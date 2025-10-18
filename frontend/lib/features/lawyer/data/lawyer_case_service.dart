import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/constants/api_constants.dart';
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';
class LawyerCaseService {
  final String baseUrl = ApiConstants.baseUrl;  // This is /api
  
  Future<List<CaseModel>> getCases({
    required String lawyerEmail,
    String? status,
    String? searchQuery,
  }) async {
    final queryParams = {
      'lawyer_email': lawyerEmail,
      if (status != null && status != 'all') 'status': status,
      if (searchQuery != null && searchQuery.isNotEmpty) 'search': searchQuery,
    };
    
    // Changed from '/lawyer/cases' to '/cases'
    final uri = Uri.parse('$baseUrl/cases')
        .replace(queryParameters: queryParams);
    
    final response = await http.get(uri);
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> data = responseData['data'];
      return data.map((json) => CaseModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load cases');
    }
  }
  
  Future<CaseModel> getCaseDetails(String caseId) async {
    // Changed from '/lawyer/cases/$caseId' to '/cases/$caseId'
    final response = await http.get(
      Uri.parse('$baseUrl/cases/$caseId'),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CaseModel.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to load case details');
    }
  }
  
  Future<CaseModel> updateCaseStatus(String caseId, String newStatus) async {
    // Changed from '/lawyer/cases/$caseId/status' to '/cases/$caseId/status'
    final response = await http.put(
      Uri.parse('$baseUrl/cases/$caseId/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': newStatus}),
    );
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      return CaseModel.fromJson(responseData['data']);
    } else {
      throw Exception('Failed to update case status');
    }
  }
}