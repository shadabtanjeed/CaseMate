import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';
class UpdateCaseStatusSheet extends StatefulWidget {
  final CaseModel caseModel;
  final Function(String) onUpdate;

  const UpdateCaseStatusSheet({
    super.key,
    required this.caseModel,
    required this.onUpdate,
  });

  @override
  State<UpdateCaseStatusSheet> createState() => _UpdateCaseStatusSheetState();
}

class _UpdateCaseStatusSheetState extends State<UpdateCaseStatusSheet> {
  late String _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.caseModel.status;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Update Case Status',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.caseModel.caseTitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 24),
          _buildStatusOption(
            'pending',
            'Pending',
            Icons.hourglass_empty,
            Colors.orange,
            'Case is awaiting review or action',
          ),
          _buildStatusOption(
            'ongoing',
            'Ongoing',
            Icons.refresh,
            AppTheme.accentBlue,
            'Actively working on the case',
          ),
          _buildStatusOption(
            'closed',
            'Closed',
            Icons.check_circle,
            Colors.green,
            'Case has been completed',
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUpdating
                  ? null
                  : () {
                      setState(() => _isUpdating = true);
                      widget.onUpdate(_selectedStatus);
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isUpdating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Update Status'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusOption(
    String value,
    String label,
    IconData icon,
    Color color,
    String description,
  ) {
    final isSelected = _selectedStatus == value;

    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = value),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}