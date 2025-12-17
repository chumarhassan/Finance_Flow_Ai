import 'package:flutter/material.dart';
import '../../config/colors.dart';
import '../../services/auth_services.dart';



class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms & Conditions'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signUpWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully! 🎉'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pop();
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryRose,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Sign up to start managing your finances',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.primaryRose,
                  ),
                ),

                const SizedBox(height: 40),

                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    return AuthService.validateName(value ?? '');
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
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

                const SizedBox(height: 20),

                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Create a strong password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    return AuthService.validatePassword(value ?? '');
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignup(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (value) {
                        setState(() {
                          _acceptedTerms = value ?? false;
                        });
                      },
                      activeColor: AppColors.primaryYellow,
                      checkColor: AppColors.primaryNavy,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _acceptedTerms = !_acceptedTerms;
                          });
                        },
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium,
                            children: const [
                              TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: TextStyle(
                                  color: AppColors.primaryYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                  color: AppColors.primaryYellow,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null : AppColors.yellowPinkGradient,
                      color: _isLoading ? AppColors.primaryGray.withOpacity(0.3) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primaryPink.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSignup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: AppColors.primaryRose,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}