import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../services/ai_service.dart';

class TransactionProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final AIService _aiService = AIService();

  List<TransactionModel> _transactions = [];
  List<TransactionModel> get transactions => _transactions;

  StreamSubscription? _transactionSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isAIProcessing = false;
  bool get isAIProcessing => _isAIProcessing;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentUserId;

  String? _cachedSpendingAnalysis;
  List<String>? _cachedSavingTips;
  DateTime? _lastAIUpdateTime;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    
    await loadTransactions();
    
    _listenToTransactions();
  }

  Future<void> loadTransactions() async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final transactions = await _firestoreService.getTransactions(_currentUserId!);
      _transactions = transactions;
      
      if (kDebugMode) {
        print('Loaded ${_transactions.length} transactions');
      }

    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Load transactions error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToTransactions() {
    if (_currentUserId == null) return;

    _transactionSubscription?.cancel();

    _transactionSubscription = _firestoreService
        .getTransactionsStream(_currentUserId!)
        .listen(
      (transactions) {
        _transactions = transactions;
        _errorMessage = null;
        
        _invalidateAICache();
        
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        if (kDebugMode) {
          print('Transaction stream error: $error');
        }
        notifyListeners();
      },
    );
  }

  Future<bool> addTransactionWithAI({
    required double amount,
    required String description,
    required String type,
    required DateTime date,
    String? manualCategory,
    String? paymentMethod,
  }) async {
    try {
      _isLoading = true;
      _isAIProcessing = true;
      _errorMessage = null;
      notifyListeners();

      String category;
      bool isAISuggested = false;

      if (manualCategory != null && manualCategory.isNotEmpty) {
        category = manualCategory;
      } else {
        category = await _aiService.categorizeTransaction(description);
        isAISuggested = true;
        
        if (kDebugMode) {
          print('AI suggested category: $category for "$description"');
        }
      }

      final transaction = TransactionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        amount: amount,
        description: description,
        category: category,
        type: type,
        date: date,
        isAISuggested: isAISuggested,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestoreService.addTransaction(transaction);
      
      _invalidateAICache();
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Add transaction with AI error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      _isAIProcessing = false;
      notifyListeners();
    }
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addTransaction(transaction);
      _invalidateAICache();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Add transaction error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateTransaction(transaction);
      _invalidateAICache();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Update transaction error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteTransaction(transactionId);
      _invalidateAICache();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Delete transaction error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> recategorizeWithAI(String transactionId) async {
    try {
      final transaction = _transactions.firstWhere((t) => t.id == transactionId);
      
      _isAIProcessing = true;
      notifyListeners();
      
      final newCategory = await _aiService.categorizeTransaction(
        transaction.description,
      );
      
      final updated = transaction.copyWith(
        category: newCategory,
        isAISuggested: true,
        updatedAt: DateTime.now(),
      );
      
      await updateTransaction(updated);
      
      return newCategory;
    } catch (e) {
      if (kDebugMode) {
        print('Recategorize error: $e');
      }
      return null;
    } finally {
      _isAIProcessing = false;
      notifyListeners();
    }
  }

  Future<String> getSpendingAnalysis({bool forceRefresh = false}) async {
    if (!forceRefresh && 
        _cachedSpendingAnalysis != null && 
        _lastAIUpdateTime != null &&
        DateTime.now().difference(_lastAIUpdateTime!) < const Duration(hours: 1)) {
      return _cachedSpendingAnalysis!;
    }

    try {
      _isAIProcessing = true;
      // Don't call notifyListeners() here - let the caller handle UI updates
      // This prevents "setState during build" errors

      final analysis = await _aiService.analyzeSpending(thisMonthTransactions);
      
      _cachedSpendingAnalysis = analysis;
      _lastAIUpdateTime = DateTime.now();
      
      return analysis;
    } catch (e) {
      if (kDebugMode) {
        print('Spending analysis error: $e');
      }
      return 'Unable to generate spending analysis at the moment.';
    } finally {
      _isAIProcessing = false;
      // Only notify at the end, not during the process
    }
  }

  Future<List<String>> getSavingTips({bool forceRefresh = false}) async {
    if (!forceRefresh && 
        _cachedSavingTips != null && 
        _lastAIUpdateTime != null &&
        DateTime.now().difference(_lastAIUpdateTime!) < const Duration(hours: 1)) {
      return _cachedSavingTips!;
    }

    try {
      _isAIProcessing = true;
      notifyListeners();

      final tips = await _aiService.generateSavingTips(thisMonthTransactions);
      
      _cachedSavingTips = tips;
      _lastAIUpdateTime = DateTime.now();
      
      return tips;
    } catch (e) {
      if (kDebugMode) {
        print('Saving tips error: $e');
      }
      return [
        'Start tracking your expenses to get personalized tips',
        'Add more transactions for better AI insights',
      ];
    } finally {
      _isAIProcessing = false;
      notifyListeners();
    }
  }

  Future<Map<String, double>> getSuggestedBudget() async {
    try {
      return await _aiService.suggestBudget(
        thisMonthTransactions,
        monthlyIncome,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Budget suggestion error: $e');
      }
      return {};
    }
  }

  int get financialHealthScore {
    return _aiService.calculateFinancialHealthScore(
      monthlyIncome,
      monthlyExpenses,
      monthlyBalance,
    );
  }

  String get financialHealthMessage {
    return _aiService.getHealthMessage(financialHealthScore);
  }

  void _invalidateAICache() {
    _cachedSpendingAnalysis = null;
    _cachedSavingTips = null;
    _lastAIUpdateTime = null;
  }

  Future<void> refreshAIInsights() async {
    await Future.wait([
      getSpendingAnalysis(forceRefresh: true),
      getSavingTips(forceRefresh: true),
    ]);
  }

  List<TransactionModel> get incomeTransactions {
    return _transactions.where((t) => t.isIncome).toList();
  }

  List<TransactionModel> get expenseTransactions {
    return _transactions.where((t) => t.isExpense).toList();
  }

  List<TransactionModel> get aiSuggestedTransactions {
    return _transactions.where((t) => t.isAISuggested).toList();
  }

  List<TransactionModel> get todayTransactions {
    return _transactions.where((t) => t.isToday).toList();
  }

  List<TransactionModel> get thisMonthTransactions {
    return _transactions.where((t) => t.isThisMonth).toList();
  }

  List<TransactionModel> getTransactionsByCategory(String category) {
    return _transactions.where((t) => t.category == category).toList();
  }

  List<TransactionModel> getTransactionsInRange(DateTime start, DateTime end) {
    return _transactions.where((t) {
      return t.date.isAfter(start.subtract(const Duration(days: 1))) &&
          t.date.isBefore(end.add(const Duration(days: 1)));
    }).toList();
  }

  double get totalIncome {
    return incomeTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double get totalExpenses {
    return expenseTransactions.fold(0.0, (sum, t) => sum + t.amount);
  }

  double get balance {
    return totalIncome - totalExpenses;
  }

  double get monthlyIncome {
    return thisMonthTransactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyExpenses {
    return thisMonthTransactions
        .where((t) => t.isExpense)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double get monthlyBalance {
    return monthlyIncome - monthlyExpenses;
  }

  double get currentBalance => balance;
  double get monthlyExpense => monthlyExpenses;

  int get transactionCount => _transactions.length;

  int get monthlyTransactionCount => thisMonthTransactions.length;

  double get averageTransactionAmount {
    if (_transactions.isEmpty) return 0.0;
    final total = _transactions.fold(0.0, (sum, t) => sum + t.amount);
    return total / _transactions.length;
  }

  Map<String, double> get categoryWiseSpending {
    final Map<String, double> categoryTotals = {};

    for (final transaction in expenseTransactions) {
      categoryTotals[transaction.category] =
          (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
    }

    return categoryTotals;
  }

  List<MapEntry<String, double>> getTopSpendingCategories({int limit = 5}) {
    final categorySpending = categoryWiseSpending;
    final sortedEntries = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).toList();
  }

  List<TransactionModel> getRecentTransactions({int limit = 10}) {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.take(limit).toList();
  }

  List<TransactionModel> searchTransactions(String query) {
    if (query.isEmpty) return _transactions;

    final lowerQuery = query.toLowerCase();
    return _transactions.where((t) {
      return t.description.toLowerCase().contains(lowerQuery) ||
          t.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _transactionSubscription?.cancel();
    super.dispose();
  }
}