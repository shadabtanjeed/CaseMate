import '../../../core/network/api_client.dart';

class ScheduleService {
  final ApiClient apiClient;
  ScheduleService({ApiClient? apiClient})
      : apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> getSchedule(String email) async {
    final res = await apiClient.get('/lawyer/schedules/$email');
    return res;
  }

  Future<Map<String, dynamic>> saveSchedule(
      String email, Map<String, dynamic> payload) async {
    final res = await apiClient.post('/lawyer/schedules/$email', body: payload);
    return res;
  }

  /// Get appointments for a lawyer on a specific date
  /// [email] - Lawyer's email
  /// [date] - Date in format 'YYYY-MM-DD'
  Future<List<Map<String, dynamic>>> getAppointmentsByDate(
    String email,
    String date,
  ) async {
    try {
      final res = await apiClient.get('/appointments/lawyer/$email/date/$date');
      final appointments = res['appointments'] as List<dynamic>? ?? [];
      return appointments.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error fetching appointments: $e');
      return [];
    }
  }
}
