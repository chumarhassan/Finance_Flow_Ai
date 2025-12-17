import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction_model.dart';

// 🧪 TEST DATA SCREEN
// Temporary screen to test our data models and Firestore integration

class TestDataScreen extends StatelessWidget {
  const TestDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final transactionProvider = Provider.of<TransactionProvider>(context);

    // Initialize transaction provider with current user
    if (authProvider.currentUser != null && transactionProvider.transactions.isEmpty) {
      transactionProvider.initialize(authProvider.currentUser!.uid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Data Screen'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.signOut();
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'User Information',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('Name: ${authProvider.currentUser?.name ?? "N/A"}'),
                    Text('Email: ${authProvider.currentUser?.email ?? "N/A"}'),
                    Text('Currency: ${authProvider.currentUser?.currency ?? "\$"}'),
                    Text('Monthly Budget: ${authProvider.currentUser?.formattedBudget ?? "N/A"}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Add Test Transaction Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _addTestTransaction(context, authProvider, transactionProvider),
                icon: const Icon(Icons.add),
                label: const Text('Add Test Transaction'),
              ),
            ),

            const SizedBox(height: 20),

            // Statistics Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistics',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text('Total Transactions: ${transactionProvider.transactionCount}'),
                    Text('Total Income: ${authProvider.currentUser?.currency ?? "\$"}${transactionProvider.totalIncome.toStringAsFixed(2)}'),
                    Text('Total Expenses: ${authProvider.currentUser?.currency ?? "\$"}${transactionProvider.totalExpenses.toStringAsFixed(2)}'),
                    Text('Balance: ${authProvider.currentUser?.currency ?? "\$"}${transactionProvider.balance.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Transactions List
            Text(
              'Recent Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            if (transactionProvider.transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Text('No transactions yet.\nTap "Add Test Transaction" to create one!'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactionProvider.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactionProvider.transactions[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: transaction.isIncome
                            ? AppColors.success.withOpacity(0.2)
                            : AppColors.error.withOpacity(0.2),
                        child: Icon(
                          transaction.isIncome
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: transaction.isIncome
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      title: Text(transaction.description),
                      subtitle: Text('${transaction.category} • ${transaction.formattedDate}'),
                      trailing: Text(
                        '${transaction.isIncome ? "+" : "-"}${authProvider.currentUser?.currency ?? "\$"}${transaction.amount.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: transaction.isIncome
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      onLongPress: () => _deleteTransaction(context, transactionProvider, transaction.id),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Add a test transaction
  void _addTestTransaction(
      BuildContext context,
      AuthProvider authProvider,
      TransactionProvider transactionProvider,
      ) async {
    if (authProvider.currentUser == null) return;

    // Create a random test transaction
    final random = DateTime.now().millisecondsSinceEpoch % 2 == 0;
    final transaction = TransactionModel(
      id: 'trans_${DateTime.now().millisecondsSinceEpoch}',
      userId: authProvider.currentUser!.uid,
      amount: (random ? 50.0 : 25.0) + (DateTime.now().millisecondsSinceEpoch % 100),
      description: random ? 'Test Income' : 'Test Expense',
      category: random ? 'Salary' : 'Food & Dining',
      type: random ? 'income' : 'expense',
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final success = await transactionProvider.addTransaction(transaction);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Transaction added!' : 'Failed to add transaction'),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  /// Delete a transaction
  void _deleteTransaction(
      BuildContext context,
      TransactionProvider transactionProvider,
      String transactionId,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await transactionProvider.deleteTransaction(transactionId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Transaction deleted!' : 'Failed to delete'),
            backgroundColor: success ? AppColors.success : AppColors.error,
          ),
        );
      }
    }
  }
}