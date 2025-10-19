import 'package:flutter/material.dart';
// theme handled via Theme.of(context)
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';

class CaseDetailsScreen extends StatelessWidget {
  final CaseModel caseModel;

  const CaseDetailsScreen({super.key, required this.caseModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Case Details'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
                context, 'Case Title', caseModel.caseTitle, Icons.gavel),
            const SizedBox(height: 16),
            _buildInfoCard(
                context, 'Case Type', caseModel.caseType, Icons.category),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Description',
              caseModel.description,
              Icons.description,
              maxLines: null,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
                context, 'Client Email', caseModel.userEmail, Icons.email),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Status',
              caseModel.status.toUpperCase(),
              Icons.flag,
              valueColor: caseModel.statusColor,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(context, 'Case ID', caseModel.caseId, Icons.badge),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Created',
              _formatDate(caseModel.creationDate),
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              context,
              'Last Updated',
              _formatDate(caseModel.lastUpdated),
              Icons.update,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    int? maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ??
                        Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: maxLines,
                  overflow: maxLines != null ? TextOverflow.ellipsis : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
