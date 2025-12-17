

class TransactionModel {
  // Unique identifier for this transaction
  final String id;

  // ID of the user who owns this transaction
  final String userId;

  // Transaction amount (positive for income, but we use type to distinguish)
  final double amount;

  // Description/note about the transaction
  final String description;

  // Category (e.g., "Food & Dining", "Transportation")
  final String category;

  // Type: 'income' or 'expense'
  final String type;

  // When the transaction occurred
  final DateTime date;

  // Was this transaction auto-categorized by AI?
  final bool isAISuggested;

  // Optional: Payment method (cash, card, etc.)
  final String? paymentMethod;

  // Optional: Receipt image URL
  final String? receiptUrl;

  // When this transaction was created in the database
  final DateTime createdAt;

  // When this transaction was last updated
  final DateTime updatedAt;

  // Constructor
  TransactionModel({
    required this.id,
    required this.userId,
    required this.amount,
    required this.description,
    required this.category,
    required this.type,
    required this.date,
    this.isAISuggested = false,
    this.paymentMethod,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // ==================== JSON CONVERSION ====================

  /// Convert TransactionModel to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'description': description,
      'category': category,
      'type': type,
      'date': date.toIso8601String(),
      'isAISuggested': isAISuggested,
      'paymentMethod': paymentMethod,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create TransactionModel from Firestore JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      type: json['type'] ?? 'expense',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      isAISuggested: json['isAISuggested'] ?? false,
      paymentMethod: json['paymentMethod'],
      receiptUrl: json['receiptUrl'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // ==================== HELPER METHODS ====================

  /// Create a copy with updated fields
  TransactionModel copyWith({
    String? id,
    String? userId,
    double? amount,
    String? description,
    String? category,
    String? type,
    DateTime? date,
    bool? isAISuggested,
    String? paymentMethod,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      category: category ?? this.category,
      type: type ?? this.type,
      date: date ?? this.date,
      isAISuggested: isAISuggested ?? this.isAISuggested,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  /// Get formatted amount with currency symbol
  String getFormattedAmount(String currencySymbol) {
    return '$currencySymbol${amount.toStringAsFixed(2)}';
  }

  /// Get formatted date (e.g., "Jan 15, 2025")
  String get formattedDate {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Get time ago string (e.g., "2 hours ago", "3 days ago")
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if transaction is from today
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  /// Check if transaction is from this month
  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  /// Check if transaction is from this year
  bool get isThisYear {
    final now = DateTime.now();
    return date.year == now.year;
  }

  

  @override
  String toString() {
    return 'TransactionModel(id: $id, amount: $amount, type: $type, category: $category)';
  }
}