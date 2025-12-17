import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

/// 🔔 NOTIFICATION SERVICE
/// Handles push notifications and local notifications
/// Firebase Cloud Messaging + Local Notifications for alerts

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Notification channel constants
  static const String _channelId = 'finance_flow_channel';
  static const String _channelName = 'FinanceFlow Notifications';
  static const String _channelDescription = 'Budget alerts, savings updates, and reminders';

  // Preference keys
  static const String _prefBudgetAlerts = 'pref_budget_alerts';
  static const String _prefSavingsUpdates = 'pref_savings_updates';
  static const String _prefDailyReminders = 'pref_daily_reminders';
  static const String _prefWeeklyReports = 'pref_weekly_reports';

  /// Initialize notification service
  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();
    
    // Request permission for iOS
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Configure FCM handlers
    await _configureFCM();

    // Get and save FCM token
    await _saveFCMToken();
  }

  /// Request notification permissions
  Future<void> _requestPermission() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ Notification permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ Provisional notification permission granted');
    } else {
      print('❌ Notification permission denied');
    }
  }

  /// Initialize local notifications plugin
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android (skip on web)
    if (!kIsWeb) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Configure Firebase Cloud Messaging
  Future<void> _configureFCM() async {
    // Foreground message handler
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Background message handler (when app is in background)
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is terminated
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
  }

  /// Save FCM token for server communication
  Future<String?> _saveFCMToken() async {
    final token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('📱 FCM Token: $token');
      // TODO: Send token to your backend for targeted notifications
    }
    return token;
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('📩 Received foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      showLocalNotification(
        title: message.notification!.title ?? 'FinanceFlow',
        body: message.notification!.body ?? '',
        payload: message.data.toString(),
      );
    }
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');
    // Handle navigation based on notification data
    // Example: Navigate to specific screen based on message.data
  }

  /// Callback when local notification is tapped
  void _onNotificationTapped(NotificationResponse response) {
    print('🔔 Local notification tapped: ${response.payload}');
    // Handle navigation based on payload
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int id = 0,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(id, title, body, details, payload: payload);
  }

  // ═══════════════════════════════════════════════════════════════
  // BUDGET ALERTS
  // ═══════════════════════════════════════════════════════════════

  /// Send budget warning notification
  Future<void> showBudgetWarning({
    required String category,
    required double spent,
    required double budget,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefBudgetAlerts) ?? true)) return;

    final percentage = (spent / budget * 100).toInt();
    
    await showLocalNotification(
      id: category.hashCode,
      title: '⚠️ Budget Alert: $category',
      body: 'You\'ve spent ${percentage}% of your $category budget (\$${spent.toStringAsFixed(2)} of \$${budget.toStringAsFixed(2)})',
      payload: 'budget_alert:$category',
    );
  }

  /// Send budget exceeded notification
  Future<void> showBudgetExceeded({
    required String category,
    required double spent,
    required double budget,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefBudgetAlerts) ?? true)) return;

    final overAmount = spent - budget;
    
    await showLocalNotification(
      id: category.hashCode + 1000,
      title: '🚨 Budget Exceeded: $category',
      body: 'You\'ve exceeded your $category budget by \$${overAmount.toStringAsFixed(2)}',
      payload: 'budget_exceeded:$category',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SAVINGS UPDATES
  // ═══════════════════════════════════════════════════════════════

  /// Send savings milestone notification
  Future<void> showSavingsMilestone({
    required String goalName,
    required int percentage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefSavingsUpdates) ?? true)) return;

    String emoji = '🎯';
    if (percentage >= 100) emoji = '🎉';
    else if (percentage >= 75) emoji = '🔥';
    else if (percentage >= 50) emoji = '💪';
    else if (percentage >= 25) emoji = '🚀';

    await showLocalNotification(
      id: goalName.hashCode,
      title: '$emoji Savings Milestone!',
      body: 'You\'ve reached $percentage% of your "$goalName" goal!',
      payload: 'savings_milestone:$goalName',
    );
  }

  /// Send goal completed notification
  Future<void> showGoalCompleted({required String goalName}) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefSavingsUpdates) ?? true)) return;

    await showLocalNotification(
      id: goalName.hashCode + 2000,
      title: '🎊 Goal Achieved!',
      body: 'Congratulations! You\'ve completed your "$goalName" savings goal!',
      payload: 'goal_completed:$goalName',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // REMINDERS
  // ═══════════════════════════════════════════════════════════════

  /// Schedule daily reminder notification
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefDailyReminders) ?? false)) return;

    // Cancel any existing daily reminder
    await _localNotifications.cancel(9999);

    // Schedule daily recurring notification
    await _localNotifications.zonedSchedule(
      9999,
      '📝 Daily Finance Check',
      'Don\'t forget to log your expenses today!',
      _nextInstanceOfTime(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print('📅 Daily reminder scheduled for $hour:$minute');
  }

  /// Calculate next instance of a specific time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// Cancel daily reminder
  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(9999);
    print('📅 Daily reminder cancelled');
  }

  // ═══════════════════════════════════════════════════════════════
  // WEEKLY REPORTS
  // ═══════════════════════════════════════════════════════════════

  /// Send weekly spending report notification
  Future<void> showWeeklyReport({
    required double totalSpent,
    required double totalIncome,
    required String topCategory,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_prefWeeklyReports) ?? true)) return;

    final savings = totalIncome - totalSpent;
    final savingsEmoji = savings > 0 ? '💚' : '🔴';

    await showLocalNotification(
      id: 8888,
      title: '📊 Weekly Financial Report',
      body: 'Spent: \$${totalSpent.toStringAsFixed(0)} | Income: \$${totalIncome.toStringAsFixed(0)} $savingsEmoji\nTop category: $topCategory',
      payload: 'weekly_report',
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // SETTINGS MANAGEMENT
  // ═══════════════════════════════════════════════════════════════

  /// Get notification settings
  Future<Map<String, bool>> getNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'budgetAlerts': prefs.getBool(_prefBudgetAlerts) ?? true,
      'savingsUpdates': prefs.getBool(_prefSavingsUpdates) ?? true,
      'dailyReminders': prefs.getBool(_prefDailyReminders) ?? false,
      'weeklyReports': prefs.getBool(_prefWeeklyReports) ?? true,
    };
  }

  /// Update notification setting
  Future<void> updateNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    
    String prefKey;
    switch (key) {
      case 'budgetAlerts':
        prefKey = _prefBudgetAlerts;
        break;
      case 'savingsUpdates':
        prefKey = _prefSavingsUpdates;
        break;
      case 'dailyReminders':
        prefKey = _prefDailyReminders;
        if (!value) {
          await cancelDailyReminder();
        }
        break;
      case 'weeklyReports':
        prefKey = _prefWeeklyReports;
        break;
      default:
        return;
    }

    await prefs.setBool(prefKey, value);
    print('🔔 Updated $key to $value');
  }

  /// Subscribe to a topic for targeted notifications
  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('📢 Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('📢 Unsubscribed from topic: $topic');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('🔕 All notifications cancelled');
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background message: ${message.notification?.title}');
  // Handle background message here
}
