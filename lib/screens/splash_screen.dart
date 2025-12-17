import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import 'onboarding_screen.dart';
import 'auth/login_screen.dart';
import 'main_navigation_screen.dart';
import '../../services/auth_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Fade in animation (0.0 to 1.0)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Scale animation (0.5 to 1.0) - logo grows
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    // Start animation
    _animationController.forward();

    // Navigate after animation completes
    _navigateToNextScreen();
  }

  /// Determine which screen to show next
  Future<void> _navigateToNextScreen() async {
    // Wait for animation to complete (1.5 seconds)
    await Future.delayed(const Duration(milliseconds: 2000));

    // Check if this is first time opening the app
    final prefs = await SharedPreferences.getInstance();
    final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

    // Check if user is already logged in
    final bool isLoggedIn = AuthService().currentUser != null;

    if (!mounted) return;

    // Navigate based on app state
    if (isFirstTime) {
      // First time user - show onboarding
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const OnboardingScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else if (isLoggedIn) {
      // User is logged in - go to main navigation
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainNavigationScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    } else {
      // User has seen onboarding but not logged in
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 500),
        ),
      );
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryNavy,
              AppColors.primaryPurple,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          gradient: AppColors.yellowPinkGradient,
                          borderRadius: BorderRadius.circular(40),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryYellow.withOpacity(0.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 80,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 30),

                      ShaderMask(
                        shaderCallback: (bounds) => AppColors.yellowPinkGradient.createShader(bounds),
                        child: const Text(
                          'FinanceFlow',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'AI-Powered Finance Manager',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.primaryGray,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 50),

                      // Loading indicator
                      const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          strokeWidth: 3,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryYellow,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}