import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/colors.dart';
import '../../providers/theme_provider.dart';
import '../../services/notification_service.dart';

/// ⚙️ SETTINGS SCREEN
/// App settings, preferences, and configurations
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _budgetAlertsEnabled = true;
  bool _dailyRemindersEnabled = false;
  bool _savingsAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
      _budgetAlertsEnabled = prefs.getBool('budgetAlertsEnabled') ?? true;
      _dailyRemindersEnabled = prefs.getBool('dailyRemindersEnabled') ?? false;
      _savingsAlertsEnabled = prefs.getBool('savingsAlertsEnabled') ?? true;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.settings, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Appearance Section
            _buildSectionTitle('Appearance'),
            const SizedBox(height: 12),
            _buildAppearanceCard(themeProvider),
            const SizedBox(height: 24),

            // Notifications Section
            _buildSectionTitle('Notifications'),
            const SizedBox(height: 12),
            _buildNotificationsCard(),
            const SizedBox(height: 24),

            // Data & Privacy Section
            _buildSectionTitle('Data & Privacy'),
            const SizedBox(height: 12),
            _buildDataPrivacyCard(),
            const SizedBox(height: 24),

            // About Section
            _buildSectionTitle('About'),
            const SizedBox(height: 12),
            _buildAboutCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white60,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildAppearanceCard(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Theme Mode
          _buildSwitchTile(
            'Dark Mode',
            'Use dark theme throughout the app',
            Icons.dark_mode,
            themeProvider.isDarkMode,
            (value) {
              themeProvider.toggleTheme();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // All Notifications
          _buildSwitchTile(
            'Push Notifications',
            'Receive push notifications',
            Icons.notifications,
            _notificationsEnabled,
            (value) async {
              setState(() => _notificationsEnabled = value);
              await _savePreference('notificationsEnabled', value);
              
              if (value) {
                await NotificationService().initialize();
              }
            },
          ),
          const Divider(height: 1, color: Colors.white12),
          
          // Budget Alerts
          _buildSwitchTile(
            'Budget Alerts',
            'Get notified when approaching budget limit',
            Icons.warning_amber,
            _budgetAlertsEnabled,
            _notificationsEnabled
                ? (value) async {
                    setState(() => _budgetAlertsEnabled = value);
                    await _savePreference('budgetAlertsEnabled', value);
                  }
                : null,
          ),
          const Divider(height: 1, color: Colors.white12),
          
          // Daily Reminders
          _buildSwitchTile(
            'Daily Reminders',
            'Remind to log transactions daily',
            Icons.alarm,
            _dailyRemindersEnabled,
            _notificationsEnabled
                ? (value) async {
                    setState(() => _dailyRemindersEnabled = value);
                    await _savePreference('dailyRemindersEnabled', value);
                    
                    if (value) {
                      // Schedule daily reminder at 9:00 AM
                      await NotificationService().scheduleDailyReminder(
                        hour: 9,
                        minute: 0,
                      );
                    } else {
                      await NotificationService().cancelDailyReminder();
                    }
                  }
                : null,
          ),
          const Divider(height: 1, color: Colors.white12),
          
          // Savings Milestones
          _buildSwitchTile(
            'Savings Milestones',
            'Get notified on goal progress',
            Icons.emoji_events,
            _savingsAlertsEnabled,
            _notificationsEnabled
                ? (value) async {
                    setState(() => _savingsAlertsEnabled = value);
                    await _savePreference('savingsAlertsEnabled', value);
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDataPrivacyCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            'Export All Data',
            'Download your data as PDF',
            Icons.download,
            onTap: () => _exportAllData(),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Clear Cache',
            'Free up storage space',
            Icons.cleaning_services,
            onTap: () => _clearCache(),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Privacy Policy',
            'Read our privacy policy',
            Icons.privacy_tip,
            onTap: () {},
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Terms of Service',
            'Read our terms',
            Icons.description,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildAboutCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            'App Version',
            '1.0.0',
            Icons.info_outline,
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Rate App',
            'Rate us on the store',
            Icons.star_outline,
            onTap: () {},
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Send Feedback',
            'Help us improve',
            Icons.feedback_outlined,
            onTap: () => _showFeedbackDialog(),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Contact Support',
            'Get help',
            Icons.support_agent,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool>? onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryYellow, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryYellow,
        inactiveTrackColor: Colors.white24,
      ),
    );
  }

  Widget _buildOptionTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryYellow, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontSize: 12,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.chevron_right, color: Colors.white38)
          : null,
    );
  }

  void _exportAllData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exporting your data...'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Cache?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will clear temporary data. Your account data will not be affected.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared!'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow),
            child: const Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showFeedbackDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Send Feedback', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Tell us what you think...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: AppColors.primaryNavy,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Thank you for your feedback! 💝'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow),
            child: const Text('Send', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
