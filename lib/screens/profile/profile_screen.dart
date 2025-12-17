import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';
import 'settings_screen.dart';

/// 👤 PROFILE SCREEN
/// User profile management with stats and settings
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final user = authProvider.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: AppColors.primaryNavy,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person_off, size: 64, color: Colors.white38),
              const SizedBox(height: 16),
              const Text(
                'Not logged in',
                style: TextStyle(color: Colors.white54, fontSize: 18),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryYellow,
                ),
                child: const Text('Login', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primaryNavy,
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
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.settings, color: Colors.white, size: 20),
                ),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryPurple,
                      AppColors.primaryNavy,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      _buildProfileAvatar(user),
                      const SizedBox(height: 12),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Stats
                  _buildQuickStats(transactionProvider),
                  const SizedBox(height: 24),

                  // Account Info
                  _buildSectionTitle('Account Information'),
                  const SizedBox(height: 12),
                  _buildInfoCard(user),
                  const SizedBox(height: 24),

                  // Profile Options
                  _buildSectionTitle('Profile Options'),
                  const SizedBox(height: 12),
                  _buildOptionsList(context, authProvider),
                  const SizedBox(height: 24),

                  // Danger Zone
                  _buildSectionTitle('Account Actions'),
                  const SizedBox(height: 12),
                  _buildDangerZone(context, authProvider),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel user) {
    return GestureDetector(
      onTap: () => _showProfilePictureOptions(),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: AppColors.yellowPinkGradient,
              shape: BoxShape.circle,
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primaryPurple,
              backgroundImage: user.hasProfilePicture
                  ? NetworkImage(user.profilePicture!)
                  : null,
              child: !user.hasProfilePicture
                  ? Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryNavy, width: 3),
              ),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(TransactionProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.yellowPinkGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Transactions',
            provider.transactionCount.toString(),
            Icons.receipt_long,
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white24,
          ),
          _buildStatItem(
            'This Month',
            provider.monthlyTransactionCount.toString(),
            Icons.calendar_month,
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.white24,
          ),
          _buildStatItem(
            'Balance',
            '\$${provider.currentBalance.toStringAsFixed(0)}',
            Icons.account_balance_wallet,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildInfoCard(UserModel user) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoTile(
            'Full Name',
            user.name,
            Icons.person,
            onTap: () => _showEditNameDialog(user),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildInfoTile(
            'Email',
            user.email,
            Icons.email,
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildInfoTile(
            'Monthly Budget',
            user.formattedBudget,
            Icons.account_balance_wallet,
            onTap: () => _showEditBudgetDialog(user),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildInfoTile(
            'Currency',
            user.currency,
            Icons.currency_exchange,
            onTap: () => _showCurrencyPicker(user),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildInfoTile(
            'Member Since',
            _formatDate(user.createdAt),
            Icons.calendar_today,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value, IconData icon, {VoidCallback? onTap}) {
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
        label,
        style: const TextStyle(
          color: Colors.white60,
          fontSize: 12,
        ),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: onTap != null
          ? const Icon(Icons.edit, color: Colors.white38, size: 18)
          : null,
    );
  }

  Widget _buildOptionsList(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            'Edit Profile',
            Icons.edit,
            AppColors.primaryYellow,
            onTap: () => _showEditProfileDialog(),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Change Password',
            Icons.lock,
            const Color(0xFF2196F3),
            onTap: () => _showChangePasswordDialog(),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Export Data',
            Icons.download,
            const Color(0xFF4CAF50),
            onTap: () => _exportData(),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Privacy & Security',
            Icons.security,
            AppColors.primaryPurple,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
    );
  }

  Widget _buildDangerZone(BuildContext context, AuthProvider authProvider) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildOptionTile(
            'Logout',
            Icons.logout,
            AppColors.primaryPink,
            onTap: () => _showLogoutDialog(context, authProvider),
          ),
          const Divider(height: 1, color: Colors.white12),
          _buildOptionTile(
            'Delete Account',
            Icons.delete_forever,
            Colors.red,
            onTap: () => _showDeleteAccountDialog(context, authProvider),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPictureOption(
                  'Camera',
                  Icons.camera_alt,
                  () async {
                    final image = await _picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      // TODO: Upload to Firebase Storage
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildPictureOption(
                  'Gallery',
                  Icons.photo_library,
                  () async {
                    final image = await _picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      // TODO: Upload to Firebase Storage
                      Navigator.pop(context);
                    }
                  },
                ),
                _buildPictureOption(
                  'Remove',
                  Icons.delete,
                  () {
                    // TODO: Remove profile picture
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildPictureOption(String label, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.primaryYellow, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _showEditNameDialog(UserModel user) {
    final controller = TextEditingController(text: user.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Name', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
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
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final updatedUser = user.copyWith(
                name: controller.text,
                updatedAt: DateTime.now(),
              );
              await authProvider.updateUserProfile(updatedUser);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditBudgetDialog(UserModel user) {
    final controller = TextEditingController(text: user.monthlyBudget.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Budget', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            prefixText: '\$ ',
            prefixStyle: const TextStyle(color: Colors.white),
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
            onPressed: () async {
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final updatedUser = user.copyWith(
                monthlyBudget: double.parse(controller.text),
                updatedAt: DateTime.now(),
              );
              await authProvider.updateUserProfile(updatedUser);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(UserModel user) {
    final currencies = ['\$', '€', '£', '¥', '₹', '₽', 'R', 'CHF'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Currency',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: currencies.map((currency) {
                final isSelected = user.currency == currency;
                return GestureDetector(
                  onTap: () async {
                    final authProvider = Provider.of<AuthProvider>(context, listen: false);
                    final updatedUser = user.copyWith(
                      currency: currency,
                      updatedAt: DateTime.now(),
                    );
                    await authProvider.updateUserProfile(updatedUser);
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryYellow
                          : AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(12),
                      border: isSelected
                          ? null
                          : Border.all(color: Colors.white24),
                    ),
                    child: Center(
                      child: Text(
                        currency,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    // Navigate to full profile edit screen or show comprehensive dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Edit profile coming soon!')),
    );
  }

  void _showChangePasswordDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent!')),
    );
  }

  void _exportData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Exporting data...')),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Logout?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Account?', style: TextStyle(color: Colors.red)),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              await authProvider.deleteAccount();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
