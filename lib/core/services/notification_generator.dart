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
        );

        // Mark notification as sent
        await _localStorage.setBool('notification_$id', true);

        // Store in history
        await _addToHistory(
          id: id,
          title: notification.title,
          body: notification.body,
          seasonId: season.id,
          timestamp: DateTime.now(),
        );
      }
    }
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
        ];
      case 2:
        return [
          _SeasonNotification(
            id: 'planting',
            title: 'Planting Season',
            body:
                'Optimal time to plant your crops. Ensure proper spacing and depth.',
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
    required String seasonId,
    required DateTime timestamp,
  }) async {
    final history = await _localStorage.getList('notification_history') ?? [];

    history.add({
      'id': id,
      'title': title,
      'body': body,
      'season_id': seasonId,
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
