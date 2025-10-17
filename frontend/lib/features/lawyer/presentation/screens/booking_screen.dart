import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lawyer_entity.dart';
import '../../../booking/presentation/providers/appointment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

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
  final TextEditingController _caseDescriptionController =
      TextEditingController();
  bool _isLoading = false;

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
    return _caseCategory != null && _caseDescriptionController.text.isNotEmpty;
  }

  Future<void> _bookAppointment() async {
    if (!_isComplete) return;

    setState(() => _isLoading = true);

    try {
      // Get user email from auth provider
      final authState = ref.read(authProvider);
      var userEmail = authState.user?.email;

      // Fallback to placeholder if not available
      if (userEmail == null || userEmail.isEmpty) {
        userEmail = 'user@example.com';
      }

      // Extract time from selectedSlot
      final timeSlot = widget.selectedSlot.contains('_')
          ? widget.selectedSlot.split('_').last
          : '09:00';

      // Calculate end time (1 hour later)
      final startTime = timeSlot;
      final hour = int.parse(startTime.split(':')[0]);
      final minute = startTime.split(':')[1];
      final endHour = (hour + 1).toString().padLeft(2, '0');
      final endTime = '$endHour:$minute';

      // Create appointment data
      final appointmentData = {
        'lawyer_email': widget.lawyer.email ?? 'lawyer@example.com',
        'user_email': userEmail,
        'date': widget.selectedDate,
        'start_time': startTime,
        'end_time': endTime,
        'case_type': _caseCategory ?? '',
        'description': _caseDescriptionController.text,
        'consultation_type': 'video',
      };

      // Call the repository to create appointment
      final repository = ref.read(appointmentRepositoryProvider);
      final result = await repository.createAppointment(
        lawyerEmail: appointmentData['lawyer_email'] as String,
        userEmail: appointmentData['user_email'] as String,
        date: appointmentData['date'] as String,
        startTime: appointmentData['start_time'] as String,
        endTime: appointmentData['end_time'] as String,
        caseType: appointmentData['case_type'] as String,
        description: appointmentData['description'] as String,
        consultationType: appointmentData['consultation_type'] as String,
      );

      if (result['success'] == true) {
        _showSuccessDialog();
      } else {
        _showErrorDialog(result['message'] ?? 'Failed to create appointment');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryBlue,
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 32,
            ),
          ),
          titlePadding: const EdgeInsets.only(top: 16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Appointment Booked!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your appointment with ${widget.lawyer.name} has been successfully booked.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Close the dialog first
                  Navigator.of(context).pop();
                  // Then pop the booking screen
                  Navigator.of(context).pop();
                  // Finally trigger the callback to go home
                  widget.onBookingSuccess();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Back to Home'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 8),
              Text(
                'Booking Failed',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'OK',
                style: TextStyle(color: AppTheme.primaryBlue),
              ),
            ),
          ],
        );
      },
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            )
          : SingleChildScrollView(
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

                  // Case Description section
                  _buildCaseDescriptionSection(),
                  const SizedBox(height: 32),

                  // Book Now button
                  _buildBookNowButton(context),
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

  Widget _buildBookNowButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isComplete ? _bookAppointment : null,
        icon: const Icon(Icons.book_online),
        label: const Text('Book Now'),
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
