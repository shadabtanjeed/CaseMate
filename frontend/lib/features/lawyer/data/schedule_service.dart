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
}
