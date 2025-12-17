import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';
import '../models/category_model.dart';
import '../models/goal_model.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  static const String _usersCollection = 'users';
  static const String _transactionsCollection = 'transactions';
  static const String _categoriesCollection = 'categories';
  static const String _goalsCollection = 'goals';

  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transaction.id)
          .set(transaction.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add transaction: $e');
      }
      throw Exception('Failed to add transaction: ${e.toString()}');
    }
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transaction.id)
          .update(transaction.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update transaction: $e');
      }
      throw Exception('Failed to update transaction: ${e.toString()}');
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore
          .collection(_transactionsCollection)
          .doc(transactionId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete transaction: $e');
      }
      throw Exception('Failed to delete transaction: ${e.toString()}');
    }
  }

  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore
        .collection(_transactionsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      if (kDebugMode) {
        print('Stream update: ${snapshot.docs.length} transactions');
      }
      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    });
  }

  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();

      if (kDebugMode) {
        print('Loaded ${snapshot.docs.length} transactions');
      }

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting transactions: $e');
      }
      rethrow;
    }
  }

  Future<List<TransactionModel>> getTransactionsByDateRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: startDate.toIso8601String())
          .where('date', isLessThanOrEqualTo: endDate.toIso8601String())
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch transactions by date range: $e');
      }
      throw Exception('Failed to fetch transactions: ${e.toString()}');
    }
  }

  Future<List<TransactionModel>> getTransactionsByCategory({
    required String userId,
    required String category,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('category', isEqualTo: category)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch transactions by category: $e');
      }
      throw Exception('Failed to fetch transactions by category: ${e.toString()}');
    }
  }

  Future<List<TransactionModel>> getTransactionsByType({
    required String userId,
    required String type,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: type)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => TransactionModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch transactions by type: $e');
      }
      throw Exception('Failed to fetch transactions by type: ${e.toString()}');
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .set(category.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add category: $e');
      }
      throw Exception('Failed to add category: ${e.toString()}');
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(category.id)
          .update(category.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update category: $e');
      }
      throw Exception('Failed to update category: ${e.toString()}');
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore
          .collection(_categoriesCollection)
          .doc(categoryId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete category: $e');
      }
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  Stream<List<CategoryModel>> getCategoriesStream(String userId) {
    return _firestore
        .collection(_categoriesCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final userCategories = snapshot.docs
          .map((doc) => CategoryModel.fromJson(doc.data()))
          .toList();

      final allCategories = [
        ...CategoryModel.getAllDefaultCategories(),
        ...userCategories
      ];
      return allCategories;
    });
  }

  Future<void> initializeDefaultCategories(String userId) async {
    try {
      final defaultCategories = CategoryModel.getAllDefaultCategories();
      final batch = _firestore.batch();

      for (final category in defaultCategories) {
        final customCategory = category.copyWith(
          userId: userId,
          id: '${userId}_${category.id}',
        );

        final docRef = _firestore
            .collection(_categoriesCollection)
            .doc(customCategory.id);

        batch.set(docRef, customCategory.toJson());
      }

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to initialize categories: $e');
      }
      throw Exception('Failed to initialize categories: ${e.toString()}');
    }
  }

  Future<void> addGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection(_goalsCollection)
          .doc(goal.id)
          .set(goal.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add goal: $e');
      }
      throw Exception('Failed to add goal: ${e.toString()}');
    }
  }

  Future<void> updateGoal(GoalModel goal) async {
    try {
      await _firestore
          .collection(_goalsCollection)
          .doc(goal.id)
          .update(goal.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update goal: $e');
      }
      throw Exception('Failed to update goal: ${e.toString()}');
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore
          .collection(_goalsCollection)
          .doc(goalId)
          .delete();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete goal: $e');
      }
      throw Exception('Failed to delete goal: ${e.toString()}');
    }
  }

  Stream<List<GoalModel>> getGoalsStream(String userId) {
    return _firestore
        .collection(_goalsCollection)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final goals = snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .toList();
      // Sort in memory to avoid composite index requirement
      goals.sort((a, b) => a.deadline.compareTo(b.deadline));
      return goals;
    });
  }

  Future<List<GoalModel>> getActiveGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_goalsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final goals = snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .where((goal) => !goal.isCompleted)
          .toList();
      
      // Sort in memory to avoid composite index requirement
      goals.sort((a, b) => a.deadline.compareTo(b.deadline));
      return goals;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch active goals: $e');
      }
      throw Exception('Failed to fetch active goals: ${e.toString()}');
    }
  }

  Future<List<GoalModel>> getCompletedGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection(_goalsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      final goals = snapshot.docs
          .map((doc) => GoalModel.fromJson(doc.data()))
          .where((goal) => goal.isCompleted)
          .toList();
      
      // Sort in memory to avoid composite index requirement
      goals.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return goals;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch completed goals: $e');
      }
      throw Exception('Failed to fetch completed goals: ${e.toString()}');
    }
  }

  Future<void> addMoneyToGoal(String goalId, double amount) async {
    try {
      final docRef = _firestore.collection(_goalsCollection).doc(goalId);

      await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(docRef);

        if (!snapshot.exists) {
          throw Exception('Goal not found');
        }

        final goal = GoalModel.fromJson(snapshot.data()!);
        final newAmount = goal.currentAmount + amount;
        final isCompleted = newAmount >= goal.targetAmount;

        transaction.update(docRef, {
          'currentAmount': newAmount,
          'isCompleted': isCompleted,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (e) {
      if (kDebugMode) {
        print('Failed to add money to goal: $e');
      }
      throw Exception('Failed to add money to goal: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserData(String userId) async {
    try {
      final doc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!doc.exists) return null;
      return UserModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to fetch user data: $e');
      }
      throw Exception('Failed to fetch user data: ${e.toString()}');
    }
  }

  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore
          .collection(_usersCollection)
          .doc(user.uid)
          .update(user.toJson());
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update user data: $e');
      }
      throw Exception('Failed to update user data: ${e.toString()}');
    }
  }

  Stream<UserModel?> getUserDataStream(String userId) {
    return _firestore
        .collection(_usersCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return null;
      return UserModel.fromJson(snapshot.data()!);
    });
  }

  Future<double> getTotalIncome({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return transactions
          .where((t) => t.isIncome)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to calculate income: $e');
      }
      throw Exception('Failed to calculate income: ${e.toString()}');
    }
  }

  Future<double> getTotalExpenses({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      return transactions
          .where((t) => t.isExpense)
          .fold<double>(0.0, (sum, t) => sum + t.amount);
    } catch (e) {
      if (kDebugMode) {
        print('Failed to calculate expenses: $e');
      }
      throw Exception('Failed to calculate expenses: ${e.toString()}');
    }
  }

  Future<Map<String, double>> getCategoryWiseSpending({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<String, double> categoryTotals = {};

      for (final transaction in transactions) {
        if (transaction.isExpense) {
          categoryTotals[transaction.category] =
              (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
        }
      }

      return categoryTotals;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to calculate category spending: $e');
      }
      throw Exception('Failed to calculate category spending: ${e.toString()}');
    }
  }

  Future<Map<String, double>> getMonthlySpendingByCategory(String userId) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return getCategoryWiseSpending(
      userId: userId,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );
  }

  Future<int> getTransactionCount({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByDateRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
      return transactions.length;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to get transaction count: $e');
      }
      throw Exception('Failed to get transaction count: ${e.toString()}');
    }
  }

  Future<double> getAverageDailySpending({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final totalExpenses = await getTotalExpenses(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final days = endDate.difference(startDate).inDays + 1;
      return days > 0 ? totalExpenses / days : 0.0;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to calculate average spending: $e');
      }
      throw Exception('Failed to calculate average spending: ${e.toString()}');
    }
  }

  Future<void> deleteAllUserData(String userId) async {
    try {
      final batch = _firestore.batch();

      final transactions = await _firestore
          .collection(_transactionsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in transactions.docs) {
        batch.delete(doc.reference);
      }

      final categories = await _firestore
          .collection(_categoriesCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in categories.docs) {
        batch.delete(doc.reference);
      }

      final goals = await _firestore
          .collection(_goalsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in goals.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_firestore.collection(_usersCollection).doc(userId));

      await batch.commit();
    } catch (e) {
      if (kDebugMode) {
        print('Failed to delete user data: $e');
      }
      throw Exception('Failed to delete user data: ${e.toString()}');
    }
  }
}