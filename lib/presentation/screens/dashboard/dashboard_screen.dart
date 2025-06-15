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
import '../contact/contact_screen.dart';
import '../farm_progress/farm_progress_detail_screen.dart';

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
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDashboard();
    });
  }

  Future<void> _initializeDashboard() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);

    // Load farms if not already loaded
    if (farmProvider.farms.isEmpty) {
      debugPrint('🌱 Dashboard loading farms...');
      await farmProvider.loadFarms();
    }

    // Load notes for selected farm if available (without triggering rebuild)
    if (farmProvider.selectedFarm != null) {
      debugPrint('📝 Loading notes for selected farm...');
      // Don't await this to avoid triggering setState during build
      farmProvider.loadNotes(
        farmProvider.selectedFarm!.id,
        farmProvider.selectedFarm!.farmerId,
      );
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

  void _navigateToFarmProgress(String farmId) {
    NavigationHelper.navigateTo(
      context,
      FarmProgressDetailScreen(farmId: farmId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              Strings.dashboard,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
            Consumer<FarmProvider>(
              builder: (context, farmProvider, child) {
                if (farmProvider.isLoading) {
                  return const Text(
                    'Loading farms...',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  );
                }

                if (farmProvider.selectedFarm != null) {
                  return Text(
                    '${farmProvider.selectedFarm!.name} (${farmProvider.farms.length} farms)',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  );
                }

                if (farmProvider.farms.isEmpty) {
                  return const Text(
                    'No farms found',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  );
                }

                return Text(
                  '${farmProvider.farms.length} farms available',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                );
              },
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                      const SelectFarmScreen(returnToNotes: false),
                    );
                  },
                ),
                _buildDashboardItem(
                  title: Strings.mySeasons,
                  icon: AssetPaths.dashboardSeasons,
                  color: const Color(0xFFA5D6A7),
                  onTap: () {
                    NavigationHelper.navigateTo(
                      context,
                      const SeasonsScreen(),
                    );
                  },
                ),
                _buildDashboardItem(
                  title: Strings.mySchedule,
                  icon: AssetPaths.dashboardSchedule,
                  color: const Color(0xFFA5D6A7),
                  onTap: () {
                    NavigationHelper.navigateTo(
                      context,
                      const NotificationsScreen(),
                    );
                  },
                ),
                _buildDashboardItem(
                  title: Strings.myNotes,
                  icon: AssetPaths.dashboardNotes,
                  color: const Color(0xFFE0F7E0),
                  onTap: () {
                    NavigationHelper.navigateTo(
                      context,
                      const FarmNotesScreen(),
                    );
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

            // Guide Section
            const SizedBox(height: 24),
            _buildSectionHeader(
              'Farmer\'s Guide',
              'Quick tips and help for managing your farm',
              Icons.lightbulb_outline,
            ),
            const SizedBox(height: 16),
            _buildGuideCard(),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationHelper.navigateTo(context, const ContactScreen());
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.contact_phone),
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
            Image.asset(icon, height: 80, width: 80, fit: BoxFit.cover),
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
    return Consumer<FarmProvider>(
      builder: (context, farmProvider, child) {
        final selectedFarm = farmProvider.selectedFarm;
        final stats = farmProvider.getFarmStatistics();

        if (selectedFarm == null) {
          return _buildNoFarmSelectedCard(stats);
        }

        return GestureDetector(
          onTap: () => _navigateToFarmProgress(selectedFarm.id),
          child: Container(
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
                // Header Row
                Row(
                  children: [
                    Text(
                      selectedFarm.name,
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundGrey,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${selectedFarm.size} acres | ${stats['total_farms']} farms',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMedium,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${selectedFarm.village}, ${selectedFarm.district}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textLight,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),

                // Current Season Display
                FutureBuilder<Map<String, dynamic>?>(
                  future: farmProvider.getCurrentSeasonData(selectedFarm.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return _buildSeasonLoadingState();
                    }

                    if (snapshot.hasError) {
                      return _buildSeasonErrorState();
                    }

                    final seasonData = snapshot.data;

                    // Handle null data gracefully
                    if (seasonData == null) {
                      return _buildSeasonErrorState();
                    }

                    // Safely extract data with null checks
                    final farm = seasonData['farm'] as Map<String, dynamic>?;
                    final currentSeason = seasonData['current_season'] as Map<String, dynamic>?;

                    if (farm == null || currentSeason == null) {
                      return _buildSeasonErrorState();
                    }

                    return _buildCurrentSeasonDisplay(farm, currentSeason);
                  },
                ),

                const SizedBox(height: 16),

                // Tap to view more indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        color: AppColors.primaryGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Tap to view detailed monthly guide',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primaryGreen,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentSeasonDisplay(Map<String, dynamic> farm, Map<String, dynamic> currentSeason) {
    // Safe extraction with null checks and defaults
    final currentMonth = (currentSeason['month'] as int?) ?? 1;
    final title = (currentSeason['title'] as String?) ?? 'Season Information';
    final shortDescription = (currentSeason['short_description'] as String?) ?? 'Loading season details...';
    final ageInMonths = ((farm['age_in_months'] as num?) ?? 0.0).toDouble();
    final activities = (currentSeason['activities'] as List<dynamic>?) ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Month Badge and Progress
        Row(
          children: [
            // Month Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.eco,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Month $currentMonth',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Age Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryLightGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                '${ageInMonths.toStringAsFixed(1)} months old',
                style: TextStyle(
                  color: AppColors.primaryGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Season Title
        Text(
          title,
          style: AppTextStyles.bodyLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),

        const SizedBox(height: 6),

        // Short Description
        Text(
          shortDescription,
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMedium,
            fontSize: 13,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 12),

        // Progress Bar
        _buildMonthProgressBar(currentMonth, ageInMonths),

        const SizedBox(height: 12),

        // Activities Preview
        Row(
          children: [
            Icon(
              Icons.checklist_outlined,
              color: AppColors.primaryGreen,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              '${activities.length} key activities this month',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMonthProgressBar(int currentMonth, double ageInMonths) {
    final monthProgress = (ageInMonths % 1).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Month Progress',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
            Text(
              '${(monthProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.primaryLightGreen.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: monthProgress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryGreen,
                    AppColors.primaryGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonLoadingState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundGrey,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading season information...',
            style: TextStyle(
              color: AppColors.textMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Unable to load season data. Check your connection.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoFarmSelectedCard(Map<String, dynamic> stats) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[300]!, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.agriculture_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            stats['total_farms'] > 0
                ? 'Select a farm to view progress'
                : 'No farms found',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (stats['total_farms'] > 0) ...[
            const SizedBox(height: 8),
            Text(
              'You have ${stats['total_farms']} farms',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationHelper.navigateTo(
                  context,
                  const SelectFarmScreen(returnToNotes: false),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Select Farm'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuideCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    Icons.tips_and_updates,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Getting Started',
                        style: AppTextStyles.heading3.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Welcome to your farm management app',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              '• Start by selecting your farm from "My Farms" above\n'
                  '• Track your progress in the Farm Progress section\n'
                  '• Add notes about important observations\n'
                  '• Check the schedule for upcoming activities\n'
                  '• Monitor seasons to optimize your farming',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryLightGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primaryGreen.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Need help? Tap on any section to learn more about its features',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primaryGreen, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.heading3),
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