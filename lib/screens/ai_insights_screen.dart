import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../config/colors.dart';

// 🤖 AI INSIGHTS SCREEN - MATCHING YOUR BEAUTIFUL UI THEME
class AIInsightsScreen extends StatefulWidget {
  const AIInsightsScreen({super.key});

  @override
  State<AIInsightsScreen> createState() => _AIInsightsScreenState();
}

class _AIInsightsScreenState extends State<AIInsightsScreen> {
  String? _spendingAnalysis;
  List<String>? _savingTips;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAIInsights();
  }

  Future<void> _loadAIInsights() async {
    setState(() => _isLoading = true);

    final provider = Provider.of<TransactionProvider>(context, listen: false);

    try {
      final analysis = await provider.getSpendingAnalysis();
      final tips = await provider.getSavingTips();

      if (mounted) {
        setState(() {
          _spendingAnalysis = analysis;
          _savingTips = tips;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _spendingAnalysis = "Add transactions to get AI insights!";
          _savingTips = [
            "💰 Start tracking your expenses",
            "📊 Add at least 5 transactions for better insights",
            "🎯 Set monthly budgets for each category",
          ];
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshInsights() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.refreshAIInsights();
    await _loadAIInsights();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'AI Insights',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryYellow),
            onPressed: _isLoading ? null : _refreshInsights,
            tooltip: 'Refresh Insights',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshInsights,
        color: AppColors.primaryYellow,
        backgroundColor: AppColors.primaryPurple,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: AppColors.primaryYellow,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🤖 AI is analyzing your finances...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFinancialHealthCard(context),
                    const SizedBox(height: 16),
                    _buildSpendingAnalysisCard(context),
                    const SizedBox(height: 16),
                    _buildSavingTipsCard(context),
                    const SizedBox(height: 16),
                    _buildAIStatisticsCard(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildFinancialHealthCard(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final score = provider.financialHealthScore;
    final message = provider.financialHealthMessage;

    Color scoreColor;
    if (score >= 80) {
      scoreColor = const Color(0xFF4caf50);
    } else if (score >= 60) {
      scoreColor = AppColors.primaryYellow;
    } else if (score >= 40) {
      scoreColor = const Color(0xFFff9800);
    } else {
      scoreColor = AppColors.primaryPink;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppColors.primaryYellow,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Financial Health Score',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 160,
                  height: 160,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 14,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: scoreColor,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '/100',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: scoreColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: scoreColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpendingAnalysisCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Analysis',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _spendingAnalysis ?? 'No analysis available yet.',
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavingTipsCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4caf50), Color(0xFF66bb6a)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Smart Saving Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_savingTips != null && _savingTips!.isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _savingTips!.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNavy,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4caf50), Color(0xFF66bb6a)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _savingTips![index],
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Text(
              'No tips available yet.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAIStatisticsCard(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final aiTransactions = provider.aiSuggestedTransactions;
    final totalTransactions = provider.transactions.length;
    final aiPercentage = totalTransactions > 0
        ? (aiTransactions.length / totalTransactions * 100).toStringAsFixed(0)
        : '0';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(20),
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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: AppColors.yellowPinkGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'AI Statistics',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'AI Categorized',
                  '${aiTransactions.length}',
                  Icons.category_rounded,
                  AppColors.primaryYellow,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'AI Rate',
                  '$aiPercentage%',
                  Icons.percent_rounded,
                  AppColors.primaryPink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryNavy,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: AppColors.primaryYellow,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'AI automatically categorizes transactions to save you time!',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}