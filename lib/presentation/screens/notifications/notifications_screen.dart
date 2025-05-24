import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../seasons/seasons_screen.dart';
import '../farm_notes/farm_notes_screen.dart';
import '../profile/profile_settings_screen.dart';
import '../../../core/utils/navigation_helper.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int _currentIndex = 0;

  void _onNavigationTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        NavigationHelper.navigateToReplacement(
            context, const DashboardScreen());
        break;
      case 1:
        NavigationHelper.navigateToReplacement(context, const SeasonsScreen());
        break;
      case 2:
        NavigationHelper.navigateToReplacement(
            context, const FarmNotesScreen());
        break;
      case 3:
        NavigationHelper.navigateToReplacement(
            context, const ProfileSettingsScreen());
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear All Notifications'),
                  content: const Text(
                    'Are you sure you want to clear all notifications?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        final notificationProvider =
                            Provider.of<NotificationProvider>(
                          context,
                          listen: false,
                        );
                        notificationProvider.cancelAllNotifications();
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Clear All',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (notificationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${notificationProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notificationProvider.clearError();
                      notificationProvider.initialize();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (notificationProvider.notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (direction) {
                  notificationProvider.cancelNotification(notification.id);
                },
                child: _buildNotificationCard(
                  title: notification.title,
                  message: notification.body,
                  time: notification.timestamp,
                  isRead: notification.isRead,
                  onTap: () {
                    notificationProvider.markAsRead(notification.id);
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }

  Widget _buildNotificationCard({
    required String title,
    required String message,
    required DateTime time,
    required bool isRead,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primaryGreen,
            ),
          ),
          title: Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: isRead ? Colors.grey : Colors.black,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isRead ? Colors.grey : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(time),
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          trailing: !isRead
              ? Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryGreen,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
