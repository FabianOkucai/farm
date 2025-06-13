import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../../providers/auth_provider.dart';
import '../farm_details/farm_details_screen.dart';
import '../add_farm/add_farm_screen.dart';

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
                  ),
                  const SizedBox(height: 16),
                  Consumer<AuthProvider>(
                    builder: (context, authProvider, _) {
                      return ElevatedButton(
                        onPressed: () {
                          farmProvider.clearError();
                          farmProvider.loadFarms(authProvider.user!.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('Retry'),
                      );
                    },
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

          return ListView.builder(
            padding: const EdgeInsets.all(16),
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
                    color:
                        isSelected ? AppColors.primaryGreen : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: InkWell(
                  onTap: () async {
                    await farmProvider.selectFarm(farm.id);
                    if (context.mounted) {
                      NavigationHelper.navigateTo(
                        context,
                        FarmDetailsScreen(farmId: farm.id),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.agriculture,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                farm.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${farm.size ?? 0} acres • ${farm.village ?? 'Unknown'}, ${farm.district ?? 'Unknown'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
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
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
