import 'package:flutter/material.dart';
import 'package:legal_assist/features/lawyer/data/models/case_model.dart';
import 'package:legal_assist/features/lawyer/data/lawyer_case_service.dart';
import 'package:legal_assist/features/lawyer/presentation/screens/case_details_screen.dart';
import 'package:legal_assist/features/lawyer/presentation/screens/update_case_status_sheet.dart';

class LawyerCasesScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LawyerCasesScreen({super.key, required this.onBack});

  @override
  State<LawyerCasesScreen> createState() => _LawyerCasesScreenState();
}

class _LawyerCasesScreenState extends State<LawyerCasesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LawyerCaseService _caseService = LawyerCaseService();
  final TextEditingController _searchController = TextEditingController();

  List<CaseModel> _allCases = [];
  List<CaseModel> _filteredCases = [];
  bool _isLoading = true;
  String _currentFilter = 'all';
  String _lawyerEmail = '';

  // Stats
  int _activeCount = 0;
  int _pendingCount = 0;
  int _totalCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadLawyerEmail();
    _loadCases();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadLawyerEmail() {
    // TODO: Get from SharedPreferences or auth service
    _lawyerEmail = 'shadabtanjeed@iut-dhaka.edu';
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _currentFilter =
            ['all', 'ongoing', 'pending', 'closed'][_tabController.index];
        _filterCases();
      });
    }
  }

  Future<void> _loadCases() async {
    setState(() => _isLoading = true);

    try {
      final cases = await _caseService.getCases(
        lawyerEmail: _lawyerEmail,
        searchQuery: _searchController.text,
      );

      setState(() {
        _allCases = cases;
        _calculateStats();
        _filterCases();
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

  void _calculateStats() {
    _totalCount = _allCases.length;
    _activeCount =
        _allCases.where((c) => c.status.toLowerCase() == 'ongoing').length;
    _pendingCount =
        _allCases.where((c) => c.status.toLowerCase() == 'pending').length;
  }

  void _filterCases() {
    setState(() {
      if (_currentFilter == 'all') {
        _filteredCases = _allCases;
      } else {
        _filteredCases = _allCases
            .where(
                (c) => c.status.toLowerCase() == _currentFilter.toLowerCase())
            .toList();
      }
    });
  }

  void _searchCases(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterCases();
      } else {
        _filteredCases = _allCases
            .where((c) =>
                c.caseTitle.toLowerCase().contains(query.toLowerCase()) &&
                (_currentFilter == 'all' ||
                    c.status.toLowerCase() == _currentFilter))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCasesList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary
          ],
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
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              ),
              const Expanded(
                child: Text(
                  'Case Management',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadCases,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildHeaderStat(
                    _activeCount.toString(),
                    'Active',
                    Icons.folder_open,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildHeaderStat(
                    _pendingCount.toString(),
                    'Pending',
                    Icons.hourglass_empty,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6.0),
                  child: _buildHeaderStat(
                    _totalCount.toString(),
                    'Total',
                    Icons.folder,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _searchCases,
        decoration: InputDecoration(
          hintText: 'Search cases by title...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchCases('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          filled: true,
          fillColor: Theme.of(context).cardColor,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
        isScrollable: true,
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Ongoing'),
          Tab(text: 'Pending'),
          Tab(text: 'Closed'),
        ],
      ),
    );
  }

  Widget _buildCasesList() {
    if (_filteredCases.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open,
                size: 64, color: Theme.of(context).textTheme.bodyMedium?.color),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No cases found matching "${_searchController.text}"'
                  : 'No cases found',
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCases,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredCases.length,
        itemBuilder: (context, index) {
          return _buildCaseCard(_filteredCases[index]);
        },
      ),
    );
  }

  Widget _buildCaseCard(CaseModel caseModel) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getPriorityColor(context, caseModel.priorityLevel)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  caseModel.priorityLevel,
                  style: TextStyle(
                    fontSize: 11,
                    color: _getPriorityColor(context, caseModel.priorityLevel),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person,
                  size: 14,
                  color: Theme.of(context).textTheme.bodyMedium?.color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  caseModel.userEmail,
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                caseModel.caseType,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                caseModel.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  color: caseModel.statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewCaseDetails(caseModel),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('View Details'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateCaseStatus(caseModel),
                  icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                  label: const Text('Update'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(BuildContext context, String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    }
  }

  void _viewCaseDetails(CaseModel caseModel) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CaseDetailsScreen(caseModel: caseModel),
      ),
    );
  }

  void _updateCaseStatus(CaseModel caseModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateCaseStatusSheet(
        caseModel: caseModel,
        onUpdate: (newStatus) async {
          try {
            await _caseService.updateCaseStatus(caseModel.id, newStatus);
            if (mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Case status updated successfully'),
                  backgroundColor: Colors.green,
                ),
              );
              _loadCases(); // Reload cases
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error updating status: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        },
      ),
    );
  }
}
