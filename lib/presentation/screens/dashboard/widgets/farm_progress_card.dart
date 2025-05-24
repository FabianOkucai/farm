import 'package:flutter/material.dart';
import '../../../../constants/app_colors.dart';
import '../../../../constants/app_text_styles.dart';

class FarmProgressCard extends StatelessWidget {
  final String farmName;
  final int totalSeasons;
  final int totalFarms;
  final List<Map<String, String>> progressItems;

  const FarmProgressCard({
    Key? key,
    required this.farmName,
    required this.totalSeasons,
    required this.totalFarms,
    required this.progressItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                farmName,
                style: AppTextStyles.heading3,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$totalSeasons seasons | $totalFarms farms',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMedium,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // Progress Timeline
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: progressItems.length,
            itemBuilder: (context, index) {
              final item = progressItems[index];
              final isLast = index == progressItems.length - 1;

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
                          color: AppColors.primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
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
                            item['title'] ?? '',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item['date']} • ${item['time']}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
