import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/season_data.dart';
import '../../providers/season_provider.dart';

class SeasonDetailScreen extends StatefulWidget {
  final int monthNumber;

  const SeasonDetailScreen({
    Key? key,
    required this.monthNumber,
  }) : super(key: key);

  @override
  State<SeasonDetailScreen> createState() => _SeasonDetailScreenState();
}

class _SeasonDetailScreenState extends State<SeasonDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SeasonProvider>().loadSeasonInfo(widget.monthNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Month ${widget.monthNumber}',
          style: const TextStyle(
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
      body: Consumer<SeasonProvider>(
        builder: (context, seasonProvider, child) {
          if (seasonProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (seasonProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error: ${seasonProvider.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        seasonProvider.loadSeasonInfo(widget.monthNumber),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final season = seasonProvider.selectedSeason;
          if (season == null) {
            return const Center(child: Text('No data available'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  season.title,
                  style: AppTextStyles.heading2,
                ),
                const SizedBox(height: 16),
                Text(
                  season.shortDescription,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.grey[700],
                  ),
                ),
                if (season.fullInstructions != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Full Instructions',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      season.fullInstructions!,
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                ],
                if (season.activities != null &&
                    season.activities!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Activities',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: season.activities!.length,
                    itemBuilder: (context, index) {
                      final activity = season.activities![index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activity.title,
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                activity.description,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
