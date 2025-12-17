import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../providers/auth_provider.dart';
import '../config/colors.dart';
import '../models/transaction_model.dart';

class AddTransactionScreen extends StatefulWidget {
  final String type; // 'income' or 'expense'

  const AddTransactionScreen({
    super.key,
    required this.type,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;

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
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please select a category')),
            ],
          ),
          backgroundColor: AppColors.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final transactionProvider =
        Provider.of<TransactionProvider>(context, listen: false);

    if (authProvider.currentUser == null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final amount = double.parse(_amountController.text);

    // Create transaction directly
    final transaction = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: authProvider.currentUser!.uid,
      amount: amount,
      description: _descriptionController.text.trim(),
      category: _selectedCategory!,
      type: widget.type,
      date: _selectedDate,
      isAISuggested: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await transactionProvider.addTransaction(transaction);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                widget.type == 'income'
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: Colors.white,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${widget.type == 'income' ? 'Income' : 'Expense'} added successfully! 🎉',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: widget.type == 'income'
              ? const Color(0xFF4caf50)
              : AppColors.primaryPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  transactionProvider.errorMessage ?? 'Failed to add transaction',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = widget.type == 'income';

    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Add ${isIncome ? 'Income' : 'Expense'}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Amount Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: isIncome
                      ? const LinearGradient(
                          colors: [Color(0xFF4caf50), Color(0xFF66bb6a)],
                        )
                      : AppColors.yellowPinkGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: (isIncome
                              ? const Color(0xFF4caf50)
                              : AppColors.primaryYellow)
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Amount',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _amountController,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -2,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                        ),
                        border: InputBorder.none,
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          color: Colors.white54,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Invalid amount';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Description
              Text(
                'Description',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
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
                child: TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'e.g., Coffee at Starbucks',
                    hintStyle: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(18),
                    prefixIcon: Icon(
                      Icons.edit_note_rounded,
                      color: AppColors.primaryYellow,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter description';
                    }
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Category
              Text(
                'Category',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((category) {
                  final isSelected = _selectedCategory == category;
                  return InkWell(
                    onTap: () => setState(() => _selectedCategory = category),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppColors.yellowPinkGradient
                            : null,
                        color: isSelected ? null : AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryYellow.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.white.withOpacity(0.8),
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 28),

              // Date
              Text(
                'Date',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2020),
                    lastDate: DateTime.now(),
                    builder: (context, child) {
                      return Theme(
                        data: ThemeData.dark().copyWith(
                          colorScheme: ColorScheme.dark(
                            primary: AppColors.primaryYellow,
                            surface: AppColors.primaryPurple,
                            onSurface: Colors.white,
                          ),
                          dialogBackgroundColor: AppColors.primaryPurple,
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
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
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primaryYellow,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('MMMM dd, yyyy').format(_selectedDate),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isIncome
                        ? const Color(0xFF4caf50)
                        : AppColors.primaryPink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    shadowColor: (isIncome
                            ? const Color(0xFF4caf50)
                            : AppColors.primaryPink)
                        .withOpacity(0.5),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isIncome
                                  ? Icons.add_circle_rounded
                                  : Icons.remove_circle_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Add ${isIncome ? 'Income' : 'Expense'}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Info text
              Center(
                child: Text(
                  'Transaction will be saved to your account',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}