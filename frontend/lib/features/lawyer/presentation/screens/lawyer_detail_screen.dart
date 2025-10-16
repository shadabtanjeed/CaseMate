import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/lawyer_provider.dart';
import '../../domain/entities/lawyer_entity.dart';
import '../../../lawyer/data/schedule_service.dart';
import 'booking_screen.dart';

class LawyerDetailScreen extends ConsumerStatefulWidget {
  final String lawyerId;
  final VoidCallback onBack;
  final VoidCallback onBookConsultation;
  final int initialTabIndex;

  const LawyerDetailScreen({
    super.key,
    required this.lawyerId,
    required this.onBack,
    required this.onBookConsultation,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<LawyerDetailScreen> createState() => _LawyerDetailScreenState();
}

class _LawyerDetailScreenState extends ConsumerState<LawyerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _selectedSlot; // Track selected slot (date_time format)
  DateTime? _selectedDateTime; // Store the actual DateTime
  final ScrollController _availabilityScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Use post-frame callback to ensure the tab is set after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tabController.animateTo(widget.initialTabIndex);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _availabilityScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(lawyerDetailProvider(widget.lawyerId));

    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          // show profile card based on provider state
          detail.when(
            data: (l) =>
                l != null ? _buildProfileCard(l) : _buildProfileCard(null),
            loading: () => const SizedBox(
                height: 220, child: Center(child: CircularProgressIndicator())),
            error: (e, st) => _buildProfileCard(null),
          ),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                detail.when(
                  data: (l) => _buildAboutTab(l),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      const Center(child: Text('Failed to load lawyer')),
                ),
                detail.when(
                  data: (l) => _buildReviewsTab(l),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      const Center(child: Text('Failed to load lawyer')),
                ),
                detail.when(
                  data: (l) => _buildAvailabilityTab(l),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      const Center(child: Text('Failed to load lawyer')),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 120,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard([LawyerEntity? lawyer]) {
    final name = lawyer?.name ?? 'Dr. Sarah Johnson';
    final specialization = lawyer?.specialization ?? 'Criminal Law';
    final rating = lawyer?.rating ?? 4.9;
    final reviews = lawyer?.reviews ?? 124;
    final experience = lawyer?.experience ?? 12;
    final location = lawyer?.location ?? 'New York, NY';
    final feeText = lawyer != null
        ? '\$${lawyer.fee} per consultation'
        : '\$150 per consultation';

    return Transform.translate(
      offset: const Offset(0, -30),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 40,
                      backgroundColor: AppTheme.accentBlue,
                      child: Text(
                        'SJ',
                        style: TextStyle(fontSize: 24, color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            specialization,
                            style:
                                const TextStyle(color: AppTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.star,
                                  size: 16, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text('$rating ($reviews reviews)'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: AppTheme.primaryBlue,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Verified',
                            style: TextStyle(
                              color: AppTheme.primaryBlue,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                        Icons.work_outline, '$experience years exp.'),
                    _buildStatItem(Icons.location_on, location),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.attach_money,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    Text(feeText),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppTheme.primaryBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textPrimary,
        labelPadding: EdgeInsets.zero,
        indicatorPadding:
            const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        tabs: const [
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text('About'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text('Reviews'),
            ),
          ),
          Tab(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Text('Availability'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutTab([LawyerEntity? lawyer]) {
    final bio = lawyer?.bio ?? 'Biography not available.';
    final education = lawyer?.education ?? [];
    final achievements = lawyer?.achievements ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Biography',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            bio,
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
          const SizedBox(height: 24),
          const Text(
            'Education',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...education.map((e) => _buildListItem(Icons.school, e)),
          const SizedBox(height: 24),
          const Text(
            'Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...achievements.map((a) => _buildListItem(Icons.star, a)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.primaryBlue),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  Widget _buildReviewsTab([LawyerEntity? lawyer]) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildReviewCard(
          'John Mitchell',
          5,
          'Sep 28, 2025',
          'Dr. Johnson was exceptional. Highly recommend!',
        ),
        _buildReviewCard(
          'Maria Garcia',
          5,
          'Sep 15, 2025',
          'Very knowledgeable and responsive.',
        ),
        _buildReviewCard(
          'David Lee',
          4,
          'Aug 30, 2025',
          'Great lawyer, excellent communication.',
        ),
      ],
    );
  }

  Widget _buildReviewCard(
    String name,
    int rating,
    String date,
    String comment,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  Icons.star,
                  size: 16,
                  color: index < rating ? Colors.amber : Colors.grey[300],
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              comment,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityTab([LawyerEntity? lawyer]) {
    final Future<Map<String, dynamic>> scheduleFuture =
        (lawyer != null && (lawyer.email ?? '').isNotEmpty)
            ? ScheduleService().getSchedule(lawyer.email!)
            : Future.value({});

    return FutureBuilder<Map<String, dynamic>>(
      future: scheduleFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule_outlined,
                      size: 48, color: AppTheme.textSecondary),
                  SizedBox(height: 16),
                  Text('No availability set',
                      style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            ),
          );
        } else if (snapshot.hasData && (snapshot.data ?? {}).isNotEmpty) {
          final data = snapshot.data!;
          final weekly = data['weekly_schedule'] as List<dynamic>? ?? [];

          if (weekly.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_outlined,
                        size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text('No availability set',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            );
          }

          // Build a map of weekday -> slots for easier lookup
          final weekdaySlots = <String, List<dynamic>>{};
          for (final d in weekly) {
            final weekday = d['weekday'] ?? '';
            final slots = (d['slots'] as List<dynamic>? ?? []);
            if (slots.isNotEmpty) {
              weekdaySlots[weekday] = slots;
            }
          }

          // Generate dates for next 4 weeks
          final today = DateTime.now();
          final dateSlots = <Map<String, dynamic>>[];

          for (int i = 0; i < 28; i++) {
            final date = today.add(Duration(days: i));
            final weekdayName = _getWeekdayName(date.weekday);

            if (weekdaySlots.containsKey(weekdayName)) {
              dateSlots.add({
                'date': date,
                'weekday': weekdayName,
                'slots': weekdaySlots[weekdayName],
              });
            }
          }

          if (dateSlots.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule_outlined,
                        size: 48, color: AppTheme.textSecondary),
                    SizedBox(height: 16),
                    Text('No available dates in the next 4 weeks',
                        style: TextStyle(color: AppTheme.textSecondary)),
                  ],
                ),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _availabilityScrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: dateSlots.length,
                  itemBuilder: (context, index) {
                    final item = dateSlots[index];
                    final date = item['date'] as DateTime;
                    final slots = item['slots'] as List<dynamic>;
                    final dateStr =
                        '${date.day} ${_getMonthName(date.month)} ${date.year}';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateStr,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: slots.map((slot) {
                                final start = slot['start'] ?? '';
                                final end = slot['end'] ?? '';
                                final slotId =
                                    '${date.toString().split(' ')[0]}_$start';
                                final isSelected = _selectedSlot == slotId;
                                return FilterChip(
                                  label: Text(
                                      '${_formatTimeToAMPM(start)} - ${_formatTimeToAMPM(end)}'),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedSlot = selected ? slotId : null;
                                      _selectedDateTime =
                                          selected ? date : null;
                                    });
                                  },
                                  backgroundColor:
                                      AppTheme.primaryBlue.withOpacity(0.1),
                                  selectedColor: AppTheme.primaryBlue,
                                  labelStyle: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.primaryBlue,
                                  ),
                                  side: BorderSide(
                                    color: isSelected
                                        ? AppTheme.primaryBlue
                                        : AppTheme.borderColor,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppTheme.borderColor)),
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectedSlot != null && lawyer != null
                          ? () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BookingScreen(
                                    lawyer: lawyer,
                                    selectedSlot: _selectedSlot!,
                                    selectedDate: _getSelectedDateString(),
                                  ),
                                ),
                              );
                            }
                          : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Book Appointment'),
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.schedule_outlined,
                    size: 48, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('No availability set',
                    style: TextStyle(color: AppTheme.textSecondary)),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  String _getMonthName(int month) {
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
      'Dec',
    ];
    return months[month - 1];
  }

  String _formatTimeToAMPM(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      final hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '$hour12:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  String _getSelectedDateString() {
    if (_selectedDateTime == null) return '';
    return '${_selectedDateTime!.day} ${_getMonthName(_selectedDateTime!.month)} ${_selectedDateTime!.year}';
  }
}
