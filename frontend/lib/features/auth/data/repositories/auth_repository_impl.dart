import '../../domain/entities/auth_token.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasources.dart';
import '../datasources/auth_remote_datasources.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<AuthToken> login({
    required String email,
    required String password,
  }) async {
    final tokenModel = await remoteDataSource.login(
      email: email,
      password: password,
    );

    // Save tokens locally
    await localDataSource.saveTokens(
      accessToken: tokenModel.accessToken,
      refreshToken: tokenModel.refreshToken,
    );

    // Fetch and save user data
    final user = await remoteDataSource.getCurrentUser(tokenModel.accessToken);
    await localDataSource.saveUser(user);

    return tokenModel.toEntity();
  }

  @override
  @override
  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? education,
    String? achievements,
    String? licenseId,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
    String? phone, // Added phone parameter
    String? location, // Added location parameter
    double? consultationFee,
  }) async {
    final userModel = await remoteDataSource.register(
      email: email,
      password: password,
      fullName: fullName,
      role: role,
      education: education,
      achievements: achievements,
      licenseId: licenseId,
      specialization: specialization,
      yearsOfExperience: yearsOfExperience,
      bio: bio,
      phone: phone, // Pass phone to remoteDataSource
      location: location, // Pass location to remoteDataSource
      consultationFee: consultationFee,
    );

    // Note: After registration, user still needs to login
    // Or you can auto-login here if backend returns tokens

    return userModel.toEntity();
  }

  @override
  Future<void> logout() async {
    await localDataSource.clearAllData();
  }

  @override
  Future<User?> getCurrentUser() async {
    // First try to get from local storage
    final localUser = await localDataSource.getUser();
    if (localUser != null) {
      return localUser.toEntity();
    }

    // If not in local storage, fetch from server
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null) {
      return null;
    }

    try {
      final userModel = await remoteDataSource.getCurrentUser(accessToken);
      await localDataSource.saveUser(userModel);
      return userModel.toEntity();
    } catch (e) {
      // Token might be expired, return null
      return null;
    }
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    final newAccessToken = await remoteDataSource.refreshToken(refreshToken);

    // Save new access token
    final oldRefreshToken = await localDataSource.getRefreshToken();
    await localDataSource.saveTokens(
      accessToken: newAccessToken,
      refreshToken: oldRefreshToken ?? refreshToken,
    );

    return newAccessToken;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await remoteDataSource.requestPasswordReset(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await remoteDataSource.resetPassword(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final accessToken = await localDataSource.getAccessToken();
    if (accessToken == null) {
      throw Exception('Not authenticated');
    }

    await remoteDataSource.changePassword(
      accessToken: accessToken,
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }


  @override
  Future<bool> isLoggedIn() async {
    return await localDataSource.isLoggedIn();
  }

  @override
  Future<void> verifyResetPin({
    required String email,
    required String pin,
  }) async {
    await remoteDataSource.verifyResetPin(email: email, pin: pin);
  }
}
