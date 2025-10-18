import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';

class CaseDetailsScreen extends StatelessWidget {
  final CaseModel caseModel;

  const CaseDetailsScreen({super.key, required this.caseModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Case Details'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Case Title', caseModel.caseTitle, Icons.gavel),
            const SizedBox(height: 16),
            _buildInfoCard('Case Type', caseModel.caseType, Icons.category),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Description',
              caseModel.description,
              Icons.description,
              maxLines: null,
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Client Email', caseModel.userEmail, Icons.email),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Status',
              caseModel.status.toUpperCase(),
              Icons.flag,
              valueColor: caseModel.statusColor,
            ),
            const SizedBox(height: 16),
            _buildInfoCard('Case ID', caseModel.caseId, Icons.badge),
            const SizedBox(height: 16),
            _buildInfoCard(
              'Created',
              _formatDate(caseModel.creationDate),
              Icons.calendar_today,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
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
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    int? maxLines = 1,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryBlue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: valueColor ?? AppTheme.textPrimary,
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
