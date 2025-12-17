import 'package:flutter/foundation.dart';
import 'dart:async';
import '../models/goal_model.dart';
import '../services/firestore_service.dart';

/// 🎯 GOAL PROVIDER
/// Manages savings goals state throughout the app
class GoalProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<GoalModel> _goals = [];
  List<GoalModel> get goals => _goals;

  StreamSubscription? _goalSubscription;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _currentUserId;

  // ==================== INITIALIZATION ====================

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    await loadGoals();
    _listenToGoals();
  }

  Future<void> loadGoals() async {
    if (_currentUserId == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final activeGoals = await _firestoreService.getActiveGoals(_currentUserId!);
      final completedGoals = await _firestoreService.getCompletedGoals(_currentUserId!);
      
      _goals = [...activeGoals, ...completedGoals];
      
      if (kDebugMode) {
        print('Loaded ${_goals.length} goals');
      }
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Load goals error: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _listenToGoals() {
    if (_currentUserId == null) return;

    _goalSubscription?.cancel();

    _goalSubscription = _firestoreService
        .getGoalsStream(_currentUserId!)
        .listen(
      (goals) {
        _goals = goals;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        if (kDebugMode) {
          print('Goals stream error: $error');
        }
        notifyListeners();
      },
    );
  }

  // ==================== GOAL CRUD OPERATIONS ====================

  Future<bool> addGoal({
    required String name,
    required double targetAmount,
    required DateTime deadline,
    String? description,
    String? imageUrl,
  }) async {
    if (_currentUserId == null) {
      if (kDebugMode) {
        print('❌ Cannot add goal: User not logged in');
      }
      _errorMessage = 'User not logged in';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final goal = GoalModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: _currentUserId!,
        name: name,
        targetAmount: targetAmount,
        currentAmount: 0.0,
        deadline: deadline,
        description: description,
        imageUrl: imageUrl,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (kDebugMode) {
        print('📝 Adding goal: ${goal.name} for user: $_currentUserId');
      }

      await _firestoreService.addGoal(goal);
      
      if (kDebugMode) {
        print('✅ Goal added successfully!');
      }
      
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('❌ Add goal error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateGoal(GoalModel goal) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateGoal(goal.copyWith(
        updatedAt: DateTime.now(),
      ));
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Update goal error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteGoal(String goalId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteGoal(goalId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Delete goal error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMoneyToGoal(String goalId, double amount) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.addMoneyToGoal(goalId, amount);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      if (kDebugMode) {
        print('Add money to goal error: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markGoalComplete(String goalId) async {
    try {
      final goal = _goals.firstWhere((g) => g.id == goalId);
      final updatedGoal = goal.copyWith(
        isCompleted: true,
        updatedAt: DateTime.now(),
      );
      return await updateGoal(updatedGoal);
    } catch (e) {
      if (kDebugMode) {
        print('Mark goal complete error: $e');
      }
      return false;
    }
  }

  // ==================== GETTERS ====================

  List<GoalModel> get activeGoals {
    return _goals.where((g) => !g.isCompleted).toList();
  }

  List<GoalModel> get completedGoals {
    return _goals.where((g) => g.isCompleted).toList();
  }

  List<GoalModel> get overdueGoals {
    return _goals.where((g) => g.isOverdue).toList();
  }

  List<GoalModel> get nearDeadlineGoals {
    return _goals.where((g) => !g.isCompleted && g.daysRemaining <= 7).toList();
  }

  double get totalTargetAmount {
    return _goals.fold(0.0, (sum, g) => sum + g.targetAmount);
  }

  double get totalSavedAmount {
    return _goals.fold(0.0, (sum, g) => sum + g.currentAmount);
  }

  double get overallProgress {
    if (totalTargetAmount == 0) return 0.0;
    return (totalSavedAmount / totalTargetAmount) * 100;
  }

  int get goalsCount => _goals.length;
  int get activeGoalsCount => activeGoals.length;
  int get completedGoalsCount => completedGoals.length;

  GoalModel? getGoalById(String id) {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _goalSubscription?.cancel();
    super.dispose();
  }
}
