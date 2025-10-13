import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class LawyerDiscoveryScreen extends StatefulWidget {
  final VoidCallback onBack;
  final Function(int) onSelectLawyer;

  const LawyerDiscoveryScreen({
    super.key,
    required this.onBack,
    required this.onSelectLawyer,
  });

  @override
  State<LawyerDiscoveryScreen> createState() => _LawyerDiscoveryScreenState();
}

class _LawyerDiscoveryScreenState extends State<LawyerDiscoveryScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<LawyerCard> lawyers = [
    LawyerCard(
      id: 1,
      name: 'Dr. Sarah Johnson',
      specialization: 'Criminal Law',
      rating: 4.9,
      reviews: 124,
      experience: 12,
      location: 'New York, NY',
      fee: 150,
      verified: true,
      bio:
          'Experienced criminal defense attorney with a track record of success.',
    ),
    LawyerCard(
      id: 2,
      name: 'Mr. Michael Chen',
      specialization: 'Property Law',
      rating: 4.8,
      reviews: 98,
      experience: 10,
      location: 'Los Angeles, CA',
      fee: 120,
      verified: true,
      bio: 'Specializing in real estate and property disputes.',
    ),
    LawyerCard(
      id: 3,
      name: 'Ms. Emily Rodriguez',
      specialization: 'Family Law',
      rating: 4.9,
      reviews: 156,
      experience: 15,
      location: 'Chicago, IL',
      fee: 140,
      verified: true,
      bio: 'Compassionate approach to family law matters.',
    ),
    LawyerCard(
      id: 4,
      name: 'Dr. James Williams',
      specialization: 'Corporate Law',
      rating: 4.7,
      reviews: 89,
      experience: 8,
      location: 'San Francisco, CA',
      fee: 180,
      verified: true,
      bio: 'Expert in corporate transactions and compliance.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: lawyers.length,
                itemBuilder: (context, index) {
                  return _buildLawyerCard(lawyers[index]);
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
                              child: const Row(
                                children: [
                                  Icon(Icons.verified,
                                      size: 12, color: AppTheme.primaryBlue),
                                  SizedBox(width: 4),
                                  Text(
                                    'Verified',
                                    style: TextStyle(
                                      color: AppTheme.primaryBlue,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                            '${lawyer.rating} (${lawyer.reviews} reviews)',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.work_outline,
                              size: 16,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
                          const SizedBox(width: 4),
                          Text(
                            '${lawyer.experience} years experience',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 16,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
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
                          Icon(Icons.attach_money,
                              size: 16,
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color),
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Lawyers',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            Text('Specialization',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                    value: 'criminal', child: Text('Criminal Law')),
                DropdownMenuItem(value: 'civil', child: Text('Civil Law')),
                DropdownMenuItem(value: 'family', child: Text('Family Law')),
                DropdownMenuItem(
                    value: 'property', child: Text('Property Law')),
                DropdownMenuItem(
                    value: 'corporate', child: Text('Corporate Law')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            Text('Minimum Rating',
                style: Theme.of(context).textTheme.titleMedium),
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
              onChanged: (value) {},
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
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
  final int id;
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
