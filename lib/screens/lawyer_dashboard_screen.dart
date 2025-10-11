import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LawyerDashboardScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LawyerDashboardScreen({super.key, required this.onBack});

  @override
  State<LawyerDashboardScreen> createState() => _LawyerDashboardScreenState();
}

class _LawyerDashboardScreenState extends State<LawyerDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStatsCards(),
            const SizedBox(height: 16),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildAppointmentsTab(), _buildMessagesTab()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Dr. Sarah Johnson',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.white,
            child: Text('SJ', style: TextStyle(color: AppTheme.primaryBlue)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildStatCard(Icons.people, '124', 'Total Clients', '+12%'),
          _buildStatCard(Icons.calendar_today, '8', 'This Week', '3 today'),
          _buildStatCard(Icons.star, '4.9', 'Avg Rating', '124 reviews'),
          _buildStatCard(Icons.attach_money, '\$12.5k', 'This Month', '+8%'),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String value,
    String label,
    String? subtitle,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.accentBlue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
                ),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  color: subtitle.contains('+')
                      ? Colors.green
                      : AppTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
          ],
        ),
      ),
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
        tabs: const [
          Tab(text: 'Appointments'),
          Tab(text: 'Messages'),
        ],
      ),
    );
  }

  Widget _buildAppointmentsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Appointments',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 16),
              label: const Text('Manage'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildAppointmentCard(
          'John Mitchell',
          'Video Call',
          'Oct 12, 2025',
          '10:00 AM',
          'confirmed',
        ),
        _buildAppointmentCard(
          'Maria Garcia',
          'Chat',
          'Oct 12, 2025',
          '2:00 PM',
          'confirmed',
        ),
        _buildAppointmentCard(
          'David Lee',
          'Phone Call',
          'Oct 13, 2025',
          '11:00 AM',
          'pending',
        ),
      ],
    );
  }

  Widget _buildAppointmentCard(
    String client,
    String type,
    String date,
    String time,
    String status,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.accentBlue,
                  child: Text(
                    client.split(' ').map((e) => e[0]).join(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        type,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'confirmed'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.yellow.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: status == 'confirmed'
                          ? Colors.green[700]
                          : Colors.yellow[800],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$date • $time',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () {},
                      child: const Text('Reschedule'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Start'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Messages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '2 new',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildMessageCard(
          'Sarah Williams',
          'Thank you for your help with my case!',
          '10 min ago',
          true,
        ),
        _buildMessageCard(
          'Robert Brown',
          'Can we reschedule our meeting?',
          '1 hour ago',
          true,
        ),
        _buildMessageCard(
          'Emily Davis',
          'I have some additional documents',
          '3 hours ago',
          false,
        ),
      ],
    );
  }

  Widget _buildMessageCard(
    String client,
    String message,
    String time,
    bool unread,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: unread ? AppTheme.accentBlue.withOpacity(0.05) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: unread ? AppTheme.primaryBlue : AppTheme.borderColor,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentBlue,
          child: Text(
            client.split(' ').map((e) => e[0]).join(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        title: Text(
          client,
          style: TextStyle(
            fontWeight: unread ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        subtitle: Text(message, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            if (unread)
              Container(
                margin: const EdgeInsets.only(top: 4),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryBlue,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
