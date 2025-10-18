import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:legal_assist/features/lawyer/data/models/client_model.dart';
import 'package:legal_assist/features/lawyer/data/lawyer_client_service.dart';
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';
import 'case_details_screen.dart';

class ClientCasesScreen extends StatefulWidget {
  final ClientModel client;
  final String lawyerEmail;

  const ClientCasesScreen({
    super.key,
    required this.client,
    required this.lawyerEmail,
  });

  @override
  State<ClientCasesScreen> createState() => _ClientCasesScreenState();
}

class _ClientCasesScreenState extends State<ClientCasesScreen> {
  final LawyerClientService _clientService = LawyerClientService();
  List<CaseModel> _cases = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClientCases();
  }

  Future<void> _loadClientCases() async {
    setState(() => _isLoading = true);

    try {
      final cases = await _clientService.getClientCases(
        lawyerEmail: widget.lawyerEmail,
        userEmail: widget.client.userEmail,
      );

      setState(() {
        _cases = cases;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading cases: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('${widget.client.fullName}\'s Cases'),
        backgroundColor: AppTheme.primaryBlue,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _cases.isEmpty
              ? _buildEmptyState()
              : _buildCasesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64, color: AppTheme.textSecondary),
          const SizedBox(height: 16),
          Text(
            'No cases found for this client',
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCasesList() {
    return RefreshIndicator(
      onRefresh: _loadClientCases,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _cases.length,
        itemBuilder: (context, index) {
          return _buildCaseCard(_cases[index]);
        },
      ),
    );
  }

  Widget _buildCaseCard(CaseModel caseModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: caseModel.statusColor.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  caseModel.caseTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: caseModel.statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  caseModel.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    color: caseModel.statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.category, size: 14, color: AppTheme.textSecondary),
              const SizedBox(width: 4),
              Text(
                caseModel.caseType,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.description, size: 16, color: caseModel.statusColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  caseModel.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: caseModel.statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _viewCaseDetails(caseModel),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('View Full Details'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _viewCaseDetails(CaseModel caseModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaseDetailsScreen(caseModel: caseModel),
      ),
    );
  }
}