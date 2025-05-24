import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_settings_screen.dart';
import '../seasons/seasons_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({Key? key}) : super(key: key);

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  int _currentIndex = 2;
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    // TODO: Implement schedule loading
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
        NavigationHelper.navigateToReplacement(context, const SeasonsScreen());
        break;
      case 2:
        // Already on schedule
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
          'Farm Schedule',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Calendar Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month - 1,
                            );
                          });
                          _loadSchedule();
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_selectedDate),
                        style: AppTextStyles.heading3,
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _selectedDate = DateTime(
                              _selectedDate.year,
                              _selectedDate.month + 1,
                            );
                          });
                          _loadSchedule();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Schedule Content
            Expanded(
              child: farmProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildScheduleContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add new schedule item
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }

  Widget _buildScheduleContent() {
    // TODO: Replace with actual schedule data
    final dummyTasks = [
      _ScheduleTask(
        title: 'Fertilizer Application',
        description: 'Apply NPK fertilizer to mango trees',
        date: DateTime.now(),
        isCompleted: true,
      ),
      _ScheduleTask(
        title: 'Pest Control',
        description: 'Spray pesticides for aphid control',
        date: DateTime.now().add(const Duration(days: 2)),
        isCompleted: false,
      ),
      _ScheduleTask(
        title: 'Irrigation Check',
        description: 'Check and maintain irrigation system',
        date: DateTime.now().add(const Duration(days: 5)),
        isCompleted: false,
      ),
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: dummyTasks.length,
      itemBuilder: (context, index) {
        final task = dummyTasks[index];
        return _buildTaskCard(task);
      },
    );
  }

  Widget _buildTaskCard(_ScheduleTask task) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () {
          // TODO: Navigate to task details
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  color: task.isCompleted
                      ? AppColors.primaryGreen
                      : AppColors.primaryLightGreen,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      task.description,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat('MMM dd').format(task.date),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    task.isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.isCompleted
                        ? AppColors.primaryGreen
                        : AppColors.textLight,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleTask {
  final String title;
  final String description;
  final DateTime date;
  final bool isCompleted;

  _ScheduleTask({
    required this.title,
    required this.description,
    required this.date,
    required this.isCompleted,
  });
}
