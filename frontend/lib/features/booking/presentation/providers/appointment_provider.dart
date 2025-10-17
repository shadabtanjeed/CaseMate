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
  final result = await repository.createAppointment(
    lawyerEmail: appointmentData['lawyer_email'],
    userEmail: appointmentData['user_email'],
    date: appointmentData['date'],
    startTime: appointmentData['start_time'],
    endTime: appointmentData['end_time'],
    caseType: appointmentData['case_type'],
    description: appointmentData['description'],
    consultationType: appointmentData['consultation_type'],
  );

  // Invalidate appointment caches after successful creation
  if (result.containsKey('success') && result['success'] == true) {
    final userEmail = appointmentData['user_email'];
    final lawyerEmail = appointmentData['lawyer_email'];

    // Invalidate user appointments cache
    ref.invalidate(userAppointmentsProvider(userEmail));

    // Invalidate lawyer appointments cache
    ref.invalidate(lawyerAppointmentsProvider(lawyerEmail));

    // Invalidate dependent providers
    ref.invalidate(nextAppointmentProvider(lawyerEmail));
    ref.invalidate(upcomingAppointmentsProvider(lawyerEmail));
  }

  return result;
});

// Get user appointments provider
final userAppointmentsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, userEmail) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get('/appointments/user/$userEmail');
    return response['appointments'] as List<dynamic>? ?? [];
  } catch (e) {
    return [];
  }
});

// Get lawyer appointments provider
final lawyerAppointmentsProvider =
    FutureProvider.family<List<dynamic>, String>((ref, lawyerEmail) async {
  final apiClient = ref.watch(apiClientProvider);
  try {
    final response = await apiClient.get('/appointments/lawyer/$lawyerEmail');
    return response['appointments'] as List<dynamic>? ?? [];
  } catch (e) {
    return [];
  }
});

// Get next appointment for lawyer provider
final nextAppointmentProvider =
    FutureProvider.family<Map<String, dynamic>?, String>(
        (ref, lawyerEmail) async {
  final appointments =
      await ref.watch(lawyerAppointmentsProvider(lawyerEmail).future);

  if (appointments.isEmpty) {
    return null;
  }

  // Filter unfinished appointments and sort by date
  final upcomingAppointments = appointments
      .whereType<Map<String, dynamic>>()
      .where((apt) => apt['is_finished'] != true)
      .toList();

  if (upcomingAppointments.isEmpty) {
    return null;
  }

  // Sort by date
  upcomingAppointments.sort((a, b) {
    final dateA = a['date'] is String ? DateTime.parse(a['date']) : a['date'];
    final dateB = b['date'] is String ? DateTime.parse(b['date']) : b['date'];
    return dateA.compareTo(dateB);
  });

  return upcomingAppointments.first;
});

// Get upcoming appointments for lawyer provider (limited)
final upcomingAppointmentsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>(
        (ref, lawyerEmail) async {
  final appointments =
      await ref.watch(lawyerAppointmentsProvider(lawyerEmail).future);

  if (appointments.isEmpty) {
    return [];
  }

  // Filter unfinished appointments and sort by date
  final upcomingAppointments = appointments
      .whereType<Map<String, dynamic>>()
      .where((apt) => apt['is_finished'] != true)
      .toList();

  // Sort by date
  upcomingAppointments.sort((a, b) {
    final dateA = a['date'] is String ? DateTime.parse(a['date']) : a['date'];
    final dateB = b['date'] is String ? DateTime.parse(b['date']) : b['date'];
    return dateA.compareTo(dateB);
  });

  // Return top 2 appointments
  return upcomingAppointments.take(2).toList();
});

// Refresh user appointments provider
final refreshUserAppointmentsProvider = Provider.family<Function, String>(
  (ref, userEmail) {
    return () {
      ref.invalidate(userAppointmentsProvider(userEmail));
    };
  },
);

// Refresh lawyer appointments provider
final refreshLawyerAppointmentsProvider = Provider.family<Function, String>(
  (ref, lawyerEmail) {
    return () {
      ref.invalidate(lawyerAppointmentsProvider(lawyerEmail));
      ref.invalidate(nextAppointmentProvider(lawyerEmail));
      ref.invalidate(upcomingAppointmentsProvider(lawyerEmail));
    };
  },
);
