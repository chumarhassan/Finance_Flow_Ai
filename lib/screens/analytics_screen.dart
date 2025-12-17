import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../services/pdf_report_service.dart';
import '../config/colors.dart';
import '../models/transaction_model.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super. key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTimeRange = 0;
  int?  _touchedIndex;

  @override
  void initState() {
    super. initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<TransactionModel> _getFilteredTransactions(TransactionProvider provider) {
    final now = DateTime.now();
    DateTime startDate;

    switch (_selectedTimeRange) {
      case 0:
        startDate = DateTime(now.year, now.month, 1);
        break;
      case 1:
        startDate = DateTime(now.year, now. month - 2, now.day);
        break;
      case 2:
        startDate = DateTime(now.year, 1, 1);
        break;
      default:
        startDate = DateTime(now.year, now.month, 1);
    }

    final filtered = provider.getTransactionsInRange(startDate, now);

    if (kDebugMode) {
      print('Analytics: Total transactions: ${provider.transactions.length}');
      print('Analytics: Filtered transactions: ${filtered.length}');
      print('Analytics: Date range: $startDate to $now');
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildTimeRangeSelector(),
                const SizedBox(height: 16),
                _buildTabBar(),
              ],
            ),
          ),
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPieChartTab(),
                _buildLineChartTab(),
                _buildBarChartTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primaryNavy,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple. withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets. all(8),
            decoration: BoxDecoration(
              gradient: AppColors.yellowPinkGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors. primaryYellow.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
          ),
          onPressed: () => _generatePDFReport(context),
          tooltip: 'Generate PDF Report',
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisSize: MainAxisSize. min,
          children: [
            Container(
              padding: const EdgeInsets. all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons. analytics, color: Colors. white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Analytics',
              style: TextStyle(
                color: Colors. white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
      ),
    );
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTimeRangeButton('This Month', 0, Icons.calendar_today),
          _buildTimeRangeButton('3 Months', 1, Icons. date_range),
          _buildTimeRangeButton('This Year', 2, Icons.calendar_view_month),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, int index, IconData icon) {
    final isSelected = _selectedTimeRange == index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => setState(() => _selectedTimeRange = index),
            borderRadius: BorderRadius. circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
              decoration: BoxDecoration(
                gradient: isSelected ?  AppColors.yellowPinkGradient : null,
                borderRadius: BorderRadius.circular(10),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primaryYellow.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment. center,
                children: [
                  Icon(icon, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign. center,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ?  FontWeight.w700 : FontWeight. w500,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow. ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius. circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPurple.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: AppColors.yellowPinkGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryYellow.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize. tab,
        dividerColor: Colors.transparent,
        labelColor: Colors.white,
        unselectedLabelColor: Colors.white60,
        labelStyle: const TextStyle(fontWeight: FontWeight. w700, fontSize: 11),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight. w500, fontSize: 11),
        padding: const EdgeInsets.all(4),
        tabs: const [
          Tab(
            icon: Icon(Icons. pie_chart_rounded, size: 18),
            text: 'Categories',
            height: 50,
          ),
          Tab(
            icon: Icon(Icons.show_chart_rounded, size: 18),
            text: 'Trends',
            height: 50,
          ),
          Tab(
            icon: Icon(Icons. bar_chart_rounded, size: 18),
            text: 'Compare',
            height: 50,
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = _getFilteredTransactions(provider);
        final expenses = transactions.where((t) => t. isExpense).toList();

        if (expenses.isEmpty) {
          return _buildEmptyState(
            'No Expense Data',
            'Start tracking your expenses to see beautiful insights',
            Icons.pie_chart_outline_rounded,
          );
        }

        final categoryData = <String, double>{};
        for (var transaction in expenses) {
          categoryData[transaction.category] =
              (categoryData[transaction.category] ?? 0.0) + transaction.amount;
        }

        final sortedCategories = categoryData.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatsCards(provider, transactions),
              const SizedBox(height: 16),
              _buildEnhancedPieChart(sortedCategories),
              const SizedBox(height: 16),
              _buildCategoryList(sortedCategories),
            ],
          ),
        );
      },
    );
  }

 Widget _buildEnhancedPieChart(List<MapEntry<String, double>> categoryData) {
  final total = categoryData.fold(0.0, (sum, entry) => sum + entry.value);

  final colors = [
    const Color(0xFFFF6B9D),
    const Color(0xFF4ECDC4),
    const Color(0xFFFFA726),
    const Color(0xFF66BB6A),
    const Color(0xFF5C6BC0),
    const Color(0xFFAB47BC),
    const Color(0xFFEC407A),
    const Color(0xFF26C6DA),
    const Color(0xFFFFEE58),
  ];

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          AppColors.primaryPurple,
          AppColors.primaryPurple.withOpacity(0.8),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
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
        /// HEADER
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.donut_large_rounded,
                        color: AppColors.primaryYellow,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Spending by Category',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Total: \$${total.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 12), // reduced for moving chart up

        /// PIE CHART WITH SHIFT UP
        Transform.translate(
          offset: const Offset(0, -20), // moves pie chart ABOVE default position
          child: SizedBox(
            height: 240, // slightly increased height for elegance
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedIndex = -1;
                        return;
                      }
                      _touchedIndex =
                          pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                centerSpaceColor: AppColors.primaryNavy,

                sections: categoryData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final data = entry.value;
                  final percentage = (data.value / total * 100);
                  final isTouched = index == _touchedIndex;

                  final radius = isTouched ? 90.0 : 72.0;

                  return PieChartSectionData(
                    value: data.value,
                    title: percentage > 5 ? '${percentage.toStringAsFixed(1)}%' : '',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: isTouched ? 14 : 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: const [
                        Shadow(color: Colors.black, blurRadius: 4),
                      ],
                    ),
                    color: colors[index % colors.length],
                    badgeWidget:
                        isTouched ? _buildBadge(data.key, data.value) : null,
                    badgePositionPercentageOffset: 1.25,
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildBadge(String category, double amount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      constraints: const BoxConstraints(maxWidth: 120),
      decoration: BoxDecoration(
        color: AppColors. primaryNavy,
        borderRadius: BorderRadius. circular(10),
        border: Border.all(color: AppColors.primaryYellow, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.5),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize. min,
        children: [
          Text(
            category,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign. center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(
              color: AppColors.primaryYellow,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(List<MapEntry<String, double>> categoryData) {
    final total = categoryData.fold(0.0, (sum, entry) => sum + entry. value);
    final colors = [
      const Color(0xFFFF6B9D),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFA726),
      const Color(0xFF66BB6A),
      const Color(0xFF5C6BC0),
      const Color(0xFFAB47BC),
      const Color(0xFFEC407A),
      const Color(0xFF26C6DA),
      const Color(0xFFFFEE58),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets. all(6),
                decoration: BoxDecoration(
                  color: AppColors. primaryPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.format_list_bulleted_rounded,
                  color: AppColors.primaryPink,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Category Breakdown',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight. w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: categoryData. length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final entry = categoryData[index];
              final percentage = (entry.value / total * 100);

              return Container(
                padding: const EdgeInsets. all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy. withOpacity(0.6),
                  borderRadius: BorderRadius. circular(12),
                  border: Border.all(
                    color: colors[index % colors. length]. withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            colors[index % colors. length],
                            colors[index % colors.length].withOpacity(0.6),
                          ],
                        ),
                        borderRadius: BorderRadius. circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors. white,
                            fontWeight: FontWeight. w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight. w600,
                                    fontSize: 13,
                                  ),
                                  overflow: TextOverflow. ellipsis,
                                ),
                              ),
                              Text(
                                '\$${entry.value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: colors[index % colors. length],
                                  fontWeight: FontWeight. w700,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: Colors.white. withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                              FractionallySizedBox(
                                widthFactor: percentage / 100,
                                child: Container(
                                  height: 6,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colors[index % colors.length],
                                        colors[index % colors. length].withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${percentage.toStringAsFixed(1)}% of total',
                            style: TextStyle(
                              color: Colors.white. withOpacity(0.6),
                              fontSize: 10,
                              fontWeight: FontWeight. w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineChartTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = _getFilteredTransactions(provider);
        final expenses = transactions.where((t) => t.isExpense).toList();

        if (expenses.isEmpty) {
          return _buildEmptyState(
            'No Trend Data',
            'Add expenses to see your spending trends over time',
            Icons.show_chart_rounded,
          );
        }

        expenses.sort((a, b) => a.date.compareTo(b.date));

        final dailyData = <DateTime, double>{};
        for (var transaction in expenses) {
          final date = DateTime(
              transaction.date.year, transaction.date. month, transaction.date.day);
          dailyData[date] = (dailyData[date] ?? 0.0) + transaction. amount;
        }

        final sortedDates = dailyData. keys.toList().. sort();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatsCards(provider, transactions),
              const SizedBox(height: 16),
              _buildEnhancedLineChart(sortedDates, dailyData),
              const SizedBox(height: 16),
              _buildTrendInsights(sortedDates, dailyData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLineChart(List<DateTime> dates, Map<DateTime, double> data) {
    if (dates.isEmpty) return const SizedBox();

    final maxY = data.values.reduce((a, b) => a > b ? a : b) * 1.3;
    final spots = dates.asMap().entries.map((entry) {
      return FlSpot(entry.key. toDouble(), data[entry.value]!);
    }). toList();

    return Container(
      padding: const EdgeInsets. all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow. withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.primaryYellow,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Spending Trend',
                style: TextStyle(
                  color: Colors. white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Daily expense tracking',
            style: TextStyle(
              color: Colors.white. withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: maxY / 5,
                  verticalInterval: dates.length > 5 ? dates.length / 5 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '\$${value.toInt()}',
                          style: TextStyle(
                            color: Colors.white. withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight. w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: dates.length > 10 ? (dates.length / 5).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= dates.length) return const SizedBox();
                        final date = dates[value.toInt()];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormat('MMM d').format(date),
                            style: TextStyle(
                              color: Colors. white.withOpacity(0.7),
                              fontSize: 9,
                              fontWeight: FontWeight. w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: (dates.length - 1). toDouble(),
                minY: 0,
                maxY: maxY,
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.primaryNavy,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots. map((spot) {
                        final date = dates[spot.x. toInt()];
                        return LineTooltipItem(
                          '${DateFormat('MMM d').format(date)}\n\$${spot.y. toStringAsFixed(2)}',
                          const TextStyle(
                            color: AppColors.primaryYellow,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      }). toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.4,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryYellow,
                        AppColors.primaryPink,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: AppColors.primaryNavy,
                          strokeWidth: 2,
                          strokeColor: AppColors.primaryYellow,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryYellow. withOpacity(0.3),
                          AppColors.primaryPink.withOpacity(0.1),
                          Colors.transparent,
                        ],
                        begin: Alignment. topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendInsights(List<DateTime> dates, Map<DateTime, double> data) {
    if (dates.length < 2) return const SizedBox();

    final firstWeekTotal = dates.take(7).fold(0.0, (sum, date) => sum + (data[date] ??  0));
    final lastWeekTotal = dates
        .skip(dates.length > 7 ? dates.length - 7 : 0)
        .fold(0.0, (sum, date) => sum + (data[date] ?? 0));
    final avgDaily = data.values.reduce((a, b) => a + b) / dates.length;
    final change = lastWeekTotal - firstWeekTotal;
    final isIncrease = change > 0;
    final highestDay = data.entries.reduce((a, b) => a.value > b.value ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets. all(6),
                decoration: BoxDecoration(
                  color: AppColors. primaryPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: AppColors.primaryPink,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Smart Insights',
                style: TextStyle(
                  color: Colors. white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildInsightCard(
            'Average Daily Spending',
            '\$${avgDaily. toStringAsFixed(2)}',
            Icons.calendar_today_rounded,
            AppColors.primaryYellow,
            'Keeping track of your daily average',
          ),
          const SizedBox(height: 10),
          _buildInsightCard(
            'Weekly Trend',
            '${isIncrease ? '+' : ''}\$${change.abs().toStringAsFixed(2)}',
            isIncrease ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            isIncrease ? const Color(0xFFFF6B6B) : const Color(0xFF4ECDC4),
            isIncrease ? 'Spending increased this week' : 'Great!  Spending decreased',
          ),
          const SizedBox(height: 10),
          _buildInsightCard(
            'Highest Spending Day',
            '\$${highestDay.value. toStringAsFixed(2)}',
            Icons.trending_up_rounded,
            const Color(0xFFFF6B9D),
            DateFormat('MMMM d, yyyy').format(highestDay.key),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard(
      String title, String value, IconData icon, Color color, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy. withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color. withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets. all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.6)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white. withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight. w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors. white.withOpacity(0.5),
                    fontSize: 10,
                    fontWeight: FontWeight. w500,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartTab() {
    return Consumer<TransactionProvider>(
      builder: (context, provider, _) {
        final transactions = _getFilteredTransactions(provider);

        if (transactions.isEmpty) {
          return _buildEmptyState(
            'No Comparison Data',
            'Add income and expenses to compare your finances',
            Icons.bar_chart_rounded,
          );
        }

        final monthlyData = <String, Map<String, double>>{};
        for (var transaction in transactions) {
          final monthKey = DateFormat('MMM'). format(transaction.date);
          if (!monthlyData. containsKey(monthKey)) {
            monthlyData[monthKey] = {'income': 0.0, 'expense': 0.0};
          }
          if (transaction.isIncome) {
            monthlyData[monthKey]!['income'] =
                monthlyData[monthKey]! ['income']! + transaction.amount;
          } else {
            monthlyData[monthKey]!['expense'] =
                monthlyData[monthKey]! ['expense']! + transaction.amount;
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildStatsCards(provider, transactions),
              const SizedBox(height: 16),
              _buildEnhancedBarChart(monthlyData),
              const SizedBox(height: 16),
              _buildComparisonSummary(monthlyData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEnhancedBarChart(Map<String, Map<String, double>> monthlyData) {
    final months = monthlyData. keys.toList();
    final maxY = monthlyData.values. fold(0.0, (max, data) {
          final monthMax =
              [data['income'] ?? 0, data['expense'] ?? 0].reduce((a, b) => a > b ?  a : b);
          return monthMax > max ? monthMax : max;
        }) *
        1.3;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.compare_arrows_rounded,
                  color: AppColors.primaryYellow,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Income vs Expense',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Monthly comparison',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildEnhancedLegendItem('Income', const Color(0xFF66BB6A)),
              const SizedBox(width: 24),
              _buildEnhancedLegendItem('Expense', const Color(0xFFFF6B9D)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment. spaceAround,
                maxY: maxY,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => AppColors.primaryNavy,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final month = months[group.x.toInt()];
                      final type = rodIndex == 0 ? 'Income' : 'Expense';
                      return BarTooltipItem(
                        '$month\n$type: \$${rod.toY.toStringAsFixed(2)}',
                        TextStyle(
                          color: rodIndex == 0
                              ? const Color(0xFF66BB6A)
                              : const Color(0xFFFF6B9D),
                          fontWeight: FontWeight. w700,
                          fontSize: 11,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: maxY / 5,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Text(
                          '\$${value. toInt()}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= months.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            months[value.toInt()],
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 10,
                              fontWeight: FontWeight. w600,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.white.withOpacity(0.08),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                barGroups: months.asMap().entries.map((entry) {
                  final index = entry.key;
                  final month = entry.value;
                  final data = monthlyData[month]! ;

                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: data['income']!,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF66BB6A), Color(0xFF4CAF50)],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY,
                          color: Colors.white. withOpacity(0.05),
                        ),
                      ),
                      BarChartRodData(
                        toY: data['expense']!,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B9D), Color(0xFFFF1744)],
                          begin: Alignment. bottomCenter,
                          end: Alignment. topCenter,
                        ),
                        width: 14,
                        borderRadius: const BorderRadius. vertical(top: Radius.circular(4)),
                      ),
                    ],
                    barsSpace: 6,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedLegendItem(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color. withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize. min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color. withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSummary(Map<String, Map<String, double>> monthlyData) {
    final totalIncome =
        monthlyData.values.fold(0.0, (sum, data) => sum + (data['income'] ??  0));
    final totalExpense =
        monthlyData.values.fold(0.0, (sum, data) => sum + (data['expense'] ?? 0));
    final balance = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0 ? ((balance / totalIncome) * 100) : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black. withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment. start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryPink.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.assessment_rounded,
                  color: AppColors.primaryPink,
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Period Summary',
                style: TextStyle(
                  color: Colors. white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildSummaryRow(
              'Total Income', totalIncome, const Color(0xFF66BB6A), Icons.arrow_downward_rounded),
          const SizedBox(height: 10),
          _buildSummaryRow(
              'Total Expense', totalExpense, const Color(0xFFFF6B9D), Icons. arrow_upward_rounded),
          const SizedBox(height: 10),
          _buildSummaryRow(
              'Net Balance',
              balance,
              balance >= 0 ? AppColors.primaryYellow : const Color(0xFFFF6B6B),
              Icons.account_balance_wallet_rounded),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets. all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  savingsRate >= 20
                      ? const Color(0xFF66BB6A). withOpacity(0.2)
                      : AppColors.primaryYellow.withOpacity(0.2),
                  savingsRate >= 20
                      ? const Color(0xFF66BB6A).withOpacity(0.1)
                      : AppColors.primaryYellow.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: savingsRate >= 20
                    ? const Color(0xFF66BB6A).withOpacity(0.3)
                    : AppColors.primaryYellow.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        savingsRate >= 20 ? const Color(0xFF66BB6A) : AppColors.primaryYellow,
                        savingsRate >= 20
                            ? const Color(0xFF4CAF50)
                            : AppColors.primaryYellow. withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius. circular(10),
                  ),
                  child: const Icon(Icons.savings_rounded, color: Colors. white, size: 18),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Savings Rate',
                        style: TextStyle(
                          color: Colors. white,
                          fontSize: 13,
                          fontWeight: FontWeight. w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        savingsRate >= 20 ? 'Excellent savings!' : 'Keep it up!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 10,
                          fontWeight: FontWeight. w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${savingsRate. toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: savingsRate >= 20 ? const Color(0xFF66BB6A) : AppColors.primaryYellow,
                    fontSize: 22,
                    fontWeight: FontWeight. w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryNavy.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white. withOpacity(0.9),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight. w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards(TransactionProvider provider, List<TransactionModel> transactions) {
    final income = transactions.where((t) => t.isIncome).fold(0.0, (sum, t) => sum + t. amount);
    final expense = transactions.where((t) => t.isExpense). fold(0.0, (sum, t) => sum + t.amount);
    final balance = income - expense;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Income',
            '\$${income.toStringAsFixed(0)}',
            Icons.arrow_downward_rounded,
            const Color(0xFF66BB6A),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Expense',
            '\$${expense.toStringAsFixed(0)}',
            Icons. arrow_upward_rounded,
            const Color(0xFFFF6B9D),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            'Balance',
            '\$${balance. toStringAsFixed(0)}',
            Icons.account_balance_wallet_rounded,
            balance >= 0 ?  AppColors.primaryYellow : const Color(0xFFFF6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    final displayValue = value.startsWith('\$-') ? '-\$${value.substring(2)}' : value;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryPurple,
            AppColors.primaryPurple.withOpacity(0.8),
          ],
          begin: Alignment. topLeft,
          end: Alignment. bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets. all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            displayValue,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String message, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryYellow.withOpacity(0.3),
                    AppColors.primaryPink.withOpacity(0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.7),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<void> _generatePDFReport(BuildContext context) async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactions = _getFilteredTransactions(provider);

    if (transactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.warning_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'No transactions to generate report',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                shape: BoxShape.circle,
              ),
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Generating PDF Report...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait a moment',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );

    try {
      // Get date range based on selected period
      final now = DateTime.now();
      DateTime startDate;
      switch (_selectedTimeRange) {
        case 0: // Month
          startDate = DateTime(now.year, now.month, 1);
          break;
        case 1: // 3 Months
          startDate = DateTime(now.year, now.month - 2, 1);
          break;
        case 2: // Year
          startDate = DateTime(now.year, 1, 1);
          break;
        default:
          startDate = DateTime(now.year, now.month, 1);
      }

      // Generate and download the PDF
      await PDFReportService.generateAndDownloadReport(
        transactions: transactions,
        userName: authProvider.currentUser?.name ?? 'User',
        startDate: startDate,
        endDate: now,
      );

      if (context.mounted) {
        Navigator.pop(context);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    '✅ PDF Report downloaded! Check your Downloads folder.',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF66BB6A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to generate report: $e',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFFF6B6B),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }
}