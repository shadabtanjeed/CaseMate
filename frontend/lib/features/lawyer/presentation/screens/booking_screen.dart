import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lawyer_entity.dart';
import 'payment_screen.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final LawyerEntity lawyer;
  final String selectedSlot;
  final String selectedDate;
  final VoidCallback onBookingSuccess;

  const BookingScreen({
    super.key,
    required this.lawyer,
    required this.selectedSlot,
    required this.selectedDate,
    required this.onBookingSuccess,
  });

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  String? _caseCategory;
  final TextEditingController _caseTitleController = TextEditingController();
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
    _caseTitleController.dispose();
    _caseDescriptionController.dispose();
    super.dispose();
  }

  String _formatTimeToAMPM(String time24) {
    try {
      final parts = time24.split(':');
      if (parts.length != 2) return time24;

      final hour = int.parse(parts[0]);
      final minute = parts[1];

      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

      return '$hour12:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  bool get _isComplete {
    return _caseCategory != null &&
        _caseTitleController.text.isNotEmpty &&
        _caseDescriptionController.text.isNotEmpty;
  }

  void _navigateToPayment() {
    if (!_isComplete) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PaymentScreen(
          lawyer: widget.lawyer,
          selectedSlot: widget.selectedSlot,
          selectedDate: widget.selectedDate,
          caseCategory: _caseCategory!,
          caseTitle: _caseTitleController.text,
          caseDescription: _caseDescriptionController.text,
          onBookingSuccess: widget.onBookingSuccess,
        ),
      ),
    );
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

            // Case Category section
            _buildCaseCategorySection(),
            const SizedBox(height: 24),

            // Case Title section
            _buildCaseTitleSection(),
            const SizedBox(height: 24),

            // Case Description section
            _buildCaseDescriptionSection(),
            const SizedBox(height: 32),

            // Continue to Payment button
            _buildContinueToPaymentButton(context),
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
    final formattedTime = _formatTimeToAMPM(timeSlot);

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
              formattedTime,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              Icons.attach_money,
              'Fee',
              '৳${widget.lawyer.fee}',
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

  Widget _buildCaseTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Case Title',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _caseTitleController,
          maxLines: 1,
          decoration: InputDecoration(
            hintText: 'Enter a brief title for your case...',
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

  Widget _buildContinueToPaymentButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isComplete ? _navigateToPayment : null,
        icon: const Icon(Icons.arrow_forward),
        label: const Text('Continue to Payment'),
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
