import '../entities/user.dart';
import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? education,
    String? achievements,
    String? phone,
    String? location,
    String? licenseId,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<String> refreshToken(String refreshToken);

  Future<void> requestPasswordReset(String email);

  Future<void> verifyResetPin({
    required String email,
    required String pin,
  });

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  });

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<bool> isLoggedIn();
}