import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import 'auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = [
    OnboardingSlide(
      icon: Icons.account_balance_wallet_rounded,
      title: 'Track Your Expenses',
      description:
          'Easily monitor all your transactions and see where your money goes with beautiful visualizations.',
      gradient: AppColors.yellowPinkGradient,
    ),
    OnboardingSlide(
      icon: Icons.analytics_rounded,
      title: 'Smart AI Insights',
      description:
          'Get personalized financial advice and spending insights powered by advanced AI technology.',
      gradient: AppColors.navyPurpleGradient,
    ),
    OnboardingSlide(
      icon: Icons.savings_rounded,
      title: 'Achieve Your Goals',
      description:
          'Set financial goals and track your progress with smart recommendations to reach them faster.',
      gradient: AppColors.rosePinkGradient,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstTime', false);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _skipOnboarding() => _completeOnboarding();

  void _nextSlide() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button - Reduced top padding
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            ),

            // PageView with slides - Takes remaining space
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _slides.length,
                itemBuilder: (context, index) => _buildSlide(_slides[index]),
              ),
            ),

            // Page Indicators - Reduced spacing
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _slides.length,
                  (index) => _buildPageIndicator(index),
                ),
              ),
            ),

            // Next / Get Started Button - Reduced bottom padding
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.yellowPinkGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryYellow.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _nextSlide,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      _currentPage == _slides.length - 1
                          ? 'Get Started'
                          : 'Next',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlide(OnboardingSlide slide) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated Icon Container with Gradient
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(milliseconds: 600),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: slide.gradient,
                    borderRadius: BorderRadius.circular(35),
                    boxShadow: [
                      BoxShadow(
                        color: slide.gradient.colors.first.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    slide.icon,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 40),

          // Title with Animation
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withOpacity(0.75),
                  height: 1.6,
                  fontSize: 15,
                ),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      height: 8,
      width: isActive ? 32 : 8,
      decoration: BoxDecoration(
        gradient: isActive
            ? AppColors.yellowPinkGradient
            : null,
        color: isActive ? null : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppColors.primaryYellow.withOpacity(0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
    );
  }
}

class OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final LinearGradient gradient;

  OnboardingSlide({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
  });
}
