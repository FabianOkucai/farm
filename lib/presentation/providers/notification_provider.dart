import 'package:flutter/material.dart';
import '../../core/services/notification_service.dart';

class NotificationItem {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool isRead;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  final List<NotificationItem> _notifications = [];
  bool _isLoading = false;
  String? _error;

  NotificationProvider({required NotificationService notificationService})
    : _notificationService = notificationService {
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
      // TODO: Load saved notifications from local storage
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
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
      _notifications[index] = NotificationItem(
        id: _notifications[index].id,
        title: _notifications[index].title,
        body: _notifications[index].body,
        timestamp: _notifications[index].timestamp,
        isRead: true,
      );
      notifyListeners();
    }
  }

  Future<void> cancelAllNotifications() async {
    try {
      await _notificationService.cancelAllNotifications();
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
        await _notificationService.cancelNotification(
          int.parse(notificationId),
        );
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
}
