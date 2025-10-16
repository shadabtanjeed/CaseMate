import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../presentation/providers/lawyer_provider.dart';

class LawyerDiscoveryScreen extends ConsumerStatefulWidget {
  final VoidCallback onBack;
  final Function(String) onSelectLawyer;
  final String? initialSpecialization;

  const LawyerDiscoveryScreen({
    super.key,
    required this.onBack,
    required this.onSelectLawyer,
    this.initialSpecialization,
  });

  @override
  ConsumerState<LawyerDiscoveryScreen> createState() => _LawyerDiscoveryScreenState();
}

class _LawyerDiscoveryScreenState extends ConsumerState<LawyerDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedSpecialization;
  double? _selectedMinRating;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // trigger initial load — apply initial specialization filter if provided
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lawyerListNotifierProvider.notifier).search(
            specialization: widget.initialSpecialization,
          );
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Persist the incoming specialization so later filter actions include it
    if (widget.initialSpecialization != null && _selectedSpecialization == null) {
      setState(() {
        _selectedSpecialization = widget.initialSpecialization;
        // Optionally prefill the search field to show the active filter
        _searchController.text = widget.initialSpecialization!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(lawyerListNotifierProvider);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(child: Text('Error: ${state.error}'))
                      : state.lawyers.isEmpty
                          ? const Center(child: Text('No lawyers found'))
                          : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: state.lawyers.length,
                              itemBuilder: (context, index) {
                                final l = state.lawyers[index];
                                return _buildLawyerCard(
                                  LawyerCard(
                                    id: l.id,
                                    name: l.name,
                                    specialization: l.specialization,
                                    rating: l.rating,
                                    reviews: l.reviews,
                                    experience: l.experience,
                                    location: l.location,
                                    fee: l.fee,
                                    verified: l.verified,
                                    bio: l.bio,
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryBlue, AppTheme.accentBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
                  'Find Lawyers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  onSubmitted: (v) => ref.read(lawyerListNotifierProvider.notifier).search(q: v, specialization: _selectedSpecialization, minRating: _selectedMinRating),
                  decoration: InputDecoration(
                    hintText: 'Search by name or specialization...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.tune, color: AppTheme.primaryBlue),
                  onPressed: () => _showFilterSheet(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLawyerCard(LawyerCard lawyer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.accentBlue,
                  child: Text(
                    lawyer.name.split(' ').map((e) => e[0]).join(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
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
                              lawyer.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          if (lawyer.verified)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.accentBlue.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Verified',
                                style: TextStyle(
                                  color: AppTheme.primaryBlue,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lawyer.specialization,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${lawyer.rating} (${lawyer.reviews})',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '•',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${lawyer.experience} years exp.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 16, color: AppTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            lawyer.location,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '•',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(width: 12),
                          const Icon(Icons.attach_money,
                              size: 16, color: AppTheme.textSecondary),
                          Text(
                            '${lawyer.fee}/session',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        lawyer.bio,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => widget.onSelectLawyer(lawyer.id),
                    child: const Text('View Profile'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    child: const Text('Book Now'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final specAsync = ref.watch(lawyerSpecializationsProvider);

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
              'Filter Lawyers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text('Specialization'),
            const SizedBox(height: 8),
            specAsync.when(
              data: (specs) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedSpecialization,
                  items: specs
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) => setState(() => _selectedSpecialization = value),
                );
              },
              loading: () => const SizedBox(
                height: 56,
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, st) {
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: const [],
                  onChanged: (value) => _selectedSpecialization = value,
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Minimum Rating'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: '4.5', child: Text('4.5+ Stars')),
                DropdownMenuItem(value: '4.0', child: Text('4.0+ Stars')),
                DropdownMenuItem(value: '3.5', child: Text('3.5+ Stars')),
              ],
              onChanged: (value) => _selectedMinRating = value != null ? double.tryParse(value) : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // apply filters and search
                  ref.read(lawyerListNotifierProvider.notifier).search(
                    q: _searchController.text.trim().isEmpty ? null : _searchController.text.trim(),
                    specialization: _selectedSpecialization,
                    minRating: _selectedMinRating,
                  );
                  Navigator.pop(context);
                },
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LawyerCard {
  final String id;
  final String name;
  final String specialization;
  final double rating;
  final int reviews;
  final int experience;
  final String location;
  final int fee;
  final bool verified;
  final String bio;

  LawyerCard({
    required this.id,
    required this.name,
    required this.specialization,
    required this.rating,
    required this.reviews,
    required this.experience,
    required this.location,
    required this.fee,
    required this.verified,
    required this.bio,
  });
}
