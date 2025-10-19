// lawyer_home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../auth/presentation/providers/auth_provider.dart';
import '../booking/presentation/providers/appointment_provider.dart';

class LawyerHomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToClients;
  final VoidCallback onNavigateToSchedule;
  final VoidCallback onNavigateToEarnings;
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToNotifications;
  final VoidCallback onNavigateToReviews;
  final VoidCallback onNavigateToCases;

  const LawyerHomeScreen({
    super.key,
    required this.onNavigateToClients,
    required this.onNavigateToSchedule,
    required this.onNavigateToEarnings,
    required this.onNavigateToProfile,
    required this.onNavigateToNotifications,
    required this.onNavigateToReviews,
    required this.onNavigateToCases,
  });

  @override
  ConsumerState<LawyerHomeScreen> createState() => _LawyerHomeScreenState();
}

class _LawyerHomeScreenState extends ConsumerState<LawyerHomeScreen> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh appointments when screen is shown
    _refreshAppointments();
  }

  void _refreshAppointments() {
    final authState = ref.read(authProvider);
    final lawyerEmail = authState.user?.email;

    if (lawyerEmail != null && lawyerEmail.isNotEmpty) {
      final refresh = ref.read(refreshLawyerAppointmentsProvider(lawyerEmail));
      refresh();
    }
  }

  // Helper method to format time to 12-hour AM/PM format
  String _formatTimeToAmPm(String timeRange) {
    try {
      final times = timeRange.split(' - ');
      if (times.length != 2) return timeRange;

      final formatted = times.map((time) {
        final parts = time.trim().split(':');
        if (parts.length < 2) return time;

        final hour = int.parse(parts[0]);
        final minute = parts[1];

        final period = hour >= 12 ? 'PM' : 'AM';
        final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

        return '$hour12:$minute $period';
      }).toList();

      return '${formatted[0]} - ${formatted[1]}';
    } catch (e) {
      return timeRange;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get lawyer email from auth provider
    final authState = ref.watch(authProvider);
    final lawyerEmail = authState.user?.email ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildQuickStats(),
                    const SizedBox(height: 24),
                    if (lawyerEmail.isNotEmpty)
                      _buildTodaySchedule(context, lawyerEmail, ref)
                    else
                      _buildTodaySchedulePlaceholder(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentActivity(),
                    const SizedBox(height: 24),
                    if (lawyerEmail.isNotEmpty)
                      _buildUpcomingAppointments(context, lawyerEmail, ref)
                    else
                      _buildUpcomingAppointmentsPlaceholder(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white,
                child: Consumer(
                  builder: (context, ref, _) {
                    final user = ref.watch(authProvider).user;
                    final initials = _initialsFrom(user?.fullName ?? '');
                    return Text(
                      initials.isEmpty ? 'U' : initials,
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Morning,',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                    Consumer(builder: (context, ref, _) {
                      final user = ref.watch(authProvider).user;
                      final name = (user?.fullName.isNotEmpty ?? false)
                          ? user!.fullName
                          : 'Lawyer';
                      return Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }),
                    Consumer(builder: (context, ref, _) {
                      final user = ref.watch(authProvider).user;
                      final spec = (user?.specialization ?? '').trim();
                      if (spec.isEmpty) return const SizedBox.shrink();
                      return Text(
                        spec,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: widget.onNavigateToNotifications,
                    icon: const Icon(Icons.notifications_outlined,
                        color: Colors.white),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: const Text(
                        '5',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            Text(
              'Oct 12, 2025',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.calendar_today,
                '5',
                'Appointments',
                '2 pending',
                AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.people_outline,
                '12',
                'Total Clients',
                '+2 this week',
                AppTheme.accentBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                Icons.attach_money,
                '\$850',
                'Today\'s Earnings',
                '+15% vs avg',
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                Icons.star,
                '4.9',
                'Rating',
                '124 reviews',
                Colors.amber,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value, String label,
      String? subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (subtitle != null)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: subtitle.contains('+') ? Colors.green : null,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedule(
      BuildContext context, String lawyerEmail, WidgetRef ref) {
    final nextAppointment = ref.watch(nextAppointmentProvider(lawyerEmail));

    return nextAppointment.when(
      loading: () => _buildLoadingSchedule(context),
      error: (err, stack) => _buildErrorSchedule(context),
      data: (appointment) {
        if (appointment == null) {
          return _buildNoAppointmentSchedule(context);
        }

        // Parse appointment data
        final userName = appointment['user_full_name'] ?? 'Client';
        final caseType = appointment['case_type'] ?? 'General Consultation';
        final consultationType = appointment['consultation_type'] ?? 'video';

        // Format date
        String formattedDate = '';
        try {
          final dateStr = appointment['date'];
          final DateTime appointmentDate =
              dateStr is String ? DateTime.parse(dateStr) : dateStr;
          formattedDate = 'Oct ${appointmentDate.day}, ${appointmentDate.year}';
        } catch (e) {
          formattedDate = 'Upcoming';
        }

        // Format time to AM/PM
        final String formattedTime = _formatTimeToAmPm(
            '${appointment['start_time'] ?? '10:00'} - ${appointment['end_time'] ?? '11:00'}');

        final displayType = consultationType == 'video'
            ? 'Video Call'
            : consultationType == 'phone'
                ? 'Phone Call'
                : 'Chat';

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.accentBlue.withOpacity(0.2),
                AppTheme.primaryBlue.withOpacity(0.1)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Next Appointment',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$userName - $caseType',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.calendar_month,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16,
                      color: Theme.of(context).textTheme.bodySmall?.color),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      displayType,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryBlue,
                      ),
                      child: const Text('Reschedule'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingSchedule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorSchedule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline,
              size: 48, color: Theme.of(context).textTheme.bodySmall?.color),
          const SizedBox(height: 16),
          Text(
            'Unable to load appointments',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildNoAppointmentSchedule(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'No Appointments',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'You have no upcoming appointments',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySchedulePlaceholder() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.2),
            AppTheme.primaryBlue.withOpacity(0.1)
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.95,
          children: [
            _buildActionCard(Icons.people, 'My Clients',
                widget.onNavigateToClients, AppTheme.primaryBlue),
            _buildActionCard(Icons.calendar_month, 'Schedule',
                widget.onNavigateToSchedule, AppTheme.accentBlue),
            _buildActionCard(Icons.folder_open, 'Cases',
                widget.onNavigateToCases, AppTheme.primaryBlue),
            _buildActionCard(Icons.attach_money, 'Earnings',
                widget.onNavigateToEarnings, Colors.green),
            _buildActionCard(Icons.star, 'Reviews', widget.onNavigateToReviews,
                Colors.amber),
            _buildActionCard(Icons.settings, 'Settings',
                widget.onNavigateToProfile, AppTheme.textSecondary),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      IconData icon, String label, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Activity',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildActivityItem(
          Icons.payment,
          'Payment received',
          'John Mitchell paid \$150 for consultation',
          '10 min ago',
          Colors.green,
        ),
        _buildActivityItem(
          Icons.rate_review,
          'New review',
          'Maria Garcia left a 5-star review',
          '2 hours ago',
          Colors.amber,
        ),
        _buildActivityItem(
          Icons.person_add,
          'New client',
          'David Lee booked a consultation',
          '5 hours ago',
          AppTheme.primaryBlue,
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      IconData icon, String title, String subtitle, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointments(
      BuildContext context, String lawyerEmail, WidgetRef ref) {
    final upcomingAppointments =
        ref.watch(upcomingAppointmentsProvider(lawyerEmail));

    return upcomingAppointments.when(
      loading: () => _buildUpcomingAppointmentsLoading(),
      error: (err, stack) => _buildUpcomingAppointmentsError(),
      data: (appointments) {
        if (appointments.isEmpty) {
          return _buildNoUpcomingAppointments(context);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Consultations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: widget.onNavigateToSchedule,
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...appointments.map((appointment) {
              return _buildAppointmentCardFromData(
                context,
                appointment,
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildAppointmentCardFromData(
      BuildContext context, Map<String, dynamic> appointment) {
    final userName = appointment['user_full_name'] ?? 'Client';
    final caseType = appointment['case_type'] ?? 'General Consultation';
    final consultationType = appointment['consultation_type'] ?? 'video';

    // Format date
    String formattedDate = '';
    try {
      final dateStr = appointment['date'];
      final DateTime appointmentDate =
          dateStr is String ? DateTime.parse(dateStr) : dateStr;
      formattedDate = 'Oct ${appointmentDate.day}, ${appointmentDate.year}';
    } catch (e) {
      formattedDate = 'Upcoming';
    }

    // Format time to AM/PM
    final time = _formatTimeToAmPm(
        '${appointment['start_time'] ?? '10:00'} - ${appointment['end_time'] ?? '11:00'}');

    // Map consultation type to color
    Color color = AppTheme.primaryBlue;
    if (consultationType == 'phone') {
      color = AppTheme.accentBlue;
    } else if (consultationType == 'chat') {
      color = Colors.orange;
    }

    final displayType = consultationType == 'video'
        ? 'Video Call'
        : consultationType == 'phone'
            ? 'Phone Call'
            : 'Chat';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                child: Text(
                  userName.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      caseType,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  displayType,
                  style: TextStyle(
                    fontSize: 11,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_month,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(
                formattedDate,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.access_time,
                  size: 14,
                  color: Theme.of(context).textTheme.bodySmall?.color),
              const SizedBox(width: 4),
              Text(
                time,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const Spacer(),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('View Details'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingAppointmentsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Consultations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: widget.onNavigateToSchedule,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsError() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Consultations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: widget.onNavigateToSchedule,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Unable to load consultations',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildNoUpcomingAppointments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Consultations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: widget.onNavigateToSchedule,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 48,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
                const SizedBox(height: 12),
                Text(
                  'No upcoming consultations',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingAppointmentsPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Upcoming Consultations',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: widget.onNavigateToSchedule,
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Center(child: CircularProgressIndicator()),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.calendar_today, 'Schedule', 1),
              _buildNavItem(Icons.people, 'Clients', 2),
              _buildNavItem(Icons.folder_open, 'Cases', 3),
              _buildNavItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        if (index == 1) widget.onNavigateToSchedule();
        if (index == 2) widget.onNavigateToClients();
        if (index == 3) widget.onNavigateToCases();
        if (index == 4) widget.onNavigateToProfile();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected
                ? AppTheme.primaryBlue
                : Theme.of(context).textTheme.bodySmall?.color,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected
                  ? AppTheme.primaryBlue
                  : Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

String _initialsFrom(String name) {
  final parts =
      name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first[0].toUpperCase();
  return (parts[0][0] + parts[1][0]).toUpperCase();
}
