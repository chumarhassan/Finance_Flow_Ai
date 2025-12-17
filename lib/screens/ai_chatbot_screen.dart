import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/colors.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/ai_service.dart';

/// 🤖 AI CHATBOT SCREEN
/// Interactive financial guidance chatbot using Groq AI
class AIChatbotScreen extends StatefulWidget {
  const AIChatbotScreen({super.key});

  @override
  State<AIChatbotScreen> createState() => _AIChatbotScreenState();
}

class _AIChatbotScreenState extends State<AIChatbotScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AIService _aiService = AIService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  // Quick action prompts
  final List<QuickPrompt> _quickPrompts = [
    QuickPrompt('💰', 'Analyze my spending', 'Analyze my recent spending patterns and identify areas where I can save money.'),
    QuickPrompt('📊', 'Budget tips', 'Give me personalized budget tips based on my income and expenses.'),
    QuickPrompt('🎯', 'Savings advice', 'How can I save more money this month? Suggest specific strategies.'),
    QuickPrompt('📈', 'Investment basics', 'Explain basic investment options for beginners with low risk.'),
    QuickPrompt('💳', 'Debt management', 'What\'s the best strategy to pay off debt faster?'),
    QuickPrompt('🏠', 'Emergency fund', 'How much should I have in my emergency fund and how to build one?'),
  ];

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    _messages.add(ChatMessage(
      text: 'Hi! 👋 I\'m your AI Financial Assistant. I can help you with:\n\n'
          '💰 Analyzing your spending habits\n'
          '📊 Creating budgets\n'
          '🎯 Setting savings goals\n'
          '📈 Investment advice\n'
          '💡 Financial tips\n\n'
          'Ask me anything about your finances!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNavy,
      appBar: AppBar(
        backgroundColor: AppColors.primaryNavy,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Finance AI',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Always ready to help',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryYellow),
            onPressed: _clearChat,
            tooltip: 'Clear chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return _buildTypingIndicator();
                }
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),

          // Quick Prompts
          if (_messages.length <= 1)
            Container(
              height: 48,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _quickPrompts.length,
                itemBuilder: (context, index) {
                  final prompt = _quickPrompts[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      avatar: Text(prompt.emoji),
                      label: Text(
                        prompt.label,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      backgroundColor: AppColors.primaryPurple,
                      side: BorderSide.none,
                      onPressed: () => _sendMessage(prompt.fullPrompt),
                    ),
                  );
                },
              ),
            ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryPurple,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: _messageController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          hintText: 'Ask me anything about finance...',
                          hintStyle: TextStyle(color: Colors.white38),
                          border: InputBorder.none,
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _isLoading ? null : () => _sendMessage(),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: _isLoading
                            ? LinearGradient(
                                colors: [
                                  Colors.grey.shade600,
                                  Colors.grey.shade700,
                                ],
                              )
                            : AppColors.yellowPinkGradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        _isLoading ? Icons.hourglass_empty : Icons.send_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.yellowPinkGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.primaryYellow.withOpacity(0.9)
                    : AppColors.primaryPurple,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(message.isUser ? 20 : 4),
                  bottomRight: Radius.circular(message.isUser ? 4 : 20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? AppColors.primaryNavy : Colors.white,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser
                          ? AppColors.primaryNavy.withOpacity(0.6)
                          : Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primaryPurple,
              child: Text(
                Provider.of<AuthProvider>(context, listen: false)
                        .currentUser
                        ?.name
                        .substring(0, 1)
                        .toUpperCase() ??
                    'U',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.yellowPinkGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDot(0),
                _buildDot(1),
                _buildDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 150)),
      builder: (context, value, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withOpacity(0.5 + (value * 0.5)),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = overrideText ?? _messageController.text.trim();
    if (text.isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get financial context for better AI responses
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      
      final financialContext = await _buildFinancialContext(transactionProvider);
      
      // Get AI response
      final response = await _aiService.getFinancialAdvice(
        userQuery: text,
        financialContext: financialContext,
      );

      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: 'Sorry, I encountered an error. Please try again. 🙏\n\nError: ${e.toString()}',
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isLoading = false;
        });
        _scrollToBottom();
      }
    }
  }

  Future<String> _buildFinancialContext(TransactionProvider provider) async {
    final transactions = provider.transactions;
    
    if (transactions.isEmpty) {
      return 'User has no transaction history yet.';
    }

    // Calculate totals
    final totalIncome = transactions
        .where((t) => t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);
    
    final totalExpenses = transactions
        .where((t) => !t.isIncome)
        .fold(0.0, (sum, t) => sum + t.amount);

    // Get spending by category
    final categorySpending = <String, double>{};
    for (final t in transactions.where((t) => !t.isIncome)) {
      categorySpending[t.category] = (categorySpending[t.category] ?? 0) + t.amount;
    }

    // Sort categories by spending
    final sortedCategories = categorySpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Get recent transactions (last 10)
    final recentTransactions = transactions.take(10).map((t) {
      return '${t.category}: \$${t.amount.toStringAsFixed(2)} (${t.isIncome ? "income" : "expense"})';
    }).join(', ');

    return '''
User's Financial Context:
- Total Income: \$${totalIncome.toStringAsFixed(2)}
- Total Expenses: \$${totalExpenses.toStringAsFixed(2)}
- Net Balance: \$${(totalIncome - totalExpenses).toStringAsFixed(2)}
- Top Spending Categories: ${sortedCategories.take(5).map((e) => '${e.key}: \$${e.value.toStringAsFixed(2)}').join(', ')}
- Recent Transactions: $recentTransactions
''';
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.primaryPurple,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Clear Chat?', style: TextStyle(color: Colors.white)),
        content: const Text(
          'This will remove all messages from this conversation.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryYellow),
            child: const Text('Clear', style: TextStyle(color: AppColors.primaryNavy)),
          ),
        ],
      ),
    );
  }
}

/// Chat message model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Quick prompt model
class QuickPrompt {
  final String emoji;
  final String label;
  final String fullPrompt;

  QuickPrompt(this.emoji, this.label, this.fullPrompt);
}
