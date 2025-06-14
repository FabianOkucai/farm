import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../../providers/auth_provider.dart';
import '../farm_details/farm_details_screen.dart';
import '../add_farm/add_farm_screen.dart';
import '../dashboard/dashboard_screen.dart';

class SelectFarmScreen extends StatelessWidget {
  final bool returnToNotes;

  const SelectFarmScreen({Key? key, this.returnToNotes = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Farm',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              NavigationHelper.navigateTo(context, const AddFarmScreen());
            },
            icon: const Icon(Icons.add, color: AppColors.primaryGreen),
            label: const Text(
              'Add Farm',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<FarmProvider>(
        builder: (context, farmProvider, child) {
          if (farmProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (farmProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${farmProvider.error}',
                    style: TextStyle(color: Colors.red[300]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      farmProvider.clearError();
                      farmProvider.loadFarms();
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

          if (farmProvider.farms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.agriculture_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No farms added yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your first farm to get started',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      NavigationHelper.navigateTo(
                        context,
                        const AddFarmScreen(),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add Farm'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Farm Count Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.all(16),
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
                      Icons.info_outline,
                      color: AppColors.primaryGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        farmProvider.selectedFarm != null
                            ? 'Current: ${farmProvider.selectedFarm!.name} • ${farmProvider.farms.length} total farms'
                            : 'Select from ${farmProvider.farms.length} farms',
                        style: TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Farms List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: farmProvider.farms.length,
                  itemBuilder: (context, index) {
                    final farm = farmProvider.farms[index];
                    final isSelected = farm.id == farmProvider.selectedFarm?.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSelected
                              ? AppColors.primaryGreen
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: InkWell(
                        onTap: () async {
                          // Select the farm
                          await farmProvider.selectFarm(farm.id);

                          if (context.mounted) {
                            // Show selection feedback
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Selected ${farm.name}'),
                                backgroundColor: AppColors.primaryGreen,
                                duration: const Duration(seconds: 1),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );

                            // Small delay to show the snackbar
                            await Future.delayed(const Duration(milliseconds: 300));

                            // Navigate back to dashboard to show selected farm
                            if (context.mounted) {
                              NavigationHelper.navigateToReplacement(
                                context,
                                const DashboardScreen(),
                              );
                            }
                          }
                        },
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
                                      color: isSelected
                                          ? AppColors.primaryGreen.withOpacity(0.2)
                                          : AppColors.primaryGreen.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.agriculture,
                                      color: isSelected
                                          ? AppColors.primaryGreen
                                          : AppColors.primaryGreen.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                farm.name,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.w600,
                                                  color: isSelected
                                                      ? AppColors.primaryGreen
                                                      : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (isSelected)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryGreen,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: const Text(
                                                  'ACTIVE',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${farm.size} acres • ${farm.village}, ${farm.district}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                        color: AppColors.primaryGreen,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    )
                                  else
                                    IconButton(
                                      onPressed: () {
                                        NavigationHelper.navigateTo(
                                          context,
                                          FarmDetailsScreen(farmId: farm.id),
                                        );
                                      },
                                      icon: Icon(
                                        Icons.info_outline,
                                        color: Colors.grey[400],
                                        size: 20,
                                      ),
                                      tooltip: 'View Details',
                                    ),
                                ],
                              ),

                              // Additional farm info
                              if (isSelected) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryGreen.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: AppColors.primaryGreen,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Planted: ${_formatPlantingDate(farm.plantingDate)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        Icons.trending_up,
                                        size: 16,
                                        color: AppColors.primaryGreen,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Month ${farm.currentSeasonMonth}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primaryGreen,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatPlantingDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}