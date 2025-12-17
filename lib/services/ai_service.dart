import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

class AIService {
  // TODO: Replace with your Groq API key from https://console.groq.com/
  // Get your free API key at: https://console.groq.com/keys
  static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  
  AIService._internal() 
  {
    if (kDebugMode) {
      print('Groq AI initialized');
    }
  }

  static const List<String> categories = [
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

  Future<String> _callGroqAPI(String prompt, {int maxTokens = 500}) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'max_tokens': maxTokens,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final result = data['choices'][0]['message']['content'] as String;
        return result.trim();
      } else {
        if (kDebugMode) {
          print('Groq API Error: ${response.statusCode} - ${response.body}');
        }
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('🚨 Groq API Call Failed: $e');
        if (e.toString().contains('SocketException') || 
            e.toString().contains('ClientException') ||
            e.toString().contains('ERR_NAME_NOT_RESOLVED')) {
          print('💡 Network issue detected - Check your internet connection');
        }
      }
      rethrow;
    }
  }

  Future<String> categorizeTransaction(String description) async {
    try {
      if (description.isEmpty) return 'Other';

      final prompt = '''
Categorize this transaction into ONE of these categories ONLY:
${categories.join(', ')}

Transaction: "$description"

Rules:
- Return ONLY the category name, nothing else
- No explanation, just the category
- If unsure, use "Other"

Category:''';

      final category = await _callGroqAPI(prompt, maxTokens: 20);

      if (categories.contains(category)) {
        if (kDebugMode) {
          print('AI Categorized "$description" as: $category');
        }
        return category;
      }

      for (final validCategory in categories) {
        if (category.toLowerCase().contains(validCategory.toLowerCase()) ||
            validCategory.toLowerCase().contains(category.toLowerCase())) {
          return validCategory;
        }
      }

      return 'Other';
    } catch (e) {
      if (kDebugMode) {
        print('Categorization error: $e');
      }
      return 'Other';
    }
  }

  Future<String> analyzeSpending(List<TransactionModel> transactions) async {
    try {
      if (transactions.isEmpty) {
        return 'No transactions to analyze yet. Start adding your expenses to get personalized insights!';
      }

      final expenses = transactions.where((t) => t.type == 'expense').toList();
      final income = transactions.where((t) => t.type == 'income').toList();
      
      if (expenses.isEmpty) {
        return 'Add some expenses to get AI-powered insights about your spending!';
      }
      
      final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
      final totalIncome = income.fold(0.0, (sum, t) => sum + t.amount);
      
      final Map<String, double> categoryTotals = {};
      for (final transaction in expenses) {
        categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
      }
      
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final categoryBreakdown = sortedCategories
          .take(5)
          .map((e) => '- ${e.key}: \$${e.value.toStringAsFixed(2)} (${((e.value / totalExpense) * 100).toStringAsFixed(1)}%)')
          .join('\n');

      final prompt = '''
You are a personal finance advisor. Analyze this spending data and provide helpful advice.

Financial Summary:
- Total Income: \$${totalIncome.toStringAsFixed(2)}
- Total Expenses: \$${totalExpense.toStringAsFixed(2)}
- Balance: \$${(totalIncome - totalExpense).toStringAsFixed(2)}
- Transactions: ${transactions.length}

Top Spending Categories:
$categoryBreakdown

Provide a brief analysis in 3-4 sentences:
1. Highlight biggest spending area
2. Comment on income vs expense ratio
3. Give ONE actionable tip
4. Be encouraging

Keep it concise and friendly.''';

      final analysis = await _callGroqAPI(prompt, maxTokens: 300);
      
      if (kDebugMode) {
        print('AI Analysis Generated');
      }
      
      return analysis;
      
    } catch (e) {
      if (kDebugMode) {
        print('Spending analysis error: $e');
      }
      
      final expenses = transactions.where((t) => t.type == 'expense').toList();
      final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
      
      return 'You have spent \$${totalExpense.toStringAsFixed(2)} so far. Keep tracking to get detailed AI insights!';
    }
  }

  Future<List<String>> generateSavingTips(
    List<TransactionModel> transactions,
  ) async {
    try {
      if (transactions.isEmpty) {
        return [
          'Start tracking your expenses to get personalized tips',
          'Add at least 10 transactions for better insights',
          'Set a monthly budget to monitor your spending',
        ];
      }

      final expenses = transactions.where((t) => t.type == 'expense').toList();
      final totalExpense = expenses.fold(0.0, (sum, t) => sum + t.amount);
      
      final Map<String, double> categoryTotals = {};
      for (final transaction in expenses) {
        categoryTotals[transaction.category] = 
          (categoryTotals[transaction.category] ?? 0.0) + transaction.amount;
      }
      
      final sortedCategories = categoryTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final top3 = sortedCategories.take(3).map((e) => 
        '${e.key}: \$${e.value.toStringAsFixed(2)}'
      ).join(', ');

      final prompt = '''
Based on this spending data, provide exactly 5 specific, actionable saving tips.

Spending:
- Total: \$${totalExpense.toStringAsFixed(2)}
- Top Categories: $top3
- Expenses: ${expenses.length}

Requirements:
1. Each tip must be specific and actionable
2. Focus on highest spending categories
3. Include realistic money-saving amounts
4. Make tips practical
5. Be friendly and helpful

Format: Return ONLY a numbered list from 1 to 5, one tip per line, 1-2 sentences each.

Example:
1. Cook at home 3 times a week instead of eating out to save 120 dollars per month
2. Use public transport twice a week to reduce costs by 50 dollars per month

Your 5 tips:''';

      final response = await _callGroqAPI(prompt, maxTokens: 500);
      
      final tips = <String>[];
      final lines = response.split('\n');
      
      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isNotEmpty && trimmed.startsWith(RegExp(r'[0-9]'))) {
          final cleaned = trimmed
              .replaceFirst(RegExp(r'^[0-9]+\.?\s*'), '')
              .trim();
          if (cleaned.isNotEmpty) {
            tips.add(cleaned);
          }
        }
      }
      
      if (tips.isEmpty) {
        return _getDefaultSavingTips(categoryTotals);
      }
      
      return tips.take(5).toList();
      
    } catch (e) {
      if (kDebugMode) {
        print('Saving tips error: $e');
      }
      return _getDefaultSavingTips({});
    }
  }

  List<String> _getDefaultSavingTips(Map<String, double> categoryTotals) {
    final tips = <String>[
      'Set up automatic transfers to savings on payday',
      'Meal prep on weekends to reduce food delivery costs',
      'Review and cancel unused subscriptions',
      'Create shopping list before grocery shopping',
      'Brew coffee at home instead of buying daily',
    ];

    if (categoryTotals.isNotEmpty) {
      final topCategory = categoryTotals.entries
          .reduce((a, b) => a.value > b.value ? a : b);
      
      if (topCategory.key == 'Food & Dining') {
        tips.insert(0, 'Your top expense is dining. Try cooking at home 3 days a week to save \$${(topCategory.value * 0.3).toStringAsFixed(0)}');
      } else if (topCategory.key == 'Transportation') {
        tips.insert(0, 'Consider carpooling or public transport to reduce your \$${topCategory.value.toStringAsFixed(0)} transportation costs');
      }
    }

    return tips.take(5).toList();
  }

  Future<Map<String, double>> suggestBudget(
    List<TransactionModel> transactions,
    double monthlyIncome,
  ) async {
    if (monthlyIncome <= 0) return {};
    
    return {
      'Bills & Utilities': monthlyIncome * 0.20,
      'Groceries': monthlyIncome * 0.15,
      'Transportation': monthlyIncome * 0.10,
      'Healthcare': monthlyIncome * 0.05,
      'Food & Dining': monthlyIncome * 0.10,
      'Entertainment': monthlyIncome * 0.08,
      'Shopping': monthlyIncome * 0.07,
      'Personal Care': monthlyIncome * 0.05,
      'Savings': monthlyIncome * 0.20,
    };
  }

  int calculateFinancialHealthScore(
    double income,
    double expenses,
    double savings,
  ) {
    if (income <= 0) return 0;

    int score = 50;

    final expenseRatio = expenses / income;
    if (expenseRatio < 0.5) {
      score += 40;
    } else if (expenseRatio < 0.7) {
      score += 30;
    } else if (expenseRatio < 0.9) {
      score += 20;
    } else if (expenseRatio < 1.0) {
      score += 10;
    }

    final savingsRatio = savings / income;
    if (savingsRatio >= 0.20) {
      score += 30;
    } else if (savingsRatio >= 0.15) {
      score += 20;
    } else if (savingsRatio >= 0.10) {
      score += 15;
    } else if (savingsRatio >= 0.05) {
      score += 10;
    }

    if (income > expenses) {
      score += 20;
    } else if (income == expenses) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  String getHealthMessage(int score) 
  {
    if (score >= 80) {
      return 'Excellent! Your finances are in great shape!';
    } else if (score >= 60) {
      return 'Good! You are managing your money well!';
    } else if (score >= 40) {
      return 'Fair. There is room for improvement!';
    } else {
      return 'Needs attention. Let us work on improving your finances!';
    }
  }

  /// Get personalized financial advice from AI chatbot
  Future<String> getFinancialAdvice({
    required String userQuery,
    required String financialContext,
  }) async {
    try {
      final prompt = '''
You are a friendly and knowledgeable personal finance assistant called "FinanceFlow AI". 
Your role is to help users manage their money better with practical, personalized advice.

$financialContext

User's Question: "$userQuery"

Guidelines:
- Be conversational and friendly, use emojis occasionally
- Give specific, actionable advice based on their financial context
- If they ask about their spending, reference their actual data
- Keep responses concise (2-4 paragraphs max)
- Be encouraging and supportive
- If asked about investments, remind them you're providing general guidance, not professional financial advice
- Use bullet points for lists
- Include specific numbers when relevant to their situation

Respond naturally as a helpful financial assistant:''';

      final response = await _callGroqAPI(prompt, maxTokens: 600);
      
      if (kDebugMode) {
        print('AI Financial Advice Generated');
      }
      
      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Financial advice error: $e');
      }
      return 'I apologize, but I\'m having trouble processing your request right now. Please try again in a moment. 🙏';
    }
  }

  /// Generate a financial summary for reports
  Future<String> generateFinancialSummary({
    required double totalIncome,
    required double totalExpenses,
    required Map<String, double> categoryBreakdown,
    required String period,
  }) async {
    try {
      final categories = categoryBreakdown.entries
          .map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}')
          .join('\n');

      final prompt = '''
Generate a professional financial summary report for this $period period.

Financial Data:
- Total Income: \$${totalIncome.toStringAsFixed(2)}
- Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
- Net Savings: \$${(totalIncome - totalExpenses).toStringAsFixed(2)}

Category Breakdown:
$categories

Create a brief summary that includes:
1. Overview of financial health
2. Key observations about spending patterns
3. Areas of concern (if any)
4. Recommendations for improvement

Keep it professional and concise (3-4 paragraphs).''';

      final summary = await _callGroqAPI(prompt, maxTokens: 400);
      return summary;
    } catch (e) {
      if (kDebugMode) {
        print('Summary generation error: $e');
      }
      return 'Financial summary for $period: Income \$${totalIncome.toStringAsFixed(2)}, Expenses \$${totalExpenses.toStringAsFixed(2)}, Net \$${(totalIncome - totalExpenses).toStringAsFixed(2)}';
    }
  }
}