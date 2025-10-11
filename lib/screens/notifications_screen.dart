import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NotificationsScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final notifications = [
      NotificationItem(
        icon: Icons.calendar_today,
        title: 'Upcoming Consultation',
        message: 'Your consultation with Dr. Sarah Johnson is scheduled for tomorrow at 10:00 AM',
        time: '2 hours ago',
        isRead: false,
        color: AppTheme.primaryBlue,
      ),
      NotificationItem(
        icon: Icons.chat_bubble_outline,
        title: 'New Message',
        message: 'Mr. Michael Chen replied to your query',
        time: '5 hours ago',
        isRead: false,
        color: AppTheme.accentBlue,
      ),
      NotificationItem(
        icon: Icons.attach_money,
        title: 'Payment Confirmed',
        message: 'Your payment of \$150 for the consultation has been processed',
        time: '1 day ago',
        isRead: true,
        color: AppTheme.primaryBlue,
      ),
      NotificationItem(
        icon: Icons.star,
        title: 'Rate Your Experience',
        message: 'How was your consultation with Dr. Sarah Johnson?',
        time: '2 days ago',
        isRead: true,
        color: AppTheme.accentBlue,
      ),
      NotificationItem(
        icon: Icons.calendar_today,
        title: 'Consultation Rescheduled',
        message: 'Your consultation with Ms. Emily Rodriguez has been rescheduled to Oct 15',
        time: '3 days ago',
        isRead: true,
        color: AppTheme.primaryBlue,
      ),
    ];

    final unreadCount = notifications.where((n) => !n.isRead).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: const Text('Notifications'),
        actions: [
          if (unreadCount > 0)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Chip(
                label: Text('$unreadCount new'),
                backgroundColor: Colors.white,
                labelStyle: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12),
              ),
            ),
        ],
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
            ),
          ),
        ),
      ),
      body: notifications.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      return _buildNotificationCard(notifications[index]);
                    },
                  ),
                ),
                if (unreadCount > 0) _buildMarkAllButton(context),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: const BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              size: 64,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "You're all caught up! We'll notify you when something new happens.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead ? null : AppTheme.accentBlue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: notification.isRead ? AppTheme.borderColor : AppTheme.primaryBlue,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: notification.color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                notification.icon,
                color: notification.color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification.time,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarkAllButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () {},
          child: const Text('Mark All as Read'),
        ),
      ),
    );
  }
}

class NotificationItem {
  final IconData icon;
  final String title;
  final String message;
  final String time;
  final bool isRead;
  final Color color;

  NotificationItem({
    required this.icon,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.color,
  });
}
