import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/notification_generator.dart';
import '../../core/services/daily_checker_service.dart';
import '../../core/utils/local_storage.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;
  final String? seasonId;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
    this.seasonId,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      seasonId: json['season_id'] as String?,
    );
  }
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final NotificationGenerator _notificationGenerator;
  final DailyCheckerService _dailyCheckerService;
  final LocalStorage _localStorage;
  final List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider({
    required NotificationService notificationService,
    required NotificationGenerator notificationGenerator,
    required DailyCheckerService dailyCheckerService,
    required LocalStorage localStorage,
  }) : _notificationService = notificationService,
       _notificationGenerator = notificationGenerator,
       _dailyCheckerService = dailyCheckerService,
       _localStorage = localStorage {
    initialize();
  }

  List<NotificationItem> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _notificationService.initialize();

      // Start daily checker service
      _dailyCheckerService.startDailyCheck();

      // Load notifications from local storage
      await _loadNotifications();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadNotifications() async {
    final history = await _notificationGenerator.getNotificationHistory();

    _notifications.clear();
    _notifications.addAll(
      history.map((json) => NotificationItem.fromJson(json)).toList(),
    );

    // Sort by timestamp, newest first
    _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  Future<void> showTaskNotification({
    required String title,
    required String description,
  }) async {
    try {
      await _notificationService.showNotification(
        title: title,
        body: description,
      );

      // Add to local notifications list
      _notifications.insert(
        0,
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: description,
          timestamp: DateTime.now(),
        ),
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> scheduleTaskNotification({
    required String title,
    required String description,
    required DateTime scheduledDate,
  }) async {
    try {
      await _notificationService.scheduleNotification(
        title: title,
        body: description,
        scheduledDate: scheduledDate,
      );

      // Add to local notifications list
      _notifications.insert(
        0,
        NotificationItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          body: description,
          timestamp: scheduledDate,
        ),
      );

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      await _notificationGenerator.markAsRead(notificationId);
      await _loadNotifications(); // Reload to get updated state
      notifyListeners();
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
      await _localStorage.clear();
      _notifications.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cancelNotification(String notificationId) async {
    try {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        await _localStorage.remove('notification_$notificationId');
        _notifications.removeAt(index);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _dailyCheckerService.stopDailyCheck();
    super.dispose();
  }
}
