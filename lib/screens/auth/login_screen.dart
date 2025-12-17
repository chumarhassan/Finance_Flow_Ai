import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../config/colors.dart';
import '../../services/auth_services.dart';
import 'signup_screen.dart';
import 'forgot_password_screen.dart';
import '../main_navigation_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final _authService = AuthService();

  bool _isLoading = false;

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToSignup() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SignupScreen()),
    );
  }

  void _navigateToForgotPassword() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      await _authService.signInWithGoogle();

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainNavigationScreen(),
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
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: AppColors.yellowPinkGradient,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryRose,
                        decorationColor: AppColors.primaryRose,
                        fontSize: 32,
                      ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Login to continue managing your finances',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.primaryRose.withOpacity(0.7),
                        decorationColor: AppColors.primaryRose,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                ),

                const SizedBox(height: 40),

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
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // Forgot password link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _navigateToForgotPassword,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppColors.primaryRose,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.primaryRose,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: _isLoading ? null : AppColors.yellowPinkGradient,
                      color:
                          _isLoading ? AppColors.primaryGray.withOpacity(0.3) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _isLoading
                          ? null
                          : [
                              BoxShadow(
                                color: AppColors.primaryYellow.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
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
                              'Login',
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
                  children: [
                    const Expanded(child: Divider(thickness: 1.5)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'OR',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.primaryRose.withOpacity(0.6),
                              decorationColor: AppColors.primaryRose,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                      ),
                    ),
                    const Expanded(child: Divider(thickness: 1.5)),
                  ],
                ),

                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _handleGoogleSignIn,
                    icon: const FaIcon(
                      FontAwesomeIcons.google,
                      color: AppColors.primaryRose,
                      size: 22,
                    ),
                    label: const Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryRose,
                        decorationColor: AppColors.primaryRose,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: AppColors.primaryNavy.withOpacity(0.3),
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.primaryRose.withOpacity(0.7),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            decorationColor: AppColors.primaryRose,
                          ),
                    ),
                    TextButton(
                      onPressed: _navigateToSignup,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                          color: AppColors.primaryRose,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          decorationColor: AppColors.primaryRose,
                          decorationThickness: 2,
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