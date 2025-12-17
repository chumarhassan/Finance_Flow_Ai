

class GoalModel {
  final String id;

  final String userId;

  final String name;

  final double targetAmount;

  final double currentAmount;

  final DateTime deadline;

  final String? description;

  final String? imageUrl;

  final bool isCompleted;

  final DateTime createdAt;

  final DateTime updatedAt;

  GoalModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.deadline,
    this.description,
    this.imageUrl,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
  });


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'deadline': deadline.toIso8601String(),
      'description': description,
      'imageUrl': imageUrl,
      'isCompleted': isCompleted,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      targetAmount: (json['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (json['currentAmount'] ?? 0.0).toDouble(),
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'])
          : DateTime.now().add(const Duration(days: 30)),
      description: json['description'],
      imageUrl: json['imageUrl'],
      isCompleted: json['isCompleted'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }


  GoalModel copyWith({
    String? id,
    String? userId,
    String? name,
    double? targetAmount,
    double? currentAmount,
    DateTime? deadline,
    String? description,
    String? imageUrl,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      deadline: deadline ?? this.deadline,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressPercentage {
    if (targetAmount == 0) return 0.0;
    final progress = (currentAmount / targetAmount) * 100;
    return progress > 100 ? 100.0 : progress;
  }

  /// Get remaining amount to reach goal
  double get remainingAmount {
    final remaining = targetAmount - currentAmount;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Check if goal is achieved
  bool get isAchieved => currentAmount >= targetAmount;

  /// Get days remaining until deadline
  int get daysRemaining {
    final now = DateTime.now();
    final difference = deadline.difference(now);
    return difference.inDays;
  }

  /// Check if deadline has passed
  bool get isOverdue {
    return DateTime.now().isAfter(deadline) && !isCompleted;
  }

  /// Get formatted target amount with currency
  String getFormattedTarget(String currencySymbol) {
    return '$currencySymbol${targetAmount.toStringAsFixed(2)}';
  }

  /// Get formatted current amount with currency
  String getFormattedCurrent(String currencySymbol) {
    return '$currencySymbol${currentAmount.toStringAsFixed(2)}';
  }

  /// Get formatted remaining amount with currency
  String getFormattedRemaining(String currencySymbol) {
    return '$currencySymbol${remainingAmount.toStringAsFixed(2)}';
  }

  /// Get formatted deadline date
  String get formattedDeadline {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[deadline.month - 1]} ${deadline.day}, ${deadline.year}';
  }

  /// Get deadline status string
  String get deadlineStatus {
    if (isCompleted) return 'Completed';
    if (isOverdue) return 'Overdue';

    final days = daysRemaining;
    if (days == 0) return 'Due today';
    if (days == 1) return '1 day left';
    if (days < 7) return '$days days left';
    if (days < 30) {
      final weeks = (days / 7).ceil();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} left';
    }
    final months = (days / 30).ceil();
    return '$months ${months == 1 ? 'month' : 'months'} left';
  }

  /// Get motivational message based on progress
  String get motivationalMessage {
    if (isAchieved) {
      return '🎉 Goal achieved! Congratulations!';
    }

    final progress = progressPercentage;
    if (progress >= 90) {
      return '🔥 Almost there! Just a bit more!';
    } else if (progress >= 75) {
      return '💪 Great progress! Keep it up!';
    } else if (progress >= 50) {
      return '👍 Halfway there! You\'re doing great!';
    } else if (progress >= 25) {
      return '🌟 Good start! Keep saving!';
    } else if (progress > 0) {
      return '🚀 You\'ve started! Stay consistent!';
    } else {
      return '💡 Start saving today!';
    }
  }

  /// Calculate daily saving needed to reach goal
  double get dailySavingNeeded {
    if (isAchieved || isOverdue) return 0.0;
    final days = daysRemaining;
    if (days <= 0) return remainingAmount;
    return remainingAmount / days;
  }

  String getFormattedDailySaving(String currencySymbol) {
    return '$currencySymbol${dailySavingNeeded.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'GoalModel(id: $id, name: $name, progress: ${progressPercentage.toStringAsFixed(1)}%)';
  }
}