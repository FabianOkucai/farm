import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../core/models/season_data.dart';
import '../../providers/season_provider.dart';
import 'season_detail_screen.dart';

class SeasonOverviewScreen extends StatefulWidget {
  const SeasonOverviewScreen({Key? key}) : super(key: key);

  @override
  State<SeasonOverviewScreen> createState() => _SeasonOverviewScreenState();
}

class _SeasonOverviewScreenState extends State<SeasonOverviewScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SeasonProvider>().loadAllSeasons();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mango Growing Season',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                    onPressed: () => seasonProvider.loadAllSeasons(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: seasonProvider.seasons.length,
            itemBuilder: (context, index) {
              final season = seasonProvider.seasons[index];
              return _buildSeasonCard(season);
            },
          );
        },
      ),
    );
  }

  Widget _buildSeasonCard(SeasonData season) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  SeasonDetailScreen(monthNumber: season.month),
            ),
          );
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Month ${season.month}',
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                season.title,
                style: AppTextStyles.heading3.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                season.shortDescription,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
