import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../core/constants/api_constants.dart';

class MeetingService {
  late String _baseUrl;
  late String? _authToken;

  MeetingService({String? authToken}) {
    // Always use unified base URL that already includes "/api" suffix
    _baseUrl = ApiConstants.baseUrl; // e.g., http://host:8000/api
    _authToken = authToken;
  }

  void _log(String message) {
    if (kDebugMode) {
      // Only logs in debug/profile, no-op in release
      debugPrint('[MeetingService] $message');
    }
  }

  Uri _buildUri(String path) {
    // _baseUrl already ends without trailing slash and includes /api
    // 'path' must start with '/'
    final normalizedBase = _baseUrl.replaceAll(RegExp(r'/+$'), '');
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final full = '$normalizedBase$normalizedPath';
    _log('→ URL: $full');
    return Uri.parse(full);
  }

  Future<Map<String, dynamic>> createMeetingRoom({
    required String appointmentId,
    required String lawyerEmail,
    required String userEmail,
    required String scheduledTime,
  }) async {
    try {
      final uri = _buildUri('/meetings/create-room');
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      _log('POST create-room headers: ' + headers.keys.join(','));
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'appointment_id': appointmentId,
          'lawyer_email': lawyerEmail,
          'user_email': userEmail,
          'scheduled_time': scheduledTime,
        }),
      );

      if (response.statusCode == 200) {
        _log('✓ create-room 200');
        return jsonDecode(response.body);
      } else {
        _log('✗ create-room ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to create meeting room: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('! create-room exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getMeetingStatus(String roomId) async {
    try {
      final uri = _buildUri('/meetings/room/$roomId/status');
      final headers = {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      _log('GET status headers: ' + headers.keys.join(','));
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        _log('✓ status 200');
        return jsonDecode(response.body);
      } else {
        _log('✗ status ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to get meeting status: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('! status exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> joinMeeting({
    required String roomId,
    required String name,
    required String userType, // 'lawyer' or 'user'
  }) async {
    try {
      final uri = _buildUri('/meetings/room/$roomId/join');
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      _log('POST join headers: ' + headers.keys.join(','));
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'name': name,
          'user_type': userType,
        }),
      );

      if (response.statusCode == 200) {
        _log('✓ join 200');
        return jsonDecode(response.body);
      } else {
        _log('✗ join ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to join meeting: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('! join exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> leaveMeeting(String roomId) async {
    try {
      final uri = _buildUri('/meetings/room/$roomId/leave');
      final headers = {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      _log('POST leave headers: ' + headers.keys.join(','));
      final response = await http.post(uri, headers: headers);

      if (response.statusCode == 200) {
        _log('✓ leave 200');
        return jsonDecode(response.body);
      } else {
        _log('✗ leave ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to leave meeting: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('! leave exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> checkRoomParticipants(String roomId) async {
    try {
      final uri = _buildUri('/meetings/room/$roomId/has-participants');
      final headers = {
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      _log('GET has-participants headers: ' + headers.keys.join(','));
      final response = await http.get(uri, headers: headers);

      if (response.statusCode == 200) {
        _log('✓ has-participants 200');
        return jsonDecode(response.body);
      } else {
        _log('✗ has-participants ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to check participants: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('! has-participants exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> endMeeting({
    required String roomId,
    int durationMinutes = 0,
    String notes = '',
  }) async {
    try {
      final uri = _buildUri('/meetings/room/$roomId/end');
      final headers = {
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };
      _log('POST end headers: ' + headers.keys.join(','));
      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode({
          'duration_minutes': durationMinutes,
          'notes': notes,
        }),
      );

      if (response.statusCode == 200) {
        _log('✓ end 200');
        return jsonDecode(response.body);
      } else {
        _log('✗ end ${response.statusCode}: ${response.body}');
        return {
          'success': false,
          'error': 'Failed to end meeting: ${response.statusCode}',
        };
      }
    } catch (e) {
      _log('! end exception: $e');
      return {'success': false, 'error': e.toString()};
    }
  }
}
