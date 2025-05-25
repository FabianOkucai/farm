import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../providers/notification_provider.dart';
import '../../providers/farm_provider.dart';
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
          context,
          const DashboardScreen(),
        );
        break;
      case 1:
        NavigationHelper.navigateToReplacement(context, const SeasonsScreen());
        break;
      case 2:
        NavigationHelper.navigateToReplacement(
          context,
          const FarmNotesScreen(),
        );
        break;
      case 3:
        NavigationHelper.navigateToReplacement(
          context,
          const ProfileSettingsScreen(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Consumer<FarmProvider>(
              builder: (context, farmProvider, child) {
                return Text(
                  farmProvider.selectedFarm?.name ?? 'No farm selected',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              final notificationProvider = Provider.of<NotificationProvider>(
                context,
                listen: false,
              );
              notificationProvider.cancelAllNotifications();
            },
            icon: const Icon(
              Icons.cleaning_services_rounded,
              color: AppColors.primaryGreen,
            ),
            label: Text(
              'Clear All',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notificationProvider, child) {
          if (notificationProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (notificationProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${notificationProvider.error}',
                    style: TextStyle(color: Colors.red[300]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      notificationProvider.clearError();
                      notificationProvider.initialize();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll receive updates about your farm here',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: notificationProvider.notifications.length,
            itemBuilder: (context, index) {
              final notification = notificationProvider.notifications[index];
              return Dismissible(
                key: Key(notification.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete_outline, color: Colors.red[400]),
                ),
                onDismissed: (direction) {
                  notificationProvider.cancelNotification(notification.id);
                },
                child: Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                  child: InkWell(
                    onTap:
                        () => notificationProvider.markAsRead(notification.id),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(
                                    0.1,
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications_none_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight:
                                            notification.isRead
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                        fontSize: 16,
                                        color:
                                            notification.isRead
                                                ? Colors.grey[600]
                                                : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _formatTime(notification.timestamp),
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[500],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          if (notification.body.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.only(left: 48),
                              child: Text(
                                notification.body,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 7) {
      return '${time.day}/${time.month}/${time.year}';
    } else if (difference.inDays > 0) {
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
