import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sslcommerz/model/SSLCCustomerInfoInitializer.dart';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCTransactionInfoModel.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/lawyer_entity.dart';
import '../../../booking/presentation/providers/appointment_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final LawyerEntity lawyer;
  final String selectedSlot;
  final String selectedDate;
  final String caseCategory;
  final String caseTitle;
  final String caseDescription;
  final VoidCallback onBookingSuccess;

  const PaymentScreen({
    super.key,
    required this.lawyer,
    required this.selectedSlot,
    required this.selectedDate,
    required this.caseCategory,
    required this.caseTitle,
    required this.caseDescription,
    required this.onBookingSuccess,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isLoading = false;
  String _selectedPaymentMethod = 'sslcommerz';

  // SSLCommerz Configuration - Load from environment variables
  late final String _storeId;
  late final String _storePassword;

  @override
  void initState() {
    super.initState();
    // Load credentials from .env file
    _storeId = dotenv.env['SSLCOMMERZ_STORE_ID'] ?? '';
    _storePassword = dotenv.env['SSLCOMMERZ_STORE_PASSWORD'] ?? '';

    // Optional: Validate that credentials are loaded
    if (_storeId.isEmpty || _storePassword.isEmpty) {
      debugPrint('Warning: SSLCommerz credentials not found in .env file');
    }
  }

  // Generate unique transaction ID
  String _generateTransactionId() {
    return 'TXN${DateTime.now().millisecondsSinceEpoch}';
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

  Future<void> _initiateSSLCommerzPayment() async {
    // Validate credentials before proceeding
    if (_storeId.isEmpty || _storePassword.isEmpty) {
      _showErrorDialog('Payment configuration error. Please contact support.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get user details from auth provider
      final authState = ref.read(authProvider);
      final user = authState.user;
      final userEmail = user?.email ?? 'user@example.com';
      final userName = user?.fullName ?? 'User';
      final userPhone = user?.phone ?? '01700000000';

      // Calculate payment amount (lawyer's fee)
      final amount = widget.lawyer.fee.toDouble();

      // Initialize SSLCommerz
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          ipn_url: "https://abdhrubo.com/ipn",
          currency: SSLCurrencyType.BDT,
          product_category: "Legal Consultation",
          sdkType:
              SSLCSdkType.TESTBOX, // Change to SSLCSdkType.LIVE for production
          store_id: _storeId,
          store_passwd: _storePassword,
          total_amount: amount,
          tran_id: _generateTransactionId(),
        ),
      );

      // Add customer information
      sslcommerz.addCustomerInfoInitializer(
        customerInfoInitializer: SSLCCustomerInfoInitializer(
          customerName: userName,
          customerEmail: userEmail,
          customerAddress1: "Dhaka",
          customerCity: "Dhaka",
          customerPostCode: "1000",
          customerCountry: "Bangladesh",
          customerPhone: userPhone,
          customerState: "Dhaka",
        ),
      );

      // Start payment
      SSLCTransactionInfoModel result = await sslcommerz.payNow();

      setState(() => _isLoading = false);

      // Handle payment result
      _handlePaymentResult(result);
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Payment initialization failed: ${e.toString()}');
    }
  }

  void _handlePaymentResult(SSLCTransactionInfoModel result) {
    final status = result.status?.toUpperCase() ?? '';

    switch (status) {
      case "VALID":
      case "VALIDATED":
      case "SUCCESS":
        // Payment successful, proceed to book appointment
        _bookAppointmentAfterPayment(result);
        break;
      case "FAILED":
        Fluttertoast.showToast(
          msg: "Payment Failed",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
        );
        break;
      case "CLOSED":
        Fluttertoast.showToast(
          msg: "Payment Cancelled",
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          gravity: ToastGravity.CENTER,
        );
        break;
      default:
        _showErrorDialog("Payment status: ${result.status}");
    }
  }

  Future<void> _bookAppointmentAfterPayment(
      SSLCTransactionInfoModel paymentResult) async {
    setState(() => _isLoading = true);

    try {
      // Get user email from auth provider
      final authState = ref.read(authProvider);
      var userEmail = authState.user?.email;

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

      // Step 1: Create appointment
      final repository = ref.read(appointmentRepositoryProvider);
      final appointmentResult = await repository.createAppointment(
        lawyerEmail: widget.lawyer.email ?? 'lawyer@example.com',
        userEmail: userEmail,
        date: widget.selectedDate,
        startTime: startTime,
        endTime: endTime,
        caseType: widget.caseCategory,
        caseTitle: widget.caseTitle,
        description: widget.caseDescription,
        consultationType: 'video',
      );

      if (appointmentResult['success'] != true) {
        _showErrorDialog(
            appointmentResult['message'] ?? 'Failed to create appointment');
        return;
      }

      // Get appointment ID from response
      final appointmentId = appointmentResult['appointment']?['appointment_id'];

      if (appointmentId == null) {
        _showErrorDialog('Failed to get appointment ID');
        return;
      }

      // Step 2: Create transaction (which will auto-credit wallets)
      final transactionResult = await repository.createTransaction(
        appointmentId: appointmentId,
        userPaidAmount: widget.lawyer.fee.toDouble(),
        transactionId: paymentResult.tranId,
        paymentMethod: 'SSLCommerz',
      );

      if (transactionResult['success'] == true) {
        _showSuccessDialog(paymentResult);
      } else {
        // Appointment created but transaction failed
        // Show partial success message
        _showErrorDialog(
            'Appointment created but payment recording failed. Please contact support with transaction ID: ${paymentResult.tranId}');
      }
    } catch (e) {
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog(SSLCTransactionInfoModel paymentResult) {
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
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Payment of ৳${paymentResult.amount} successful.\nYour appointment with ${widget.lawyer.name} has been confirmed.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Transaction ID: ${paymentResult.tranId}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.textSecondary,
                  fontStyle: FontStyle.italic,
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
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Close payment screen
                  Navigator.of(context).pop(); // Close booking screen
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
                'Error',
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
    final timeSlot = widget.selectedSlot.split('_').length > 1
        ? widget.selectedSlot.split('_')[1]
        : '';
    final formattedTime = _formatTimeToAMPM(timeSlot);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
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
                  // Payment Summary Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Payment Summary',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.accentBlue,
                                child: Text(
                                  'SJ',
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.white),
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
                            Icons.category,
                            'Case Type',
                            widget.caseCategory,
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total Amount',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '৳${widget.lawyer.fee}',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Method Selection
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SSLCommerz Option
                  Card(
                    child: RadioListTile<String>(
                      value: 'sslcommerz',
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        setState(() {
                          _selectedPaymentMethod = value!;
                        });
                      },
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.credit_card,
                              color: AppTheme.primaryBlue,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'SSLCommerz',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'Pay with card, mobile banking & more',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      activeColor: AppTheme.primaryBlue,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pay Now Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _selectedPaymentMethod == 'sslcommerz'
                          ? _initiateSSLCommerzPayment
                          : null,
                      icon: const Icon(Icons.payment),
                      label: Text('Pay ৳${widget.lawyer.fee}'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        disabledForegroundColor: Colors.grey[600],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Security Info
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your payment is secure and encrypted',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
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
}
