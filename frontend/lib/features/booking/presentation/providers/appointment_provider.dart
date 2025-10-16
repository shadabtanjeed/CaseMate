import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/appointment_remote_datasource.dart';
import '../../data/repositories/appointment_repository.dart';

// API Client Provider
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

// Remote Data Source Provider
final appointmentRemoteDataSourceProvider =
    Provider<AppointmentRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AppointmentRemoteDataSourceImpl(apiClient: apiClient);
});

// Repository Provider
final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final remoteDataSource = ref.watch(appointmentRemoteDataSourceProvider);
  return AppointmentRepository(remoteDataSource: remoteDataSource);
});

// State for booking
final bookingLoadingProvider = StateProvider<bool>((ref) => false);

final bookingErrorProvider = StateProvider<String?>((ref) => null);

// Create appointment future provider
final createAppointmentProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>(
        (ref, appointmentData) async {
  final repository = ref.watch(appointmentRepositoryProvider);
  return await repository.createAppointment(
    lawyerEmail: appointmentData['lawyer_email'],
    userEmail: appointmentData['user_email'],
    date: appointmentData['date'],
    startTime: appointmentData['start_time'],
    endTime: appointmentData['end_time'],
    caseType: appointmentData['case_type'],
    description: appointmentData['description'],
    consultationType: appointmentData['consultation_type'],
  );
});
