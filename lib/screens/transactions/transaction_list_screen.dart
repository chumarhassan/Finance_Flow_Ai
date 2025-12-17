import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';
import 'transaction_details_screen.dart';
import '../add_transaction_screen.dart';

/// 📋 TRANSACTION LIST SCREEN
/// View all transactions with filtering and search
class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  String _searchQuery = '';
  String _sortBy = 'date';
  bool _sortDescending = true;

  final List<String> _categories = [
    'All',
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Groceries',
    'Personal Care',
    'Investments',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<TransactionModel> _filterAndSort(List<TransactionModel> transactions) {
    var filtered = transactions;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((t) {
        return t.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            t.category.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((t) => t.category == _selectedCategory).toList();
    }

    // Sort
    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'amount':
          comparison = a.amount.compareTo(b.amount);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'date':
        default:
          comparison = a.date.compareTo(b.date);
      }
      return _sortDescending ? -comparison : comparison;
    });

    return filtered;
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
              child: const Icon(Icons.receipt_long, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text(
              'Transactions',
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
            icon: const Icon(Icons.sort, color: AppColors.primaryYellow),
            onPressed: () => _showSortOptions(),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.primaryYellow),
            onPressed: () => _showFilterOptions(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryYellow,
          indicatorWeight: 3,
          labelColor: AppColors.primaryYellow,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                decoration: InputDecoration(
                  hintText: 'Search transactions...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: AppColors.primaryYellow),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),

          // Category Filter Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedCategory = selected ? category : 'All');
                    },
                    backgroundColor: AppColors.primaryPurple,
                    selectedColor: AppColors.primaryYellow,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    checkmarkColor: Colors.white,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Transaction List
          Expanded(
            child: Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionList(_filterAndSort(provider.transactions)),
                    _buildTransactionList(_filterAndSort(provider.incomeTransactions)),
                    _buildTransactionList(_filterAndSort(provider.expenseTransactions)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTransactionOptions(),
        backgroundColor: AppColors.primaryYellow,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildTransactionList(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: Colors.white.withOpacity(0.2),
            ),
            const SizedBox(height: 16),
            const Text(
              'No transactions found',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try adjusting your filters',
              style: TextStyle(color: Colors.white38),
            ),
          ],
        ),
      );
    }

    // Group transactions by date
    final Map<String, List<TransactionModel>> groupedTransactions = {};
    for (final transaction in transactions) {
      final dateKey = DateFormat('MMMM dd, yyyy').format(transaction.date);
      groupedTransactions.putIfAbsent(dateKey, () => []);
      groupedTransactions[dateKey]!.add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final dayTransactions = groupedTransactions[dateKey]!;
        
        final dayTotal = dayTransactions.fold(0.0, (sum, t) {
          return t.isIncome ? sum + t.amount : sum - t.amount;
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${dayTotal >= 0 ? '+' : ''}\$${dayTotal.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: dayTotal >= 0
                          ? const Color(0xFF4CAF50)
                          : AppColors.primaryPink,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            // Transactions for this day
            ...dayTransactions.map((t) => _buildTransactionCard(t)),
          ],
        );
      },
    );
  }

  Widget _buildTransactionCard(TransactionModel transaction) {
    final isIncome = transaction.isIncome;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryPurple,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TransactionDetailsScreen(transaction: transaction),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Category Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isIncome
                        ? const Color(0xFF4CAF50).withOpacity(0.2)
                        : AppColors.primaryPink.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(transaction.category),
                    color: isIncome
                        ? const Color(0xFF4CAF50)
                        : AppColors.primaryPink,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Description & Category
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.description,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            transaction.category,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                          if (transaction.isAISuggested) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryYellow.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    color: AppColors.primaryYellow,
                                    size: 10,
                                  ),
                                  SizedBox(width: 2),
                                  Text(
                                    'AI',
                                    style: TextStyle(
                                      color: AppColors.primaryYellow,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}\$${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: isIncome
                            ? const Color(0xFF4CAF50)
                            : AppColors.primaryPink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('HH:mm').format(transaction.date),
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
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

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food & Dining':
        return Icons.restaurant;
      case 'Transportation':
        return Icons.directions_car;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills & Utilities':
        return Icons.receipt_long;
      case 'Healthcare':
        return Icons.local_hospital;
      case 'Education':
        return Icons.school;
      case 'Travel':
        return Icons.flight;
      case 'Groceries':
        return Icons.local_grocery_store;
      case 'Personal Care':
        return Icons.spa;
      case 'Investments':
        return Icons.trending_up;
      case 'Salary':
        return Icons.work;
      case 'Freelance':
        return Icons.laptop;
      default:
        return Icons.category;
    }
  }

  void _showSortOptions() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sort By',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            _buildSortOption('Date', 'date'),
            _buildSortOption('Amount', 'amount'),
            _buildSortOption('Category', 'category'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _sortDescending = true);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _sortDescending
                            ? AppColors.primaryYellow
                            : AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Descending',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _sortDescending = false);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_sortDescending
                            ? AppColors.primaryYellow
                            : AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text(
                          'Ascending',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSortOption(String label, String value) {
    final isSelected = _sortBy == value;
    return ListTile(
      onTap: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
      leading: Radio<String>(
        value: value,
        groupValue: _sortBy,
        onChanged: (v) {
          setState(() => _sortBy = v!);
          Navigator.pop(context);
        },
        activeColor: AppColors.primaryYellow,
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.primaryYellow : Colors.white,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }

  void _showFilterOptions() {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter by Category',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() => _selectedCategory = 'All');
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppColors.primaryYellow),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _categories.map((category) {
                final isSelected = _selectedCategory == category;
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedCategory = category);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryYellow
                          : AppColors.primaryPurple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionOptions() {
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
              'Add Transaction',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(type: 'income'),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.5)),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.arrow_downward,
                            color: Color(0xFF4CAF50),
                            size: 40,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Income',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddTransactionScreen(type: 'expense'),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.primaryPink.withOpacity(0.5)),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.arrow_upward,
                            color: AppColors.primaryPink,
                            size: 40,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Expense',
                            style: TextStyle(
                              color: AppColors.primaryPink,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
