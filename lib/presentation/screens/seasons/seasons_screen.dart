import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../farm_notes/farm_notes_screen.dart';
import '../profile/profile_settings_screen.dart';

class SeasonsScreen extends StatefulWidget {
  const SeasonsScreen({Key? key}) : super(key: key);

  @override
  State<SeasonsScreen> createState() => _SeasonsScreenState();
}

class _SeasonsScreenState extends State<SeasonsScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 1;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
        // Already on seasons
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
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/images/seasons.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        Strings.seasons,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Active Season',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            TabBar(
              controller: _tabController,
              labelColor: AppColors.primaryGreen,
              unselectedLabelColor: AppColors.textMedium,
              indicatorColor: AppColors.primaryGreen,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              tabs: const [
                Tab(text: Strings.cultivationTips),
                Tab(text: Strings.fertilizers),
                Tab(text: Strings.diseases),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Cultivation Tips Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTipCard(
                          'Month 1',
                          'Soil Preparation & Planting',
                          'Begin by preparing the soil with organic matter, ensure soil pH is between 5.5 and 7.5, and plant the mango saplings with proper spacing to allow for growth and air circulation.',
                        ),
                        const SizedBox(height: 16),
                        _buildTipCard(
                          'Month 3',
                          'Watering & Mulching',
                          'Water young trees regularly but avoid overwatering. Apply mulch around the base of trees to conserve moisture, suppress weeds, and provide nutrients as it decomposes.',
                        ),
                        const SizedBox(height: 16),
                        _buildTipCard(
                          'Month 6',
                          'Pruning & Training',
                          'Prune to remove dead or diseased branches and to shape the tree for optimal sunlight exposure and air circulation. Train young trees to develop a strong framework.',
                        ),
                      ],
                    ),
                  ),

                  // Fertilizers Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildFertilizerCard(
                          'Nitrogen-rich Fertilizer',
                          'Apply during vegetative growth phase to promote leaf and stem development.',
                          '10-5-5',
                        ),
                        const SizedBox(height: 16),
                        _buildFertilizerCard(
                          'Phosphorus-rich Fertilizer',
                          'Apply before flowering to encourage bloom and fruit set.',
                          '5-10-5',
                        ),
                        const SizedBox(height: 16),
                        _buildFertilizerCard(
                          'Potassium-rich Fertilizer',
                          'Apply during fruit development to improve fruit quality and yield.',
                          '5-5-10',
                        ),
                      ],
                    ),
                  ),

                  // Diseases Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDiseaseCard(
                          'Anthracnose',
                          'Fungal disease causing black spots on leaves, flowers, and fruits. Control with fungicides and proper spacing for air circulation.',
                        ),
                        const SizedBox(height: 16),
                        _buildDiseaseCard(
                          'Powdery Mildew',
                          'White powdery growth on leaves and young shoots. Control with sulfur-based fungicides and avoid overhead irrigation.',
                        ),
                        const SizedBox(height: 16),
                        _buildDiseaseCard(
                          'Mango Malformation',
                          'Causes abnormal growth of vegetative and floral parts. Control by pruning affected parts and applying appropriate fungicides.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }

  Widget _buildTipCard(String month, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryLightGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              month,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFertilizerCard(String name, String description, String ratio) {
    return Container(
      padding: const EdgeInsets.all(20),
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
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryLightGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  ratio,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primaryGreen,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiseaseCard(String name, String description) {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Text(
            name,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMedium,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
