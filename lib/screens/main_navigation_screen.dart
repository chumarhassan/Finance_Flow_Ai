import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/goal_provider.dart';
import 'home/dashboard_screen.dart';
import 'analytics_screen.dart';
import 'goals/goals_screen.dart';
import 'profile/profile_screen.dart';
import 'ai_chatbot_screen.dart';

/// 🏠 MAIN NAVIGATION SCREEN
/// Bottom navigation bar with main app sections
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const AnalyticsScreen(),
    const GoalsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeProviders();
  }

  Future<void> _initializeProviders() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await goalProvider.initialize(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AIChatbotScreen()),
          );
        },
        backgroundColor: AppColors.primaryYellow,
        child: const Icon(Icons.smart_toy, color: AppColors.primaryNavy),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: AppColors.primaryPurple,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: EdgeInsets.zero,
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildNavItem(0, Icons.home_rounded, 'Home'),
              _buildNavItem(1, Icons.bar_chart_rounded, 'Analytics'),
              const SizedBox(width: 48), // Space for FAB
              _buildNavItem(2, Icons.flag_rounded, 'Goals'),
              _buildNavItem(3, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primaryYellow : Colors.white54,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryYellow : Colors.white54,
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
