import 'package:flutter/material.dart';

import 'package:legal_assist/features/lawyer/data/models/client_model.dart';
import 'package:legal_assist/features/lawyer/data/lawyer_client_service.dart';
import 'package:legal_assist/features/lawyer/presentation/screens/client_cases_screen.dart';

class LawyerClientsScreen extends StatefulWidget {
  final VoidCallback onBack;

  const LawyerClientsScreen({super.key, required this.onBack});

  @override
  State<LawyerClientsScreen> createState() => _LawyerClientsScreenState();
}

class _LawyerClientsScreenState extends State<LawyerClientsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final LawyerClientService _clientService = LawyerClientService();

  List<ClientModel> _allClients = [];
  List<ClientModel> _filteredClients = [];
  bool _isLoading = true;
  String _currentFilter = 'all';
  String _lawyerEmail = '';

  // Stats
  int _totalClients = 0;
  int _activeClients = 0;
  int _pastClients = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    _loadLawyerEmail();
    _loadClients();
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
        _currentFilter = ['all', 'active', 'past'][_tabController.index];
        _filterClients();
      });
    }
  }

  Future<void> _loadClients() async {
    setState(() => _isLoading = true);

    try {
      final clients = await _clientService.getClients(
        lawyerEmail: _lawyerEmail,
      );

      setState(() {
        _allClients = clients;
        _calculateStats();
        _filterClients();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading clients: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _calculateStats() {
    _totalClients = _allClients.length;
    _activeClients = _allClients.where((c) => c.isActive).length;
    _pastClients = _allClients.where((c) => !c.isActive).length;
  }

  void _filterClients() {
    setState(() {
      if (_currentFilter == 'all') {
        _filteredClients = _allClients;
      } else if (_currentFilter == 'active') {
        _filteredClients = _allClients.where((c) => c.isActive).toList();
      } else {
        _filteredClients = _allClients.where((c) => !c.isActive).toList();
      }
    });
  }

  void _searchClients(String query) {
    setState(() {
      if (query.isEmpty) {
        _filterClients();
      } else {
        _filteredClients = _allClients
            .where((c) =>
                c.fullName.toLowerCase().contains(query.toLowerCase()) ||
                c.recentCaseTitle.toLowerCase().contains(query.toLowerCase()))
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
                  : _buildClientsList(),
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
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: widget.onBack,
          ),
          const Expanded(
            child: Text(
              'My Clients',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_totalClients Total',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _searchClients,
        decoration: InputDecoration(
          hintText: 'Search clients by name or case...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchClients('');
                  },
                )
              : null,
          filled: true,
          fillColor: Theme.of(context).cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
        tabs: [
          Tab(text: 'All ($_totalClients)'),
          Tab(text: 'Active ($_activeClients)'),
          Tab(text: 'Past ($_pastClients)'),
        ],
      ),
    );
  }

  Widget _buildClientsList() {
    if (_filteredClients.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline,
                size: 64, color: Theme.of(context).textTheme.bodyMedium?.color),
            const SizedBox(height: 16),
            Text(
              _searchController.text.isNotEmpty
                  ? 'No clients found matching "${_searchController.text}"'
                  : 'No clients found',
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
      onRefresh: _loadClients,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _filteredClients.length,
        itemBuilder: (context, index) {
          return _buildClientCard(_filteredClients[index]);
        },
      ),
    );
  }

  Widget _buildClientCard(ClientModel client) {
    final icon = _getCaseTypeIcon(client.recentCaseType);
    final color = _getCaseTypeColor(client.recentCaseType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            client.fullName,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color:
                                  Theme.of(context).textTheme.titleLarge?.color,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: client.isActive
                                ? Colors.green.withOpacity(0.1)
                                : Theme.of(context).dividerColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            client.statusText,
                            style: TextStyle(
                              fontSize: 11,
                              color: client.isActive
                                  ? Colors.green[700]
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      client.recentCaseTitle.isNotEmpty
                          ? client.recentCaseTitle
                          : client.recentCaseType,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cases',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      client.sessionCount,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      client.isActive ? 'Last' : 'Ended',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Text(
                      client.lastDateText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _viewClientCases(client),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('View Cases'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement messaging
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Messaging feature coming soon!'),
                      ),
                    );
                  },
                  icon:
                      const Icon(Icons.message, size: 18, color: Colors.white),
                  label: const Text('Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getCaseTypeIcon(String caseType) {
    switch (caseType.toLowerCase()) {
      case 'criminal':
        return Icons.gavel;
      case 'family':
        return Icons.people;
      case 'property':
        return Icons.home;
      case 'corporate':
        return Icons.business;
      default:
        return Icons.description;
    }
  }

  Color _getCaseTypeColor(String caseType) {
    switch (caseType.toLowerCase()) {
      case 'criminal':
        return Theme.of(context).primaryColor;
      case 'family':
        return Theme.of(context).colorScheme.secondary;
      case 'property':
        return Colors.orange;
      case 'corporate':
        return Colors.purple;
      default:
        return Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    }
  }

  void _viewClientCases(ClientModel client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ClientCasesScreen(
          client: client,
          lawyerEmail: _lawyerEmail,
        ),
      ),
    );
  }
}
