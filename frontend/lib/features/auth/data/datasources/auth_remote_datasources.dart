import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/token_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<TokenModel> login({
    required String email,
    required String password,
  });

  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? licenseId,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
    String? phone,
    String? location,
    String? education,
    String? achievements,
    double? consultationFee,
  });

  Future<UserModel> getCurrentUser(String accessToken);

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
    required String accessToken,
    required String oldPassword,
    required String newPassword,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    final response = await apiClient.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    final Map<String, dynamic> json = Map<String, dynamic>.from(response as Map);
    return TokenModel.fromJson(json);
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
    required String fullName,
    required String role,
    String? licenseId,
    String? specialization,
    int? yearsOfExperience,
    String? bio,
    String? phone,
    String? location,
    String? education,
    String? achievements,
    double? consultationFee,
  }) async {
    final Map<String, dynamic> body = {
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'location': location,
      'education': education,
      'achievements': achievements,
    };

    if (role == 'lawyer') {
      body['license_id'] = licenseId;
      body['specialization'] = specialization;
      body['years_of_experience'] = yearsOfExperience;
      body['bio'] = bio;
      body['consultation_fee'] = consultationFee;
    }

    final response = await apiClient.post(
      ApiConstants.register,
      body: body,
    );

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response as Map);
    return UserModel.fromJson(json);
  }

  @override
  Future<UserModel> getCurrentUser(String accessToken) async {
    final response = await apiClient.get(
      ApiConstants.getCurrentUser,
      headers: ApiConstants.headersWithToken(accessToken),
    );

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response as Map);
    return UserModel.fromJson(json);
  }

  @override
  Future<String> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiConstants.refreshToken,
      body: {'refresh_token': refreshToken},
    );

    final Map<String, dynamic> json =
        Map<String, dynamic>.from(response as Map);
    return json['access_token'] as String;
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    await apiClient.post(
      ApiConstants.requestPasswordReset,
      body: {'email': email},
    );
  }

  @override
  Future<void> verifyResetPin({
    required String email,
    required String pin,
  }) async {
    await apiClient.post(
      ApiConstants.verifyResetPin,
      body: {
        'email': email,
        'code': pin,
      },
    );
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiConstants.resetPassword,
      body: {
        'email': email,
        'code': code,
        'new_password': newPassword,
      },
    );
  }

  @override
  Future<void> changePassword({
    required String accessToken,
    required String oldPassword,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiConstants.changePassword,
      headers: ApiConstants.headersWithToken(accessToken),
      body: {
        'old_password': oldPassword,
        'new_password': newPassword,
      },
    );
  }
}
