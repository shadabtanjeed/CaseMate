import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import 'package:legal_assist/features/lawyer/data/models/client_model.dart';
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';

class LawyerClientService {
  final String baseUrl = ApiConstants.baseUrl;

  Future<List<ClientModel>> getClients({
    required String lawyerEmail,
    String? status,
  }) async {
    final queryParams = {
      'lawyer_email': lawyerEmail,
      if (status != null && status != 'all') 'status': status,
    };

    final uri = Uri.parse('$baseUrl/clients')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => ClientModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load clients');
    }
  }

  Future<List<CaseModel>> getClientCases({
    required String lawyerEmail,
    required String userEmail,
  }) async {
    final queryParams = {
      'lawyer_email': lawyerEmail,
    };

    final uri = Uri.parse('$baseUrl/clients/$userEmail/cases')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => CaseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load client cases');
    }
  }
}