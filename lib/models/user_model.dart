// 👤 USER MODEL
// This class represents a user in our app
// It stores all user information and handles data conversion

class UserModel {
  // User's unique ID from Firebase Authentication
  final String uid;

  // User's display name
  final String name;

  // User's email address
  final String email;

  // User's profile picture URL (optional)
  final String? profilePicture;

  // Monthly budget limit (how much they plan to spend)
  final double monthlyBudget;

  // Currency symbol (e.g., $, €, ₹)
  final String currency;

  // When the user account was created
  final DateTime createdAt;

  // When the user last updated their profile
  final DateTime updatedAt;

  // Is this user a premium member? (for future features)
  final bool isPremium;

  // Constructor - used to create a new UserModel instance
  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profilePicture,
    this.monthlyBudget = 1000.0, // Default budget
    this.currency = '\$', // Default currency
    required this.createdAt,
    required this.updatedAt,
    this.isPremium = false,
  });

  // ==================== JSON CONVERSION ====================

  /// Convert UserModel to JSON Map (for storing in Firestore)
  /// This is called when we save user data to Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profilePicture': profilePicture,
      'monthlyBudget': monthlyBudget,
      'currency': currency,
      'createdAt': createdAt.toIso8601String(), // Convert DateTime to String
      'updatedAt': updatedAt.toIso8601String(),
      'isPremium': isPremium,
    };
  }

  /// Create UserModel from JSON Map (when reading from Firestore)
  /// This is called when we fetch user data from Firebase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      monthlyBudget: (json['monthlyBudget'] ?? 1000.0).toDouble(),
      currency: json['currency'] ?? '\$',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      isPremium: json['isPremium'] ?? false,
    );
  }

  // ==================== HELPER METHODS ====================

  /// Create a copy of UserModel with some fields updated
  /// Useful when we want to update only specific fields
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profilePicture,
    double? monthlyBudget,
    String? currency,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isPremium,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      currency: currency ?? this.currency,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  /// Get user's first name only
  String get firstName {
    return name.split(' ').first;
  }

  /// Check if user has a profile picture
  bool get hasProfilePicture {
    return profilePicture != null && profilePicture!.isNotEmpty;
  }

  /// Format monthly budget with currency symbol
  String get formattedBudget {
    return '$currency${monthlyBudget.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, name: $name, email: $email)';
  }
}