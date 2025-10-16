import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lawyer_entity.dart';

class BookingScreen extends StatefulWidget {
  final LawyerEntity lawyer;
  final String selectedSlot; // Format: "YYYY-MM-DD_HH:MM"
  final String selectedDate; // Format: "16 Oct"

  const BookingScreen({
    super.key,
    required this.lawyer,
    required this.selectedSlot,
    required this.selectedDate,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  String? _consultationType; // 'chat', 'video', 'voice'
  String? _caseCategory;
  final TextEditingController _caseDescriptionController =
      TextEditingController();

  final List<String> _caseCategories = [
    'Criminal',
    'Civil',
    'Family',
    'Property',
    'Corporate',
    'Tax',
  ];

  @override
  void dispose() {
    _caseDescriptionController.dispose();
    super.dispose();
  }

  bool get _isComplete {
    return _consultationType != null &&
        _caseCategory != null &&
        _caseDescriptionController.text.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: AppTheme.primaryBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary section
            _buildSummaryCard(),
            const SizedBox(height: 24),

            // Consultation Type section
            _buildConsultationTypeSection(),
            const SizedBox(height: 24),

            // Case Category section
            _buildCaseCategorySection(),
            const SizedBox(height: 24),

            // Case Description section
            _buildCaseDescriptionSection(),
            const SizedBox(height: 32),

            // Proceed to Payment button
            _buildProceedButton(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final timeSlot = widget.selectedSlot.split('_').length > 1
        ? widget.selectedSlot.split('_')[1]
        : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Appointment Summary',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.accentBlue,
                  child: Text(
                    'SJ',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.lawyer.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        widget.lawyer.specialization,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            _buildSummaryRow(
              Icons.calendar_today,
              'Date',
              widget.selectedDate,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              Icons.access_time,
              'Time',
              timeSlot,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              Icons.attach_money,
              'Fee',
              '\$${widget.lawyer.fee} per consultation',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildConsultationTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Consultation Type',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildConsultationOption(
                'Chat',
                Icons.chat_bubble_outline,
                'chat',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConsultationOption(
                'Video Call',
                Icons.videocam_outlined,
                'video',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildConsultationOption(
                'Voice Call',
                Icons.call_outlined,
                'voice',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildConsultationOption(
    String label,
    IconData icon,
    String value,
  ) {
    final isSelected = _consultationType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _consultationType = value;
        });
      },
      child: Card(
        elevation: isSelected ? 4 : 1,
        color: isSelected ? AppTheme.primaryBlue : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : AppTheme.primaryBlue,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: isSelected ? Colors.white : AppTheme.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCaseCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Case Category',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.borderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _caseCategory,
              hint: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Select a category'),
              ),
              isExpanded: true,
              items: _caseCategories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(category),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _caseCategory = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCaseDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Case Description',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _caseDescriptionController,
          maxLines: 5,
          minLines: 5,
          decoration: InputDecoration(
            hintText: 'Describe your case briefly...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppTheme.borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: AppTheme.primaryBlue,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
          onChanged: (_) {
            setState(() {});
          },
        ),
      ],
    );
  }

  Widget _buildProceedButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isComplete
            ? () {
                // TODO: Implement payment logic
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proceeding to payment...'),
                  ),
                );
              }
            : null,
        icon: const Icon(Icons.payment),
        label: const Text('Proceed to Payment'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: AppTheme.primaryBlue,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[600],
        ),
      ),
    );
  }
}
