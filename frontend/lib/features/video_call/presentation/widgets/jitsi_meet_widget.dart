import 'package:flutter/material.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';
import '../../../../core/theme/app_theme.dart';

class JitsiMeetWidget extends StatefulWidget {
  final String roomName;
  final String userDisplayName;
  final String userEmail;
  final bool isLawyer;
  final VoidCallback onCallEnded;

  const JitsiMeetWidget({
    super.key,
    required this.roomName,
    required this.userDisplayName,
    required this.userEmail,
    required this.isLawyer,
    required this.onCallEnded,
  });

  @override
  State<JitsiMeetWidget> createState() => _JitsiMeetWidgetState();
}

class _JitsiMeetWidgetState extends State<JitsiMeetWidget> {
  late JitsiMeet _jitsiMeet;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeJitsi();
  }

  Future<void> _initializeJitsi() async {
    try {
      _jitsiMeet = JitsiMeet();
      await _joinMeeting();
    } catch (e) {
      debugPrint('Error initializing Jitsi: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinMeeting() async {
    try {
      final options = JitsiMeetConferenceOptions(
        room: widget.roomName,
        serverURL: 'https://jitsi.riot.im/',
        userInfo: JitsiMeetUserInfo(
          displayName: widget.userDisplayName,
          email: widget.userEmail,
        ),
      );

      final listener = JitsiMeetEventListener(
        conferenceJoined: (url) {
          debugPrint('Conference joined: $url');
          if (mounted) {
            setState(() => _isLoading = false);
          }
        },
        conferenceTerminated: (url, error) {
          debugPrint('Conference terminated: $url, error: $error');
          widget.onCallEnded();
          if (mounted) {
            Navigator.pop(context);
          }
        },
      );

      await _jitsiMeet.join(options, listener);
    } catch (e) {
      debugPrint('Error joining meeting: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to join meeting: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Meeting'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Error joining meeting',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Joining Meeting...'),
          backgroundColor: AppTheme.primaryBlue,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to meeting...'),
            ],
          ),
        ),
      );
    }

    return Container(); // Jitsi handles the full screen
  }
}
