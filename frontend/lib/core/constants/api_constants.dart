import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URL - prefer SERVER_URL from .env, else default to emulator host.
  static String _envOrDefault(String key, String defaultVal) {
    final v = dotenv.env[key];
    if (v == null) return defaultVal;
    final t = v.trim();
    return t.isEmpty ? defaultVal : t;
  }

  static final String baseHost =
      _envOrDefault('SERVER_URL', 'http://10.0.2.2:8000')
          .replaceAll(RegExp(r'/$'), '');

  static final String baseUrl = '$baseHost/api';

  // shadab
  // static const String baseUrl = 'http://192.168.0.232:8000/api';

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String getCurrentUser = '/auth/me';
  static const String changePassword = '/auth/password/change';
  static const String requestPasswordReset = '/auth/password/request-reset';
  static const String verifyResetPin = '/auth/password/verify-code';
  static const String resetPassword = '/auth/password/reset';

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
