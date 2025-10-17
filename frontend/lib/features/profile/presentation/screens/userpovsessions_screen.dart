import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:jitsi_meet_flutter_sdk/jitsi_meet_flutter_sdk.dart';

class UserPovSessionsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBack;

  const UserPovSessionsScreen({Key? key, this.onBack}) : super(key: key);

  @override
  ConsumerState<UserPovSessionsScreen> createState() => _UserPovSessionsScreenState();
}

class _UserPovSessionsScreenState extends ConsumerState<UserPovSessionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _appointments = [];
  bool _isLoading = true;
  String? _error;
  final Set<String> _visibleIds = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final local = ref.read(authLocalDataSourceProvider);
      final token = await local.getAccessToken();

      if (token == null) {
        setState(() {
          _error = 'Not authenticated';
          _isLoading = false;
        });
        return;
      }

      final api = ref.read(apiClientProvider);
      final resp = await api.get('/appointments/me', headers: ApiConstants.headersWithToken(token));
      final data = resp['data'] as List<dynamic>? ?? [];
      setState(() {
        _appointments = data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        _isLoading = false;
      });

      // Staggered entrance animation - smoother and slower for visibility
      for (var i = 0; i < _appointments.length; i++) {
        final idKey = (_appointments[i]['appointment_id'] ?? i).toString();
        Future.delayed(Duration(milliseconds: 150 * i), () {
          if (!mounted) return;
          setState(() => _visibleIds.add(idKey));
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Jitsi join helper - uses appointment_id as room name
  Future<void> _joinJitsiMeeting(Map<String, dynamic> appt) async {
    try {
      final rawId = (appt['appointment_id'] ?? DateTime.now().millisecondsSinceEpoch).toString();
      final room = 'casemate-$rawId'.replaceAll(RegExp(r"\s+"), '-');

      // optional: pass user display name and email if available
      final local = ref.read(authLocalDataSourceProvider);
      String displayName = 'Client';
      String email = '';
      try {
        final profile = await local.getUser();
        if (profile != null) {
          displayName = profile.fullName;
          email = profile.email;
        }
      } catch (_) {}

      // Use the JitsiMeet API from the installed package
      final jitsi = JitsiMeet();
      final options = JitsiMeetConferenceOptions(
        room: room,
        serverURL: 'https://meet.jit.si',
        userInfo: JitsiMeetUserInfo(displayName: displayName, email: email),
      );

      // optional listener
      final listener = JitsiMeetEventListener(
        conferenceJoined: (url) {
          // joined
        },
        conferenceTerminated: (url, error) {
          // terminated
        },
      );

      jitsi.join(options, listener);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to join meeting: $err')));
    }
  }

  int _parseDateMs(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) {
      try {
        return int.parse(v);
      } catch (_) {
        try {
          return double.parse(v).toInt();
        } catch (_) {
          return 0;
        }
      }
    }
    if (v is num) return v.toInt();
    return 0;
  }

  bool _parseBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is int) return v != 0;
    if (v is String) return v.toLowerCase() == 'true' || v == '1';
    return false;
  }

  List<Map<String, dynamic>> get _upcoming => _appointments.where((a) {
        final isFinished = _parseBool(a['is_finished']);
        final date = _parseDateMs(a['date']);
        final now = DateTime.now().millisecondsSinceEpoch;
        return !isFinished && date >= now;
      }).toList();

  List<Map<String, dynamic>> get _past => _appointments.where((a) {
        final isFinished = _parseBool(a['is_finished']);
        final date = _parseDateMs(a['date']);
        final now = DateTime.now().millisecondsSinceEpoch;
        return isFinished || date < now;
      }).toList();

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final appointmentDay = DateTime(dt.year, dt.month, dt.day);

    if (appointmentDay == today) {
      return 'Today, ${_formatTime(dt)}';
    } else if (appointmentDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, ${_formatTime(dt)}';
    } else if (appointmentDay.isAfter(today) && appointmentDay.isBefore(today.add(const Duration(days: 7)))) {
      final weekday = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dt.weekday - 1];
      return '$weekday, ${_formatTime(dt)}';
    } else {
      final month = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][dt.month - 1];
      return '${dt.day} $month ${dt.year}, ${_formatTime(dt)}';
    }
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  Widget _buildCard(Map<String, dynamic> a, bool upcoming) {
    final dateMs = _parseDateMs(a['date']);
    final dt = DateTime.fromMillisecondsSinceEpoch(dateMs);
    final isFinished = _parseBool(a['is_finished']);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppTheme.borderColor, width: 1),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a['case_type'] ?? 'Consultation',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              upcoming ? Icons.schedule : Icons.history,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                dateMs == 0 ? 'TBD' : _formatDate(dt),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: isFinished
                          ? Colors.grey.shade100
                          : upcoming
                              ? AppTheme.primaryBlue.withOpacity(0.1)
                              : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isFinished
                            ? Colors.grey.shade300
                            : upcoming
                                ? AppTheme.primaryBlue.withOpacity(0.3)
                                : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      isFinished ? 'Completed' : 'Scheduled',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isFinished
                            ? Colors.grey.shade700
                            : upcoming
                                ? AppTheme.primaryBlue
                                : Colors.grey.shade700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    if ((a['lawyer_name'] ?? '').toString().isNotEmpty) ...[
                      _buildInfoRow(Icons.person_outline, 'Lawyer', a['lawyer_name'] ?? ''),
                      const SizedBox(height: 6),
                    ],
                    _buildInfoRow(Icons.email_outlined, 'Email', a['lawyer_email'] ?? 'Not assigned'),
                    const SizedBox(height: 6),
                    if ((a['lawyer_phone'] ?? '').toString().isNotEmpty) ...[
                      _buildInfoRow(Icons.phone, 'Phone', a['lawyer_phone'] ?? ''),
                      const SizedBox(height: 6),
                    ],
                    _buildInfoRow(Icons.video_call_outlined, 'Type', a['consultation_type'] ?? 'Not specified'),
                  ],
                ),
              ),
              if (a['description'] != null && a['description'].toString().trim().isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade100.withOpacity(0.5)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.description_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          a['description'] ?? '',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            height: 1.4,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (upcoming) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      // start jitsi meeting for testing - no time constraint
                      await _joinJitsiMeeting(a);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.video_call, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Join Session',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade800,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your sessions will appear here',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onBack != null) {
              widget.onBack!();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: const Text(
          'My Sessions',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: -0.5),
        ),
        backgroundColor: AppTheme.primaryBlue,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(72),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(4),
              child: TabBar(
                controller: _tabController,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                ),
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'Past'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading sessions',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error!,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAnimatedList(_upcoming, true),
                    _buildAnimatedList(_past, false),
                  ],
                ),
    );
  }

  Widget _buildAnimatedList(List<Map<String, dynamic>> items, bool upcoming) {
    if (items.isEmpty) {
      return _buildEmptyState(
          upcoming ? 'No upcoming sessions' : 'No past sessions',
          upcoming ? Icons.event_available_outlined : Icons.history_outlined);
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 12),
      itemCount: items.length,
      itemBuilder: (context, idx) {
        final appt = items[idx];
        final idKey = (appt['appointment_id'] ?? idx).toString();
        final visible = _visibleIds.contains(idKey);

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 600),
          opacity: visible ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutBack,
            offset: visible ? Offset.zero : const Offset(0, 0.2),
            child: AnimatedScale(
              duration: const Duration(milliseconds: 600),
              scale: visible ? 1.0 : 0.95,
              curve: Curves.easeOutBack,
              child: _buildCard(appt, upcoming),
            ),
          ),
        );
      },
    );
  }
}
