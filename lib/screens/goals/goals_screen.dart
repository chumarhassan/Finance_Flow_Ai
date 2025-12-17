import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../providers/goal_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/goal_model.dart';

/// 🎯 GOALS SCREEN
/// Track savings goals with progress visualization
class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGoals();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadGoals() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final goalProvider = Provider.of<GoalProvider>(context, listen: false);
    
    if (authProvider.currentUser != null) {
      await goalProvider.initialize(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Icon(Icons.flag_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Savings Goals',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
            onPressed: () => _showAddGoalDialog(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          indicatorWeight: 3,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Active', icon: Icon(Icons.trending_up, size: 20)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle, size: 20)),
          ],
        ),
      ),
      body: Consumer<GoalProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryYellow),
            );
          }

          return Column(
            children: [
              _buildOverallProgress(provider),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGoalsList(provider.activeGoals, false),
                    _buildGoalsList(provider.completedGoals, true),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildOverallProgress(GoalProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.yellowPinkGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryYellow.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Overall Progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${provider.overallProgress.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.flag, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      '${provider.activeGoalsCount} Active',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: provider.overallProgress / 100,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Saved: \$${provider.totalSavedAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Target: \$${provider.totalTargetAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsList(List<GoalModel> goals, bool isCompleted) {
    if (goals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCompleted ? Icons.emoji_events : Icons.flag_outlined,
              size: 60,
              color: Colors.white24,
            ),
            const SizedBox(height: 12),
            Text(
              isCompleted ? 'No completed goals yet' : 'No active goals',
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!isCompleted) ...[
              const SizedBox(height: 8),
              const Text(
                'Tap + to create your first goal!',
                style: TextStyle(color: Colors.white38),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGoals,
      color: AppColors.primaryYellow,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: goals.length,
        itemBuilder: (context, index) => _buildGoalCard(goals[index]),
      ),
    );
  }

  Widget _buildGoalCard(GoalModel goal) {
    final progress = goal.progressPercentage;
    
    Color progressColor;
    if (goal.isCompleted) {
      progressColor = const Color(0xFF4CAF50);
    } else if (goal.isOverdue) {
      progressColor = AppColors.primaryPink;
    } else if (progress >= 75) {
      progressColor = const Color(0xFF4CAF50);
    } else if (progress >= 50) {
      progressColor = AppColors.primaryYellow;
    } else {
      progressColor = AppColors.primaryPurple;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showGoalDetails(goal),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        goal.isCompleted
                            ? Icons.emoji_events
                            : Icons.savings_rounded,
                        color: progressColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal.deadlineStatus,
                            style: TextStyle(
                              color: goal.isOverdue
                                  ? AppColors.primaryPink
                                  : Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!goal.isCompleted)
                      IconButton(
                        onPressed: () => _showAddMoneyDialog(goal),
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.yellowPinkGradient,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 20),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${goal.currentAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: progressColor,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'of \$${goal.targetAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress / 100,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              progressColor,
                              progressColor.withOpacity(0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: progressColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${progress.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: progressColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Text(
                      goal.motivationalMessage,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context) {
    final nameController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(days: 30));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: const BoxDecoration(
            color: AppColors.primaryNavy,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Create New Goal 🎯',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  controller: nameController,
                  label: 'Goal Name',
                  hint: 'e.g., New Laptop, Vacation',
                  icon: Icons.flag,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: amountController,
                  label: 'Target Amount',
                  hint: 'Enter target amount',
                  icon: Icons.attach_money,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: descriptionController,
                  label: 'Description (Optional)',
                  hint: 'Add a note',
                  icon: Icons.note,
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                      builder: (context, child) {
                        return Theme(
                          data: ThemeData.dark().copyWith(
                            colorScheme: const ColorScheme.dark(
                              primary: AppColors.primaryYellow,
                              surface: AppColors.primaryPurple,
                            ),
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      setModalState(() => selectedDate = picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, color: AppColors.primaryYellow),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Target Date',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(selectedDate),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty || amountController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill in all required fields')),
                        );
                        return;
                      }

                      final provider = Provider.of<GoalProvider>(context, listen: false);
                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                      
                      // Ensure provider is initialized with user ID
                      if (authProvider.currentUser != null) {
                        await provider.initialize(authProvider.currentUser!.uid);
                      } else {
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please log in to create goals'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                        return;
                      }
                      
                      final success = await provider.addGoal(
                        name: nameController.text,
                        targetAmount: double.parse(amountController.text),
                        deadline: selectedDate,
                        description: descriptionController.text.isNotEmpty
                            ? descriptionController.text
                            : null,
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Goal created successfully! 🎉'),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create goal: ${provider.errorMessage ?? "Unknown error"}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryYellow,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Create Goal',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(color: Colors.white60),
          hintStyle: const TextStyle(color: Colors.white38),
          prefixIcon: Icon(icon, color: AppColors.primaryYellow),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }

  void _showAddMoneyDialog(GoalModel goal) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Add Money 💰',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add savings to "${goal.name}"',
              style: const TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Amount',
                labelStyle: const TextStyle(color: Colors.white60),
                prefixIcon: const Icon(Icons.attach_money, color: AppColors.primaryYellow),
                filled: true,
                fillColor: AppColors.primaryNavy,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (amountController.text.isEmpty) return;

              final provider = Provider.of<GoalProvider>(context, listen: false);
              final success = await provider.addMoneyToGoal(
                goal.id,
                double.parse(amountController.text),
              );

              if (success && context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Money added! Keep going! 🚀'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryYellow,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showGoalDetails(GoalModel goal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.primaryNavy,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: AppColors.yellowPinkGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.flag, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      goal.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              if (goal.description != null) ...[
                const SizedBox(height: 12),
                Text(
                  goal.description!,
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              ],
              const SizedBox(height: 16),
              _buildDetailRow('Target', '\$${goal.targetAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Saved', '\$${goal.currentAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Remaining', '\$${goal.remainingAmount.toStringAsFixed(2)}'),
              _buildDetailRow('Progress', '${goal.progressPercentage.toStringAsFixed(1)}%'),
              _buildDetailRow('Deadline', goal.formattedDeadline),
              _buildDetailRow('Status', goal.deadlineStatus),
              const SizedBox(height: 16),
              if (!goal.isCompleted) ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _showAddMoneyDialog(goal);
                        },
                        icon: const Icon(Icons.add, color: Colors.white, size: 18),
                        label: const Text('Add Money', style: TextStyle(color: Colors.white, fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryYellow,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () async {
                        final provider = Provider.of<GoalProvider>(context, listen: false);
                        await provider.deleteGoal(goal.id);
                        if (context.mounted) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Goal deleted')),
                          );
                        }
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete, color: AppColors.primaryPink, size: 20),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
