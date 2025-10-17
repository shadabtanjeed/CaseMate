import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/theme/app_theme.dart';

class PersonalDetailsScreen extends ConsumerWidget {
  const PersonalDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isLawyer = user?.role == 'lawyer'; // Check if user is a lawyer

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Details'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(authProvider.notifier).refreshCurrentUser(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _infoHeader(context, user?.fullName ?? '—', user?.email ?? '—'),
            const SizedBox(height: 16),
            _sectionTitle(context, 'Account Information'),
            const SizedBox(height: 8),
            _infoTile(
              context,
              icon: Icons.badge_outlined,
              label: 'Full Name',
              value: user?.fullName ?? '—',
            ),
            _infoTile(
              context,
              icon: Icons.email_outlined,
              label: 'Email',
              value: user?.email ?? '—',
            ),
            
            // Show lawyer details only if user is a lawyer
            if (isLawyer) ...[
              const SizedBox(height: 16),
              _sectionTitle(context, 'Lawyer Details'),
              const SizedBox(height: 8),
              _infoTile(
                context,
                icon: Icons.credit_card_outlined,
                label: 'License ID',
                value: (user?.licenseId?.trim().isNotEmpty ?? false)
                    ? user!.licenseId!
                    : '—',
              ),
              _infoTile(
                context,
                icon: Icons.work_outline,
                label: 'Specialization',
                value: (user?.specialization?.trim().isNotEmpty ?? false)
                    ? user!.specialization!
                    : '—',
              ),
              _infoTile(
                context,
                icon: Icons.trending_up_outlined,
                label: 'Years of Experience',
                value: user?.yearsOfExperience?.toString() ?? '—',
              ),
              _infoTile(
                context,
                icon: Icons.notes_outlined,
                label: 'Bio',
                value: (user?.bio?.trim().isNotEmpty ?? false) ? user!.bio! : '—',
                multiline: true,
              ),
            ],
            
            // Show user details only if user is NOT a lawyer
            if (!isLawyer) ...[
              const SizedBox(height: 16),
              _sectionTitle(context, 'User Detailss'),
              const SizedBox(height: 8),
              _infoTile(
                context,
                icon: Icons.phone_outlined,
                label: 'Phone Number',
                value: user?.phone ?? '—',
              ),
              _infoTile(
                context,
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: user?.location ?? '—',
              ),
            ],
            
            const SizedBox(height: 24),
            _tipBox(context),
          ],
        ),
      ),
    );
  }

  Widget _infoHeader(BuildContext context, String name, String email) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.primaryBlue,
            child: Text(
              _initialsFrom(name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _infoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool multiline = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryBlue),
        title: Text(label),
        subtitle: Text(
          value,
          maxLines: multiline ? null : 1,
          overflow: multiline ? TextOverflow.visible : TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }

  Widget _tipBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentBlue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Pull down to refresh the latest profile details. Editing will be enabled later.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _initialsFrom(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}