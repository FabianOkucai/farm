import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/assets_path.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/auth_provider.dart';
import '../../providers/farm_provider.dart';
import '../../providers/season_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../add_farm/add_farm_screen.dart';
import '../farm_notes/farm_notes_screen.dart';
import '../profile/profile_settings_screen.dart';
import '../seasons/seasons_screen.dart';
import '../select_farm/select_farm_screen.dart';
import '../schedule/schedule_screen.dart';
import '../../providers/notification_provider.dart';
import '../notifications/notifications_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadFarms());
  }

  Future<void> _loadFarms() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    if (authProvider.user != null) {
      await farmProvider.loadFarms(authProvider.user!.id);
    }
  }

  void _onNavigationTap(int index) {
    if (index == _currentIndex) return;

    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
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
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          Strings.dashboard,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () async {
                  final notificationProvider =
                      Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  );

                  // Show test notification
                  await notificationProvider.showTaskNotification(
                    title: "Welcome to Agape Farm App",
                    description: "Your farming companion is ready to help!",
                  );

                  // Navigate to notifications screen
                  if (mounted) {
                    NavigationHelper.navigateTo(
                      context,
                      const NotificationsScreen(),
                    );
                  }
                },
              ),
              // Show notification badge if there are unread notifications
              Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  final unreadCount =
                      provider.notifications.where((n) => !n.isRead).length;
                  if (unreadCount == 0) return const SizedBox();

                  return Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        unreadCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
      body: farmProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dashboard Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildDashboardItem(
                        title: Strings.myFarms,
                        icon: AssetPaths.dashboardFarm,
                        color: const Color(0xFFE0F7E0),
                        onTap: () {
                          NavigationHelper.navigateTo(
                            context,
                            const AddFarmScreen(
                              returnToNotes: false,
                            ),
                          );
                        },
                      ),
                      _buildDashboardItem(
                        title: Strings.mySeasons,
                        icon: AssetPaths.dashboardSeasons,
                        color: const Color(0xFFA5D6A7),
                        onTap: () {
                          NavigationHelper.navigateTo(
                              context, const SeasonsScreen());
                        },
                      ),
                      _buildDashboardItem(
                        title: Strings.mySchedule,
                        icon: AssetPaths.dashboardSchedule,
                        color: const Color(0xFFA5D6A7),
                        onTap: () {
                          NavigationHelper.navigateTo(
                              context, const ScheduleScreen());
                        },
                      ),
                      _buildDashboardItem(
                        title: Strings.myNotes,
                        icon: AssetPaths.dashboardNotes,
                        color: const Color(0xFFE0F7E0),
                        onTap: () {
                          final farmProvider = Provider.of<FarmProvider>(
                            context,
                            listen: false,
                          );
                          if (farmProvider.selectedFarm != null) {
                            NavigationHelper.navigateTo(
                              context,
                              const FarmNotesScreen(),
                            );
                          } else {
                            NavigationHelper.navigateTo(
                              context,
                              const SelectFarmScreen(
                                returnToNotes: true,
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Farm Progress Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      Strings.myFarmProgress,
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Farm Progress Card
                  _buildFarmProgressCard(),

                  // Seasonal Guide Section
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                    'Seasonal Guide',
                    'Get month-by-month guidance for your mango farm',
                    Icons.calendar_today,
                  ),
                  const SizedBox(height: 16),
                  _buildSeasonalGuideCard(),
                ],
              ),
            ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }

  Widget _buildDashboardItem({
    required String title,
    required String icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              height: 80,
              width: 80,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmProgressCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Mango farm',
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '3 acres | 4 farms',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Progress Timeline
          _buildTimelineItem(
            title: '2nd Inspection completed',
            date: '23rd August - 25th August',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: '4th spray season',
            date: '23/04 - 25/04',
            isCompleted: true,
            isLast: false,
          ),
          _buildTimelineItem(
            title: 'Mulching phase',
            date: '23rd August - 25th August',
            isCompleted: false,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String date,
    required bool isCompleted,
    required bool isLast,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline dot and line
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted ? AppColors.primaryGreen : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppColors.primaryGreen
                      : AppColors.textLight,
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: AppColors.primaryLightGreen.withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonalGuideCard() {
    final currentMonth = DateTime.now().month;
    final seasonProvider = Provider.of<SeasonProvider>(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, '/seasons'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.eco_outlined,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Month Activities',
                          style: AppTextStyles.heading3.copyWith(
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Month $currentMonth',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              if (seasonProvider.seasons.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  seasonProvider.seasons
                      .firstWhere(
                        (s) => s.month == currentMonth,
                        orElse: () => seasonProvider.seasons.first,
                      )
                      .shortDescription,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.grey[700],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primaryGreen,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
