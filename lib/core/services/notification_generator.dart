import 'package:farm/core/models/season.dart';
import 'package:farm/core/services/notification_service.dart';
import 'package:farm/core/utils/local_storage.dart';

class NotificationGenerator {
  final NotificationService _notificationService;
  final LocalStorage _localStorage;

  NotificationGenerator({
    required NotificationService notificationService,
    required LocalStorage localStorage,
  }) : _notificationService = notificationService,
       _localStorage = localStorage;

  Future<void> generateSeasonNotifications(Season season) async {
    final currentMonth = season.currentMonth;
    final notifications = _getNotificationsForMonth(currentMonth);

    for (final notification in notifications) {
      final id = '${season.id}_${notification.id}';

      // Check if notification was already sent
      final isSent = await _localStorage.getBool('notification_$id') ?? false;
      if (!isSent) {
        await _notificationService.showNotification(
          title: notification.title,
          body: notification.body,
          payload: {
            'type': 'season',
            'season_id': season.id,
            'month': currentMonth.toString(),
          },
        );

        // Mark notification as sent
        await _localStorage.setBool('notification_$id', true);

        // Store in history
        await _addToHistory(
          id: id,
          title: notification.title,
          body: notification.body,
          type: 'season',
          seasonId: season.id,
          timestamp: DateTime.now(),
        );
      }
    }
  }

  Future<void> generateTaskNotification({
    required String title,
    required String body,
    required String taskId,
    DateTime? scheduledDate,
  }) async {
    final id = 'task_$taskId';

    if (scheduledDate != null) {
      await _notificationService.scheduleNotification(
        title: title,
        body: body,
        scheduledDate: scheduledDate,
        payload: {'type': 'task', 'task_id': taskId},
      );
    } else {
      await _notificationService.showNotification(
        title: title,
        body: body,
        payload: {'type': 'task', 'task_id': taskId},
      );
    }

    // Store in history
    await _addToHistory(
      id: id,
      title: title,
      body: body,
      type: 'task',
      taskId: taskId,
      timestamp: scheduledDate ?? DateTime.now(),
    );
  }

  Future<void> generateWeatherAlert({
    required String title,
    required String body,
    required String alertId,
  }) async {
    final id = 'weather_$alertId';

    await _notificationService.showNotification(
      title: title,
      body: body,
      payload: {'type': 'weather', 'alert_id': alertId},
    );

    // Store in history
    await _addToHistory(
      id: id,
      title: title,
      body: body,
      type: 'weather',
      alertId: alertId,
      timestamp: DateTime.now(),
    );
  }

  List<_SeasonNotification> _getNotificationsForMonth(int month) {
    switch (month) {
      case 1:
        return [
          _SeasonNotification(
            id: 'prepare_soil',
            title: 'Soil Preparation Time',
            body:
                'Time to prepare your soil for the new growing season. Check soil pH and add necessary amendments.',
          ),
          _SeasonNotification(
            id: 'plan_crops',
            title: 'Crop Planning',
            body:
                'Plan your crops for the season. Consider crop rotation and companion planting.',
          ),
        ];
      case 2:
        return [
          _SeasonNotification(
            id: 'planting',
            title: 'Planting Season',
            body:
                'Optimal time to plant your crops. Ensure proper spacing and depth.',
          ),
          _SeasonNotification(
            id: 'irrigation',
            title: 'Irrigation Setup',
            body:
                'Set up your irrigation system and ensure proper water distribution.',
          ),
        ];
      case 3:
        return [
          _SeasonNotification(
            id: 'fertilizer',
            title: 'First Fertilizer Application',
            body:
                'Apply the first round of fertilizer to support early growth.',
          ),
          _SeasonNotification(
            id: 'pest_check',
            title: 'Pest Monitoring',
            body: 'Start monitoring for early signs of pests and diseases.',
          ),
        ];
      // Add more months with their specific notifications
      default:
        return [];
    }
  }

  Future<void> _addToHistory({
    required String id,
    required String title,
    required String body,
    required String type,
    String? seasonId,
    String? taskId,
    String? alertId,
    required DateTime timestamp,
  }) async {
    final history = await _localStorage.getList('notification_history') ?? [];

    history.add({
      'id': id,
      'title': title,
      'body': body,
      'type': type,
      'season_id': seasonId,
      'task_id': taskId,
      'alert_id': alertId,
      'timestamp': timestamp.toIso8601String(),
      'is_read': false,
    });

    await _localStorage.setList('notification_history', history);
  }

  Future<List<Map<String, dynamic>>> getNotificationHistory() async {
    return await _localStorage.getList('notification_history') ?? [];
  }

  Future<void> markAsRead(String notificationId) async {
    final history = await _localStorage.getList('notification_history') ?? [];

    final updatedHistory =
        history.map((notification) {
          if (notification['id'] == notificationId) {
            return {...notification, 'is_read': true};
          }
          return notification;
        }).toList();

    await _localStorage.setList('notification_history', updatedHistory);
  }

  Future<void> clearHistory() async {
    await _localStorage.remove('notification_history');
  }
}

class _SeasonNotification {
  final String id;
  final String title;
  final String body;

  _SeasonNotification({
    required this.id,
    required this.title,
    required this.body,
  });
}
