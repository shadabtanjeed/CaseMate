import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';
import 'reset_password_screen.dart';

class VerifyPinScreen extends ConsumerStatefulWidget {
  final String email;

  const VerifyPinScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<VerifyPinScreen> createState() => _VerifyPinScreenState();
}

class _VerifyPinScreenState extends ConsumerState<VerifyPinScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
        (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
        (index) => FocusNode(),
  );

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  String _getPin() {
    return _pinControllers.map((c) => c.text).join();
  }

  Future<void> _verifyPin() async {
    final pin = _getPin();

    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final success = await ref.read(authProvider.notifier).verifyResetPin(
      email: widget.email,
      pin: pin,
    );

    if (success && mounted) {
      // Navigate to reset password screen with email AND pin
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => ResetPasswordScreen(
            email: widget.email,
            code: pin,
          ),
        ),
      );
    }
  }

  Future<void> _resendPin() async {
    final success = await ref.read(authProvider.notifier).requestPasswordReset(
      widget.email,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('New PIN sent to your email!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear all PIN fields
      for (var controller in _pinControllers) {
        controller.clear();
      }
      _focusNodes[0].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // Show error if any
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Colors.red,
          ),
        );
        ref.read(authProvider.notifier).clearError();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Verify PIN'),
        backgroundColor: AppTheme.background,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.pin_outlined,
                  size: 80,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(height: 24),
                Text(
                  'Enter Verification PIN',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'We sent a 6-digit PIN to',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  widget.email,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                // PIN Input Fields
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                        (index) => SizedBox(
                      width: 45,
                      child: TextFormField(
                        controller: _pinControllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          if (value.isNotEmpty && index < 5) {
                            _focusNodes[index + 1].requestFocus();
                          } else if (value.isEmpty && index > 0) {
                            _focusNodes[index - 1].requestFocus();
                          }

                          // Auto-verify when all 6 digits are entered
                          if (index == 5 && value.isNotEmpty) {
                            _verifyPin();
                          }
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _verifyPin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: authState.isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Text(
                    'Verify PIN',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Didn\'t receive the PIN? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: authState.isLoading ? null : _resendPin,
                      child: const Text(
                        'Resend',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'The PIN will expire in 15 minutes',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}