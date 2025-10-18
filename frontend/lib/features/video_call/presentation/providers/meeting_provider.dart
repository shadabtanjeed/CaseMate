import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/meeting_service.dart';

// Meeting service provider
final meetingServiceProvider = Provider<MeetingService>((ref) {
  return MeetingService();
});

// Current room ID state
final currentRoomIdProvider = StateProvider<String?>((ref) => null);

// Current meeting active state
final isMeetingActiveProvider = StateProvider<bool>((ref) => false);

// Meeting participants count
final meetingParticipantsProvider = StateProvider<int>((ref) => 0);

// Create or get meeting room
final createMeetingRoomProvider = FutureProvider.family<
    Map<String, dynamic>,
    ({
      String appointmentId,
      String lawyerEmail,
      String userEmail,
      String scheduledTime
    })>((ref, params) async {
  final service = ref.watch(meetingServiceProvider);
  return service.createMeetingRoom(
    appointmentId: params.appointmentId,
    lawyerEmail: params.lawyerEmail,
    userEmail: params.userEmail,
    scheduledTime: params.scheduledTime,
  );
});

// Get meeting status
final getMeetingStatusProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, roomId) async {
  final service = ref.watch(meetingServiceProvider);
  return service.getMeetingStatus(roomId);
});

// Join meeting
final joinMeetingProvider = FutureProvider.family<Map<String, dynamic>,
    ({String roomId, String name, String userType})>((ref, params) async {
  final service = ref.watch(meetingServiceProvider);
  return service.joinMeeting(
    roomId: params.roomId,
    name: params.name,
    userType: params.userType,
  );
});

// Leave meeting
final leaveMeetingProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, roomId) async {
  final service = ref.watch(meetingServiceProvider);
  return service.leaveMeeting(roomId);
});

// End meeting
final endMeetingProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, roomId) async {
  final service = ref.watch(meetingServiceProvider);
  return service.endMeeting(roomId: roomId);
});

// Check if room has participants
final checkRoomParticipantsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, roomId) async {
  final service = ref.watch(meetingServiceProvider);
  return service.checkRoomParticipants(roomId);
});
