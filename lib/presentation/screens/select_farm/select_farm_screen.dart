import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../farm_notes/farm_notes_screen.dart';
import '../add_farm/add_farm_screen.dart';

class SelectFarmScreen extends StatelessWidget {
  final bool returnToNotes;

  const SelectFarmScreen({
    Key? key,
    required this.returnToNotes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Select Farm',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => NavigationHelper.pop(context),
        ),
      ),
      body: farmProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : farmProvider.farms.isEmpty
              ? _buildEmptyState(context)
              : _buildFarmList(context, farmProvider),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          NavigationHelper.navigateTo(context, const AddFarmScreen());
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primaryLightGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.agriculture_outlined,
              size: 64,
              color: AppColors.primaryGreen.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Farms Yet',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textMedium,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first farm to get started',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              NavigationHelper.navigateTo(context, const AddFarmScreen());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text('Add Farm'),
          ),
        ],
      ),
    );
  }

  Widget _buildFarmList(BuildContext context, FarmProvider farmProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: farmProvider.farms.length,
      itemBuilder: (context, index) {
        final farm = farmProvider.farms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () async {
              await farmProvider.selectFarm(farm.id);
              if (context.mounted) {
                if (returnToNotes) {
                  NavigationHelper.navigateToReplacement(
                    context,
                    const FarmNotesScreen(),
                  );
                } else {
                  NavigationHelper.pop(context);
                }
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    farm.name,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${farm.village}, ${farm.district}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${farm.size} hectares',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
