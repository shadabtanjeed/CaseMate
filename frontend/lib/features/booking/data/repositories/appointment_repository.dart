import '../datasources/appointment_remote_datasource.dart';

class AppointmentRepository {
  final AppointmentRemoteDataSource remoteDataSource;

  AppointmentRepository({required this.remoteDataSource});

  Future<Map<String, dynamic>> createAppointment({
    required String lawyerEmail,
    required String userEmail,
    required String date,
    required String startTime,
    required String endTime,
    required String caseType,
    required String description,
    required String consultationType,
  }) async {
    return await remoteDataSource.createAppointment(
      lawyerEmail: lawyerEmail,
      userEmail: userEmail,
      date: date,
      startTime: startTime,
      endTime: endTime,
      caseType: caseType,
      description: description,
      consultationType: consultationType,
    );
  }

  Future<Map<String, dynamic>> getAppointment(String appointmentId) async {
    return await remoteDataSource.getAppointment(appointmentId);
  }

  Future<Map<String, dynamic>> getUserAppointments(String userEmail) async {
    return await remoteDataSource.getUserAppointments(userEmail);
  }

  Future<Map<String, dynamic>> getLawyerAppointments(String lawyerEmail) async {
    return await remoteDataSource.getLawyerAppointments(lawyerEmail);
  }

  Future<Map<String, dynamic>> updateAppointmentStatus(
    String appointmentId,
    bool isFinished,
  ) async {
    return await remoteDataSource.updateAppointmentStatus(
      appointmentId,
      isFinished,
    );
  }

  Future<Map<String, dynamic>> getCase(String caseId) async {
    return await remoteDataSource.getCase(caseId);
  }

  Future<Map<String, dynamic>> getUserCases(String userEmail) async {
    return await remoteDataSource.getUserCases(userEmail);
  }

  Future<Map<String, dynamic>> getLawyerCases(String lawyerEmail) async {
    return await remoteDataSource.getLawyerCases(lawyerEmail);
  }

  Future<Map<String, dynamic>> updateCaseStatus(
    String caseId,
    String status,
  ) async {
    return await remoteDataSource.updateCaseStatus(caseId, status);
  }
}
