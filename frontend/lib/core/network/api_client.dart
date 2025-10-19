import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final http.Client client;

  ApiClient({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, dynamic>> get(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers ?? ApiConstants.headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  // NEW METHOD: Get List responses
  Future<List<dynamic>> getList(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    try {
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers ?? ApiConstants.headers,
      );
      return _handleListResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> post(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers ?? ApiConstants.headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> put(
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? headers,
      }) async {
    try {
      final response = await client.put(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers ?? ApiConstants.headers,
        body: body != null ? jsonEncode(body) : null,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
      String endpoint, {
        Map<String, String>? headers,
      }) async {
    try {
      final response = await client.delete(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: headers ?? ApiConstants.headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw NetworkException('No internet connection');
    } catch (e) {
      throw NetworkException('Failed to connect to server: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        return {};
      }
      return jsonDecode(body) as Map<String, dynamic>;
    }

    // Handle errors
    Map<String, dynamic>? errorBody;
    try {
      errorBody = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      errorBody = {'message': body};
    }

    final errorMessage = errorBody['detail'] ??
        errorBody['message'] ??
        'Unknown error occurred';

    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMessage);
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 500:
        throw ServerException(errorMessage);
      default:
        throw ServerException('Server error: $statusCode');
    }
  }

  // NEW METHOD: Handle List responses
  List<dynamic> _handleListResponse(http.Response response) {
    final statusCode = response.statusCode;
    final body = response.body;

    if (statusCode >= 200 && statusCode < 300) {
      if (body.isEmpty) {
        return [];
      }
      final decoded = jsonDecode(body);
      if (decoded is List) {
        return decoded;
      } else {
        // If response is not a List, return empty list
        return [];
      }
    }

    // Handle errors (same as _handleResponse)
    Map<String, dynamic>? errorBody;
    try {
      errorBody = jsonDecode(body) as Map<String, dynamic>;
    } catch (_) {
      errorBody = {'message': body};
    }

    final errorMessage = errorBody['detail'] ??
        errorBody['message'] ??
        'Unknown error occurred';

    switch (statusCode) {
      case 400:
        throw BadRequestException(errorMessage);
      case 401:
        throw UnauthorizedException(errorMessage);
      case 403:
        throw ForbiddenException(errorMessage);
      case 404:
        throw NotFoundException(errorMessage);
      case 500:
        throw ServerException(errorMessage);
      default:
        throw ServerException('Server error: $statusCode');
    }
  }
}