import 'package:flutter/material.dart';
import '../config/colors.dart';


class CategoryModel {
  final String id;

  final String? userId;

  final String name;

  final IconData icon;

  final Color color;

  final double? monthlyBudget;

  final bool isDefault;

  final String type;

  final DateTime createdAt;

  CategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.icon,
    required this.color,
    this.monthlyBudget,
    this.isDefault = false,
    this.type = 'expense',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'monthlyBudget': monthlyBudget,
      'isDefault': isDefault,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      userId: json['userId'],
      name: json['name'] ?? 'Other',
      icon: IconData(
        json['iconCodePoint'] ?? Icons.category.codePoint,
        fontFamily: 'MaterialIcons',
      ),
      color: Color(json['colorValue'] ?? AppColors.primaryGray.value),
      monthlyBudget: json['monthlyBudget']?.toDouble(),
      isDefault: json['isDefault'] ?? false,
      type: json['type'] ?? 'expense',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  CategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    IconData? icon,
    Color? color,
    double? monthlyBudget,
    bool? isDefault,
    String? type,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get hasBudget => monthlyBudget != null && monthlyBudget! > 0;

  String getFormattedBudget(String currencySymbol) {
    if (!hasBudget) return 'No budget set';
    return '$currencySymbol${monthlyBudget!.toStringAsFixed(2)}';
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, type: $type)';
  }

  static List<CategoryModel> getDefaultExpenseCategories() {
    final now = DateTime.now();

    return [
      CategoryModel(
        id: 'default_food',
        name: 'Food & Dining',
        icon: Icons.restaurant_rounded,
        color: AppColors.primaryRose,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_transport',
        name: 'Transportation',
        icon: Icons.directions_car_rounded,
        color: AppColors.primaryPurple,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_shopping',
        name: 'Shopping',
        icon: Icons.shopping_bag_rounded,
        color: AppColors.primaryPink,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_bills',
        name: 'Bills & Utilities',
        icon: Icons.receipt_long_rounded,
        color: AppColors.primaryNavy,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_entertainment',
        name: 'Entertainment',
        icon: Icons.movie_rounded,
        color: AppColors.primaryYellow,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_healthcare',
        name: 'Healthcare',
        icon: Icons.local_hospital_rounded,
        color: AppColors.primaryGray,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_education',
        name: 'Education',
        icon: Icons.school_rounded,
        color: AppColors.primaryPurple,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_other',
        name: 'Other',
        icon: Icons.more_horiz_rounded,
        color: AppColors.primaryGray,
        isDefault: true,
        type: 'expense',
        createdAt: now,
      ),
    ];
  }

  static List<CategoryModel> getDefaultIncomeCategories() {
    final now = DateTime.now();

    return [
      CategoryModel(
        id: 'default_salary',
        name: 'Salary',
        icon: Icons.work_rounded,
        color: AppColors.success,
        isDefault: true,
        type: 'income',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_freelance',
        name: 'Freelance',
        icon: Icons.laptop_rounded,
        color: AppColors.primaryYellow,
        isDefault: true,
        type: 'income',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_business',
        name: 'Business',
        icon: Icons.business_rounded,
        color: AppColors.primaryPurple,
        isDefault: true,
        type: 'income',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_investment',
        name: 'Investment',
        icon: Icons.trending_up_rounded,
        color: AppColors.success,
        isDefault: true,
        type: 'income',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_gift',
        name: 'Gift',
        icon: Icons.card_giftcard_rounded,
        color: AppColors.primaryPink,
        isDefault: true,
        type: 'income',
        createdAt: now,
      ),
      CategoryModel(
        id: 'default_other_income',
        name: 'Other Income',
        icon: Icons.attach_money_rounded,
        color: AppColors.success,
        isDefault: true,
        type: 'income',
        createdAt: now,
      ),
    ];
  }

  static List<CategoryModel> getAllDefaultCategories() {
    return [
      ...getDefaultExpenseCategories(),
      ...getDefaultIncomeCategories(),
    ];
  }
}