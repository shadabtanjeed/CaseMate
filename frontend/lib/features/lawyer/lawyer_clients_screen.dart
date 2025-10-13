import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAllClientsTab(),
                  _buildActiveClientsTab(),
                  _buildPastClientsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppTheme.primaryBlue,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text('Add Client', style: TextStyle(color: Colors.white)),
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
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              '47 Total',
              style: TextStyle(
                color: Colors.white,
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
        decoration: InputDecoration(
          hintText: 'Search clients by name or case...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.borderColor),
          ),
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
          Tab(text: 'All (47)'),
          Tab(text: 'Active (28)'),
          Tab(text: 'Past (19)'),
        ],
      ),
    );
  }

  Widget _buildAllClientsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildClientCard(
          'John Mitchell',
          'Criminal Defense',
          'Active',
          '3 sessions',
          'Last: Oct 10, 2025',
          Icons.gavel,
          AppTheme.primaryBlue,
          true,
        ),
        _buildClientCard(
          'Maria Garcia',
          'Family Law - Divorce',
          'Active',
          '7 sessions',
          'Last: Oct 11, 2025',
          Icons.people,
          AppTheme.accentBlue,
          true,
        ),
        _buildClientCard(
          'David Lee',
          'Property Dispute',
          'Active',
          '2 sessions',
          'Last: Oct 9, 2025',
          Icons.home,
          Colors.orange,
          true,
        ),
        _buildClientCard(
          'Sarah Williams',
          'Contract Review',
          'Completed',
          '4 sessions',
          'Ended: Sep 28, 2025',
          Icons.description,
          AppTheme.textSecondary,
          false,
        ),
      ],
    );
  }

  Widget _buildActiveClientsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildClientCard(
          'John Mitchell',
          'Criminal Defense',
          'Active',
          '3 sessions',
          'Next: Oct 12, 10:00 AM',
          Icons.gavel,
          AppTheme.primaryBlue,
          true,
        ),
        _buildClientCard(
          'Maria Garcia',
          'Family Law - Divorce',
          'Active',
          '7 sessions',
          'Next: Oct 12, 2:00 PM',
          Icons.people,
          AppTheme.accentBlue,
          true,
        ),
      ],
    );
  }

  Widget _buildPastClientsTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildClientCard(
          'Sarah Williams',
          'Contract Review',
          'Completed',
          '4 sessions',
          'Ended: Sep 28, 2025',
          Icons.description,
          AppTheme.textSecondary,
          false,
        ),
        _buildClientCard(
          'Robert Brown',
          'Corporate Merger',
          'Completed',
          '12 sessions',
          'Ended: Sep 15, 2025',
          Icons.business,
          AppTheme.textSecondary,
          false,
        ),
      ],
    );
  }

  Widget _buildClientCard(
    String name,
    String caseType,
    String status,
    String sessions,
    String lastDate,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.borderColor),
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
                            name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive
                                ? Colors.green.withOpacity(0.1)
                                : AppTheme.borderColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              color: isActive
                                  ? Colors.green[700]
                                  : AppTheme.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      caseType,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
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
                    const Text(
                      'Sessions',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      sessions,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
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
                      isActive ? 'Next' : 'Last',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      lastDate,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
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
                  onPressed: () {},
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('View Case'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
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

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Clients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Case Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('All'), onSelected: (val) {}),
                FilterChip(label: const Text('Criminal'), onSelected: (val) {}),
                FilterChip(label: const Text('Family'), onSelected: (val) {}),
                FilterChip(
                    label: const Text('Corporate'), onSelected: (val) {}),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Status'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(label: const Text('Active'), onSelected: (val) {}),
                FilterChip(
                    label: const Text('Completed'), onSelected: (val) {}),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
