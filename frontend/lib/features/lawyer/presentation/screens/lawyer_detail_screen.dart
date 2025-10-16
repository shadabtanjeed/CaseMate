import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/lawyer_provider.dart';
import '../../domain/entities/lawyer_entity.dart';
import '../../../lawyer/data/schedule_service.dart';

class LawyerDetailScreen extends ConsumerStatefulWidget {
  final String lawyerId;
  final VoidCallback onBack;
  final VoidCallback onBookConsultation;

  const LawyerDetailScreen({
    super.key,
    required this.lawyerId,
    required this.onBack,
    required this.onBookConsultation,
  });

  @override
  ConsumerState<LawyerDetailScreen> createState() => _LawyerDetailScreenState();
}

class _LawyerDetailScreenState extends ConsumerState<LawyerDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
            loading: () => SizedBox(
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
                      Center(child: Text('Failed to load lawyer')),
                ),
                detail.when(
                  data: (l) => _buildReviewsTab(l),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      Center(child: Text('Failed to load lawyer')),
                ),
                detail.when(
                  data: (l) => _buildAvailabilityTab(l),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) =>
                      Center(child: Text('Failed to load lawyer')),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
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
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.borderColor),
        borderRadius: BorderRadius.circular(12),
      ),
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
          ...education.map((e) => _buildListItem(Icons.school, e)).toList(),
          const SizedBox(height: 24),
          const Text(
            'Achievements',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...achievements.map((a) => _buildListItem(Icons.star, a)).toList(),
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
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
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
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
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

          final dayWidgets = <Widget>[];
          for (final d in weekly) {
            final weekday = d['weekday'] ?? '';
            final slots = (d['slots'] as List<dynamic>?) ?? [];
            if (slots.isEmpty) continue;

            final slotChips = slots.map((s) {
              final start = s['start'] ?? '';
              final end = s['end'] ?? '';
              return Padding(
                padding: const EdgeInsets.only(right: 6, bottom: 6),
                child: Chip(
                  label: Text('$start - $end'),
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  labelStyle: const TextStyle(color: AppTheme.primaryBlue),
                  side: const BorderSide(color: AppTheme.primaryBlue),
                ),
              );
            }).toList();

            dayWidgets.add(Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      weekday,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      children: slotChips,
                    ),
                  ],
                ),
              ),
            ));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: dayWidgets,
          );
        }

        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppTheme.borderColor)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Chat Now'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: widget.onBookConsultation,
                icon: const Icon(Icons.videocam),
                label: const Text('Book'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
