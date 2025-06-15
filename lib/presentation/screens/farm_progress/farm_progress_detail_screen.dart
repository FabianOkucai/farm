import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../contact/contact_screen.dart';

class FarmProgressDetailScreen extends StatefulWidget {
  final String farmId;

  const FarmProgressDetailScreen({
    Key? key,
    required this.farmId,
  }) : super(key: key);

  @override
  State<FarmProgressDetailScreen> createState() => _FarmProgressDetailScreenState();
}

class _FarmProgressDetailScreenState extends State<FarmProgressDetailScreen> {
  Map<String, dynamic>? _seasonData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSeasonData();
  }

  Future<void> _loadSeasonData() async {
    try {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      final data = await farmProvider.getCurrentSeasonData(widget.farmId);

      if (mounted) {
        setState(() {
          _seasonData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Farm Progress',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _seasonData != null
          ? _buildProgressContent()
          : _buildNoDataState(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationHelper.navigateTo(context, const ContactScreen());
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.contact_phone),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryGreen),
          SizedBox(height: 16),
          Text('Loading farm progress...'),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            'Failed to load progress',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.red[300],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'Unknown error occurred',
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSeasonData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No progress data available',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressContent() {
    final farm = _seasonData!['farm'] as Map<String, dynamic>;
    final currentSeason = _seasonData!['current_season'] as Map<String, dynamic>;

    final farmName = farm['name'] as String;
    final currentMonth = currentSeason['month'] as int;
    final title = currentSeason['title'] as String;
    final shortDescription = currentSeason['short_description'] as String;
    final fullInstructions = currentSeason['full_instructions'] as String;
    final activities = currentSeason['activities'] as List<dynamic>;
    final ageInMonths = (farm['age_in_months'] as num).toDouble();
    final plantingDate = farm['planting_date'] as String;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Farm Name
                Text(
                  farmName,
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Farm Details Row
                Row(
                  children: [
                    _buildInfoChip(
                      '${farm['size']} acres',
                      Icons.square_foot,
                      AppColors.primaryGreen,
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      '${ageInMonths.toStringAsFixed(1)} months',
                      Icons.schedule,
                      AppColors.secondaryOrange,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Current Month Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Currently in Month $currentMonth',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Progress Visualization
                _buildProgressVisualization(currentMonth, ageInMonths),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Season Title Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                  title,
                  style: AppTextStyles.heading2.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppColors.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          shortDescription,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Activities Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    Icon(
                      Icons.checklist_outlined,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Key Activities This Month',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLightGreen.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${activities.length} tasks',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activities.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final activity = activities[index] as String;
                    return _buildActivityCard(activity, index + 1);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Detailed Instructions Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
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
                    Icon(
                      Icons.article_outlined,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Detailed Instructions',
                      style: AppTextStyles.heading3.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  fullInstructions,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 15,
                    height: 1.6,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Farm Info Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.1),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Farm Information',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInfoRow('Planted on', _formatDate(plantingDate)),
                _buildInfoRow('Location', '${farm['village']}, ${farm['district']}'),
                _buildInfoRow('Size', '${farm['size']} acres'),
                _buildInfoRow('Age', '${ageInMonths.toStringAsFixed(1)} months'),
                _buildInfoRow('Notes', '${farm['notes_count']} recorded observations'),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressVisualization(int currentMonth, double ageInMonths) {
    final monthProgress = (ageInMonths % 1).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Progress',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),

        // Progress Bars for 12 months
        Row(
          children: List.generate(12, (index) {
            final month = index + 1;
            final isCurrentMonth = month == currentMonth;
            final isCompletedMonth = month < currentMonth;

            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 11 ? 4 : 0),
                child: Column(
                  children: [
                    Container(
                      height: 8,
                      decoration: BoxDecoration(
                        color: isCompletedMonth
                            ? AppColors.primaryGreen
                            : isCurrentMonth
                            ? AppColors.primaryGreen.withOpacity(0.5)
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: isCurrentMonth
                          ? FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: monthProgress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                          : null,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      month.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal,
                        color: isCurrentMonth
                            ? AppColors.primaryGreen
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 12),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Current Progress: ${(monthProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMedium,
              ),
            ),
            Text(
              '${((currentMonth - 1 + monthProgress) / 12 * 100).toInt()}% Complete',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityCard(String activity, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                index.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              activity,
              style: AppTextStyles.bodyMedium.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Icon(
            Icons.agriculture,
            color: AppColors.primaryGreen.withOpacity(0.5),
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.textMedium,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textDark,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}