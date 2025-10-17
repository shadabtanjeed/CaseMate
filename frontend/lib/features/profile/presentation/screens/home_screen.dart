import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../booking/presentation/providers/appointment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final VoidCallback onNavigateToChatbot;
  final Function(String?) onNavigateToLawyers; // optional specialization
  final VoidCallback onNavigateToProfile;
  final VoidCallback onNavigateToNotifications;

  const HomeScreen({
    super.key,
    required this.onNavigateToChatbot,
    required this.onNavigateToLawyers,
    required this.onNavigateToProfile,
    required this.onNavigateToNotifications,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh appointments when screen is shown
    _refreshAppointments();
  }

  void _refreshAppointments() {
    final authState = ref.read(authProvider);
    final userEmail = authState.user?.email;

    if (userEmail != null && userEmail.isNotEmpty) {
      final refresh = ref.read(refreshUserAppointmentsProvider(userEmail));
      refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, ref),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegalBotCard(context, ref),
                    const SizedBox(height: 24),
                    _buildCategoriesSection(context, ref),
                    const SizedBox(height: 24),
                    _buildUpcomingConsultations(context),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

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
              const CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white,
                child: Text(
                  'JD',
                  style: TextStyle(color: AppTheme.primaryBlue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.white70),
                    ),
                    Text(
                      authState.user?.fullName ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: widget.onNavigateToNotifications,
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                    ),
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
                        '3',
                        style: TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onTap: () => widget.onNavigateToLawyers(null),
            readOnly: true,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              hintText: 'Search lawyers or specializations',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            style: const TextStyle(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Get instant answers to your legal questions',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onNavigateToChatbot,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Start Chat'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, WidgetRef ref) {
    final categories = [
      {'icon': Icons.security, 'label': 'Criminal'},
      {'icon': Icons.balance, 'label': 'Civil'},
      {'icon': Icons.people, 'label': 'Family'},
      {'icon': Icons.home, 'label': 'Property'},
      {'icon': Icons.business, 'label': 'Corporate'},
      {'icon': Icons.account_balance, 'label': 'Tax'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Find Lawyers by Category',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () => widget.onNavigateToLawyers(null),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final icon = category['icon'] as IconData;
            final label = category['label'] as String;
            return InkWell(
              onTap: () => widget.onNavigateToLawyers(null),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.borderColor),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(label, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegalBotCard(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LegalBot',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text(
                    'Get instant legal answers powered by our assistant.'),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: widget.onNavigateToChatbot,
            child: const Text('Chat'),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingConsultations(BuildContext context) {
    // Get current user email from auth provider
    final authState = ref.watch(authProvider);
    final userEmail = authState.user?.email;

    if (userEmail == null || userEmail.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upcoming Consultations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Not logged in'),
        ],
      );
    }

    // Fetch user appointments
    final appointmentsAsync = ref.watch(userAppointmentsProvider(userEmail));

    return appointmentsAsync.when(
      loading: () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upcoming Consultations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
      ),
      error: (error, stack) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Upcoming Consultations',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Error loading consultations'),
        ],
      ),
      data: (appointments) {
        if (appointments.isEmpty) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Upcoming Consultations',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'No upcoming consultations',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Upcoming Consultations',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: AppTheme.textSecondary,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...appointments.asMap().entries.map((entry) {
              final index = entry.key;
              final appointment = entry.value as Map<String, dynamic>;

              if (index > 0) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: _buildConsultationCard(appointment),
                );
              }
              return _buildConsultationCard(appointment);
            }),
          ],
        );
      },
    );
  }

  Widget _buildConsultationCard(Map<String, dynamic> appointment) {
    // Extract appointment data
    final lawyerEmail = appointment['lawyer_email'] ?? 'Unknown';
    final lawyerFullName = appointment['lawyer_full_name'] ??
        lawyerEmail.split('@').first; // Fallback to email name if not available
    final caseType = appointment['case_type'] ?? 'Legal Consultation';
    final consultationType = appointment['consultation_type'] ?? 'Scheduled';
    final date = appointment['date'] ?? '';
    final startTime = appointment['start_time'] ?? '';
    final endTime = appointment['end_time'] ?? '';

    // Format lawyer name properly (capitalize first letter of each word)
    String lawyerName = lawyerFullName;
    if (lawyerName.contains('_')) {
      lawyerName = lawyerName
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '')
          .join(' ');
    }

    // Format date if it's a string (ISO format)
    String formattedDate = date;
    try {
      if (date is String && date.isNotEmpty) {
        final parsedDate = DateTime.parse(date);
        formattedDate =
            '${_monthName(parsedDate.month)} ${parsedDate.day}, ${parsedDate.year}';
      }
    } catch (e) {
      formattedDate = date.toString();
    }

    // Format start and end times with AM/PM
    String formattedTimeRange = '$startTime - $endTime';
    try {
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        final startTimeParsed = _parseTime(startTime);
        final endTimeParsed = _parseTime(endTime);
        formattedTimeRange = '$startTimeParsed - $endTimeParsed';
      }
    } catch (e) {
      formattedTimeRange = '$startTime - $endTime';
    }

    // Format consultation type nicely
    String displayConsultationType = consultationType;
    if (consultationType.isNotEmpty) {
      displayConsultationType = consultationType[0].toUpperCase() +
          consultationType.substring(1).toLowerCase();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.accentBlue,
                child: Text(
                  lawyerName
                      .split(' ')
                      .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                      .join(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lawyerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      caseType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedTimeRange,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentBlue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  displayConsultationType,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor, width: 1)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', true, () {}),
              _buildNavItem(
                Icons.balance,
                'Lawyers',
                false,
                () => widget.onNavigateToLawyers(null),
              ),
              _buildFloatingChatButton(),
              _buildNavItem(Icons.calendar_today, 'Sessions', false, () {}),
              _buildNavItem(
                Icons.person_outline,
                'Profile',
                false,
                widget.onNavigateToProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingChatButton() {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: FloatingActionButton(
        onPressed: widget.onNavigateToChatbot,
        backgroundColor: AppTheme.primaryBlue,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white),
      ),
    );
  }

  String _parseTime(String timeStr) {
    try {
      // Parse time string in HH:mm format
      final parts = timeStr.split(':');
      if (parts.length != 2) return timeStr;

      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final isAM = hour < 12;
      final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '$displayHour:${minute.toString().padLeft(2, '0')} ${isAM ? 'AM' : 'PM'}';
    } catch (e) {
      return timeStr;
    }
  }

  String _monthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
