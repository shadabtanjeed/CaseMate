class ApiConstants {
  // Base URL - for Android emulator use 10.0.2.2 to reach host machine.
  // Change to your backend URL when testing on a physical device or iOS simulator.
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // shadab
  // static const String baseUrl = 'http://192.168.0.232:8000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String getCurrentUser = '/auth/me';
  static const String requestPasswordReset = '/auth/password-reset/request';
  static const String confirmPasswordReset = '/auth/password-reset/confirm';
  static const String changePassword = '/auth/password/change';

  // Headers
  static const Map<String, String> headers = {
    'Content-Type': 'application/json',
  };

  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
