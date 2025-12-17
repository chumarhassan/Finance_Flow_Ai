import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/auth_services.dart';



class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.resetPassword(_emailController.text);

      if (!mounted) return;

      setState(() {
        _emailSent = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent! Check your inbox.'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _emailSent ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  /// Build form view for entering email
  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          // Icon
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 50,
                color: AppColors.primaryNavy,
              ),
            ),
          ),

          const SizedBox(height: 30),

          // Title
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primaryNavy,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Enter your email address and we\'ll send you a link to reset your password.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.textSecondaryLight,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 40),

          // Email field
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleResetPassword(),
            decoration: InputDecoration(
              labelText: 'Email Address',
              hintText: 'Enter your email',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!AuthService.isEmailValid(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),

          const SizedBox(height: 30),

          // Reset password button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: AppColors.primaryNavy,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryNavy,
                  ),
                ),
              )
                  : const Text(
                'Send Reset Link',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Back to login link
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Back to Login',
                style: TextStyle(
                  color: AppColors.primaryNavy,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build success view after email is sent
  Widget _buildSuccessView() {
    return Column(
      children: [
        const SizedBox(height: 40),

        // Success icon
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 60,
            color: AppColors.success,
          ),
        ),

        const SizedBox(height: 30),

        // Title
        Text(
          'Email Sent!',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primaryNavy,
          ),
        ),

        const SizedBox(height: 16),

        // Message
        Text(
          'We\'ve sent a password reset link to',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.textSecondaryLight,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        Text(
          _emailController.text,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.primaryNavy,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        Text(
          'Please check your email and click on the reset link to create a new password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondaryLight,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 40),

        // Resend button
        OutlinedButton(
          onPressed: _handleResetPassword,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryNavy,
            side: const BorderSide(color: AppColors.primaryNavy),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Resend Email'),
        ),

        const SizedBox(height: 20),

        // Back to login
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Back to Login',
            style: TextStyle(
              color: AppColors.primaryNavy,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}