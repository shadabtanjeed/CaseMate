import '../../../../core/network/api_client.dart';

abstract class AppointmentRemoteDataSource {
  Future<Map<String, dynamic>> createAppointment({
    required String lawyerEmail,
    required String userEmail,
    required String date,
    required String startTime,
    required String endTime,
    required String caseType,
    required String caseTitle,
    required String description,
    required String consultationType,
  });

  // ADD THIS METHOD TO ABSTRACT CLASS 👇
  Future<Map<String, dynamic>> createTransaction({
    required String appointmentId,
    required double userPaidAmount,
    String? transactionId,
    String? paymentMethod,
  });
  // END 👆

  Future<Map<String, dynamic>> getAppointment(String appointmentId);

  Future<Map<String, dynamic>> getUserAppointments(String userEmail);

  Future<Map<String, dynamic>> getLawyerAppointments(String lawyerEmail);

  Future<Map<String, dynamic>> updateAppointmentStatus(
      String appointmentId,
      bool isFinished,
      );

  Future<Map<String, dynamic>> getCase(String caseId);

  Future<Map<String, dynamic>> getUserCases(String userEmail);

  Future<Map<String, dynamic>> getLawyerCases(String lawyerEmail);

  Future<Map<String, dynamic>> updateCaseStatus(String caseId, String status);
}

class AppointmentRemoteDataSourceImpl implements AppointmentRemoteDataSource {
  final ApiClient apiClient;

  AppointmentRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> createAppointment({
    required String lawyerEmail,
    required String userEmail,
    required String date,
    required String startTime,
    required String endTime,
    required String caseType,
    required String caseTitle,
    required String description,
    required String consultationType,
  }) async {
    final response = await apiClient.post(
      '/appointments/create',
      body: {
        'lawyer_email': lawyerEmail,
        'user_email': userEmail,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
        'case_type': caseType,
        'case_title': caseTitle,
        'description': description,
        'consultation_type': consultationType,
      },
    );
    return response;
  }

  // ADD THIS METHOD TO IMPLEMENTATION 👇
  @override
  Future<Map<String, dynamic>> createTransaction({
    required String appointmentId,
    required double userPaidAmount,
    String? transactionId,
    String? paymentMethod,
  }) async {
    try {
      final response = await apiClient.post(
        '/transactions/',
        body: {
          'appointment_id': appointmentId,
          'user_paid_amount': userPaidAmount,
          if (transactionId != null) 'transaction_id': transactionId,
          if (paymentMethod != null) 'payment_method': paymentMethod,
        },
      );
      return {
        'success': true,
        'transaction': response,
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
      };
    }
  }
  // END 👆

  @override
  Future<Map<String, dynamic>> getAppointment(String appointmentId) async {
    final response = await apiClient.get(
      '/appointments/$appointmentId',
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getUserAppointments(String userEmail) async {
    final response = await apiClient.get(
      '/appointments/user/$userEmail',
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getLawyerAppointments(String lawyerEmail) async {
    final response = await apiClient.get(
      '/appointments/lawyer/$lawyerEmail',
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> updateAppointmentStatus(
      String appointmentId,
      bool isFinished,
      ) async {
    final response = await apiClient.put(
      '/appointments/$appointmentId/status',
      body: {'is_finished': isFinished},
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getCase(String caseId) async {
    final response = await apiClient.get(
      '/appointments/case/$caseId',
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getUserCases(String userEmail) async {
    final response = await apiClient.get(
      '/appointments/user/$userEmail/cases',
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> getLawyerCases(String lawyerEmail) async {
    final response = await apiClient.get(
      '/appointments/lawyer/$lawyerEmail/cases',
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> updateCaseStatus(
      String caseId,
      String status,
      ) async {
    final response = await apiClient.put(
      '/appointments/$caseId/status',
      body: {'case_status': status},
    );
    return response;
  }
}