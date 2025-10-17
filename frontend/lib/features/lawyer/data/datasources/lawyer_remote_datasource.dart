import '../../../../core/network/api_client.dart';
import '../models/lawyer_model.dart';

class LawyerRemoteDataSource {
  final ApiClient apiClient;

  LawyerRemoteDataSource({required this.apiClient});

  Future<List<LawyerModel>> searchLawyers({
    String? q,
    String? specialization,
    double? minRating,
    int page = 1,
    int pageSize = 20,
  }) async {
    final queryParams = <String, String>{};
    if (q != null && q.isNotEmpty) queryParams['q'] = q;
    if (specialization != null && specialization.isNotEmpty) queryParams['specialization'] = specialization;
    if (minRating != null) queryParams['min_rating'] = minRating.toString();
    queryParams['page'] = page.toString();
    queryParams['page_size'] = pageSize.toString();

    final uri = StringBuffer('/lawyers');
    if (queryParams.isNotEmpty) {
      uri.write('?');
      uri.writeAll(queryParams.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}'), '&');
    }

    // Debug: print the final request URI
    // ignore: avoid_print
    print('LawyerRemoteDataSource.request URI: ${uri.toString()}');
    final response = await apiClient.get(uri.toString());
    // Debug: print raw response to help troubleshooting during development
    // ignore: avoid_print
    print('LawyerRemoteDataSource.searchLawyers raw response: $response');
    // response is expected to be a list encoded as JSON object? apiClient.get returns Map; adapt
    // We'll assume response contains a JSON list under 'data' OR is the list itself. Try both.
    final List<dynamic>? rawList = response['data'] as List<dynamic>? ?? (response as dynamic) as List<dynamic>?;

    if (rawList == null) return [];

    return rawList.map((e) => LawyerModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<LawyerModel?> getLawyerById(String id) async {
    final response = await apiClient.get('/lawyers/$id');
    // Debug: print raw response
    // ignore: avoid_print
    print('LawyerRemoteDataSource.getLawyerById raw response: $response');
    final data = response['data'] as Map<String, dynamic>?;
    if (data == null) return null;
    return LawyerModel.fromJson(data);
  }
}
