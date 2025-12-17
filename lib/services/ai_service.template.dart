import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/transaction_model.dart';

/// AI Service Template
/// 
/// This is a template file showing the structure of the AI service.
/// The actual service uses the Groq API for AI-powered financial insights.
/// 
/// To use this service:
/// 1. Get a free API key from https://console.groq.com/
/// 2. Copy this file to ai_service.dart
/// 3. Replace 'YOUR_GROQ_API_KEY' with your actual API key
/// 
/// IMPORTANT: Never commit your actual API key to version control!

class AIService {
  // TODO: Replace with your Groq API key from https://console.groq.com/
  static const String _apiKey = 'YOUR_GROQ_API_KEY';
  static const String _baseUrl = 'https://api.groq.com/openai/v1';
  
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  
  AIService._internal() {
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
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API call failed: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Groq API Error: $e');
      }
      rethrow;
    }
  }

  // ... rest of the service implementation
  // See the full ai_service.dart for complete implementation
}
