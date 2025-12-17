import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/colors.dart';
import '../../providers/transaction_provider.dart';
import '../../models/transaction_model.dart';

/// 📄 TRANSACTION DETAILS SCREEN
/// View and manage individual transaction details
class TransactionDetailsScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionDetailsScreen({
    super.key,
    required this.transaction,
  });

  @override
  State<TransactionDetailsScreen> createState() => _TransactionDetailsScreenState();
}

class _TransactionDetailsScreenState extends State<TransactionDetailsScreen> {
  late TransactionModel _transaction;
  bool _isEditing = false;
  
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  String? _selectedCategory;
  DateTime? _selectedDate;

  final List<String> _categories = [
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
    _transaction = widget.transaction;
    _initControllers();
  }

  void _initControllers() {
    _amountController = TextEditingController(text: _transaction.amount.toString());
    _descriptionController = TextEditingController(text: _transaction.description);
    _selectedCategory = _transaction.category;
    _selectedDate = _transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = _transaction.isIncome;

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
        title: const Text(
          'Transaction Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (!_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryYellow),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.primaryPink),
              onPressed: () => _showDeleteDialog(),
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white54),
              onPressed: () {
                setState(() => _isEditing = false);
                _initControllers();
              },
            ),
            IconButton(
              icon: const Icon(Icons.check, color: Color(0xFF4CAF50)),
              onPressed: () => _saveChanges(),
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Amount Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isIncome
                    ? const LinearGradient(
                        colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      )
                    : AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isIncome
                            ? const Color(0xFF4CAF50)
                            : AppColors.primaryYellow)
                        .withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isIncome
                            ? Icons.arrow_downward_rounded
                            : Icons.arrow_upward_rounded,
                        color: Colors.white70,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isIncome ? 'Income' : 'Expense',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_isEditing)
                    TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                        border: InputBorder.none,
                      ),
                    )
                  else
                    Text(
                      '\$${_transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Details Card
            Container(
              decoration: BoxDecoration(
                color: AppColors.primaryPurple,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Description
                  _buildDetailItem(
                    'Description',
                    _transaction.description,
                    Icons.description,
                    isEditable: _isEditing,
                    editWidget: TextField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter description',
                        hintStyle: TextStyle(color: Colors.white38),
                      ),
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),

                  // Category
                  _buildDetailItem(
                    'Category',
                    _transaction.category,
                    _getCategoryIcon(_transaction.category),
                    isEditable: _isEditing,
                    onTap: _isEditing ? () => _showCategoryPicker() : null,
                    editWidget: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _selectedCategory ?? _transaction.category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),

                  // Date
                  _buildDetailItem(
                    'Date',
                    DateFormat('EEEE, MMMM dd, yyyy').format(_transaction.date),
                    Icons.calendar_today,
                    isEditable: _isEditing,
                    onTap: _isEditing ? () => _showDatePicker() : null,
                    editWidget: Row(
                      children: [
                        Expanded(
                          child: Text(
                            DateFormat('MMMM dd, yyyy').format(_selectedDate ?? _transaction.date),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Colors.white12),

                  // Time
                  _buildDetailItem(
                    'Time',
                    DateFormat('HH:mm').format(_transaction.date),
                    Icons.access_time,
                  ),
                  const Divider(height: 1, color: Colors.white12),

                  // Type
                  _buildDetailItem(
                    'Type',
                    _transaction.type.toUpperCase(),
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    valueColor: isIncome ? const Color(0xFF4CAF50) : AppColors.primaryPink,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // AI Info Card
            if (_transaction.isAISuggested)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryYellow.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primaryYellow.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.primaryYellow,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Categorized',
                            style: TextStyle(
                              color: AppColors.primaryYellow,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'This transaction was automatically categorized by AI',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),

            // Meta Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryPurple.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Transaction Info',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMetaRow('ID', _transaction.id),
                  _buildMetaRow('Created', DateFormat('MMM dd, yyyy HH:mm').format(_transaction.createdAt)),
                  _buildMetaRow('Updated', DateFormat('MMM dd, yyyy HH:mm').format(_transaction.updatedAt)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Recategorize Button
            if (!_isEditing)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _recategorizeWithAI(),
                  icon: const Icon(Icons.auto_awesome, color: AppColors.primaryYellow),
                  label: const Text(
                    'Recategorize with AI',
                    style: TextStyle(color: AppColors.primaryYellow),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: AppColors.primaryYellow),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
    bool isEditable = false,
    Widget? editWidget,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.primaryYellow.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppColors.primaryYellow, size: 20),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white54,
          fontSize: 12,
        ),
      ),
      subtitle: isEditable && editWidget != null
          ? editWidget
          : Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
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
      default:
        return Icons.category;
    }
  }

  void _showCategoryPicker() {
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
              'Select Category',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getCategoryIcon(category),
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          category,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? _transaction.date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveChanges() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    final updatedTransaction = _transaction.copyWith(
      amount: double.parse(_amountController.text),
      description: _descriptionController.text,
      category: _selectedCategory,
      date: _selectedDate,
      updatedAt: DateTime.now(),
    );

    final success = await provider.updateTransaction(updatedTransaction);

    if (success && mounted) {
      setState(() {
        _transaction = updatedTransaction;
        _isEditing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaction updated! ✅'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Transaction?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This action cannot be undone.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<TransactionProvider>(context, listen: false);
              await provider.deleteTransaction(_transaction.id);
              if (context.mounted) {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction deleted')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPink),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _recategorizeWithAI() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('🤖 AI is analyzing...')),
    );

    final newCategory = await provider.recategorizeWithAI(_transaction.id);

    if (newCategory != null && mounted) {
      setState(() {
        _transaction = _transaction.copyWith(
          category: newCategory,
          isAISuggested: true,
        );
        _selectedCategory = newCategory;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recategorized to: $newCategory ✨'),
          backgroundColor: const Color(0xFF4CAF50),
        ),
      );
    }
  }
}
