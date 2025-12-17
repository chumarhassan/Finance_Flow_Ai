import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import '../ai_insights_screen.dart';
import '../ai_chatbot_screen.dart';
import '../add_transaction_screen.dart';
import '../analytics_screen.dart';
import '../profile/profile_screen.dart';
import '../transactions/transaction_list_screen.dart';

// 🏠 DASHBOARD SCREEN
// Main home screen showing financial overview, stats, and recent transactions

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  // Animation controller for number animations
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Selected month for filtering
  final DateTime _selectedMonth = DateTime.now();

  // AI tip state - to avoid calling async during build
  String _aiTip = '🤖 Loading AI insights...';
  bool _isLoadingAITip = true;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Start animation
    _animationController.forward();

    // Load transactions when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  /// Load dashboard data
  Future<void> _loadData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      // Initialize will now load data AND start listening
      await transactionProvider.initialize(authProvider.currentUser!.uid);
      
      // Load AI tip after transactions are loaded
      _loadAITip();
    }
  }

  /// Load AI spending tip - separated to avoid setState during build
  Future<void> _loadAITip() async {
    if (!mounted) return;
    
    try {
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      final analysis = await transactionProvider.getSpendingAnalysis();
      
      if (mounted) {
        setState(() {
          _aiTip = analysis;
          _isLoadingAITip = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiTip = '💡 Keep tracking your expenses for personalized insights!';
          _isLoadingAITip = false;
        });
      }
    }
  }

  /// Handle pull to refresh
  Future<void> _handleRefresh() async {
    await _loadData();
    _animationController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primaryYellow,
          backgroundColor: AppColors.primaryPurple,
          child: CustomScrollView(
            slivers: [
              // App Bar with greeting
              _buildAppBar(authProvider),

              // Main content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Top Section: Balance Card
                      _buildBalanceCard(transactionProvider),

                      const SizedBox(height: 24),

                      // Middle Section: Stats Cards
                      _buildStatsSection(transactionProvider),

                      const SizedBox(height: 24),

                      // AI Smart Tip Card
                      _buildAITipCard(),

                      const SizedBox(height: 24),

                      // Recent Transactions Section
                      _buildRecentTransactionsSection(transactionProvider),

                      const SizedBox(height: 24),

                      // Quick Action Buttons
                      _buildQuickActions(),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build app bar with greeting
  Widget _buildAppBar(AuthProvider authProvider) {
    final hour = DateTime.now().hour;
    String greeting;
    IconData greetingIcon;

    if (hour < 12) {
      greeting = 'Good Morning';
      greetingIcon = Icons.wb_sunny_rounded;
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
      greetingIcon = Icons.wb_sunny_outlined;
    } else {
      greeting = 'Good Evening';
      greetingIcon = Icons.nightlight_round;
    }

    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primaryNavy,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(greetingIcon, color: AppColors.primaryYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            authProvider.currentUser?.name ?? 'User',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        // Notifications button
        // AI Insights button
        IconButton(
    icon: const Icon(Icons.analytics, color: AppColors.primaryYellow),
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AnalyticsScreen()),
      );
    },
    tooltip: 'Analytics',
  ),
IconButton(
  icon: Icon(Icons.lightbulb_outline, color: AppColors.primaryYellow),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AIInsightsScreen()),
    );
  },
  tooltip: 'AI Insights',
),
        // Profile button
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryPink,
              child: Text(
                authProvider.currentUser?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Build balance card with gradient
  Widget _buildBalanceCard(TransactionProvider transactionProvider) {
    final balance = transactionProvider.currentBalance;
    final income = transactionProvider.monthlyIncome;
    final expense = transactionProvider.monthlyExpense;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: AppColors.yellowPinkGradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryYellow.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Month selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Text(
                        DateFormat('MMM yyyy').format(_selectedMonth),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today, color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Animated balance amount
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: balance),
              duration: const Duration(milliseconds: 1000),
              builder: (context, value, child) {
                return Text(
                  '\$${value.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1,
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Income and Expense row
            Row(
              children: [
                // Income
                Expanded(
                  child: _buildBalanceItem(
                    icon: Icons.arrow_downward_rounded,
                    label: 'Income',
                    amount: income,
                    isIncome: true,
                  ),
                ),

                const SizedBox(width: 16),

                // Expense
                Expanded(
                  child: _buildBalanceItem(
                    icon: Icons.arrow_upward_rounded,
                    label: 'Expense',
                    amount: expense,
                    isIncome: false,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Build small income/expense item
  Widget _buildBalanceItem({
    required IconData icon,
    required String label,
    required double amount,
    required bool isIncome,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build stats section with quick stats
  Widget _buildStatsSection(TransactionProvider transactionProvider) {
    final transactionCount = transactionProvider.transactions.length;
    final avgSpending = transactionProvider.monthlyExpense / 30;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Transaction count card
          Expanded(
            child: _buildStatCard(
              icon: Icons.receipt_long_rounded,
              label: 'Transactions',
              value: transactionCount.toString(),
              color: AppColors.primaryPurple,
            ),
          ),

          const SizedBox(width: 12),

          // Average spending card
          Expanded(
            child: _buildStatCard(
              icon: Icons.trending_down_rounded,
              label: 'Avg/Day',
              value: '\$${avgSpending.toStringAsFixed(0)}',
              color: AppColors.primaryRose,
            ),
          ),
        ],
      ),
    );
  }

  /// Build individual stat card
  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Build AI Smart Tip Card with REAL AI
  Widget _buildAITipCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AIChatbotScreen()),
          );
        },
        onLongPress: () {
          // Refresh AI tip on long press
          setState(() {
            _isLoadingAITip = true;
            _aiTip = '🤖 Refreshing AI insights...';
          });
          _loadAITip();
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.navyPurpleGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryPurple.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoadingAITip
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryYellow),
                        ),
                      )
                    : const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primaryYellow,
                        size: 24,
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'AI Smart Tip',
                          style: TextStyle(
                            color: AppColors.primaryYellow,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to chat →',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _aiTip,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build recent transactions section
  Widget _buildRecentTransactionsSection(TransactionProvider transactionProvider) {
    final recentTransactions = transactionProvider.transactions.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TransactionListScreen()),
                  );
                },
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: AppColors.primaryYellow,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Transaction list or empty state
        if (transactionProvider.isLoading)
          _buildLoadingShimmer()
        else if (recentTransactions.isEmpty)
          _buildEmptyState()
        else
          ...recentTransactions.map((transaction) => _buildTransactionItem(transaction)),
      ],
    );
  }

  /// Build single transaction item
  Widget _buildTransactionItem(TransactionModel transaction) {
    final isExpense = transaction.type == 'expense';
    final color = isExpense ? AppColors.error : AppColors.success;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryPurple,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryYellow.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: AppColors.primaryYellow,
                size: 24,
              ),
            ),

            const SizedBox(width: 16),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        transaction.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '•',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd').format(transaction.date),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Amount
            Text(
              '${isExpense ? '-' : '+'}\$${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading shimmer effect
  Widget _buildLoadingShimmer() {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Shimmer.fromColors(
            baseColor: AppColors.primaryPurple.withOpacity(0.5),
            highlightColor: AppColors.primaryPurple.withOpacity(0.7),
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryYellow.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 48,
              color: AppColors.primaryYellow,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Transactions Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your expenses by adding your first transaction!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick action buttons
  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Add Income button
          Expanded(
            child: _buildActionButton(
              label: 'Add Income',
              icon: Icons.add_circle_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF4caf50), Color(0xFF66bb6a)],
              ),
              onTap: () {
                // TODO: Navigate to add income
                _showAddTransactionDialog('income');
              },
            ),
          ),

          const SizedBox(width: 12),

          // Add Expense button
          Expanded(
            child: _buildActionButton(
              label: 'Add Expense',
              icon: Icons.remove_circle_rounded,
              gradient: const LinearGradient(
                colors: [AppColors.primaryPink, AppColors.primaryYellow],
              ),
              onTap: () {
                // TODO: Navigate to add expense
                _showAddTransactionDialog('expense');
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Build action button
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddTransactionDialog(String type) async {
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => AddTransactionScreen(type: type),
    ),
  );
  
  // Force reload
  await _loadData();
  
  // Debug print
  final transactionProvider = Provider.of<TransactionProvider>(context, listen: false);
  print('Total transactions: ${transactionProvider.transactions.length}');
  print('Balance: ${transactionProvider.currentBalance}');
}

  /// Get category icon based on category name
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food & dining':
      case 'food':
        return Icons.restaurant_rounded;
      case 'transportation':
        return Icons.directions_car_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'bills & utilities':
      case 'bills':
        return Icons.receipt_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'healthcare':
        return Icons.local_hospital_rounded;
      case 'education':
        return Icons.school_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  
}
