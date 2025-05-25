import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_colors.dart';
import '../../../constants/app_text_styles.dart';
import '../../../constants/strings.dart';
import '../../../core/utils/navigation_helper.dart';
import '../../../core/models/note.dart';
import '../../providers/farm_provider.dart';
import '../../widgets/navigation_bar.dart';
import '../dashboard/dashboard_screen.dart';
import '../profile/profile_settings_screen.dart';
import '../seasons/seasons_screen.dart';
import '../farm_details/farm_details_screen.dart';
import 'add_note_screen.dart';

class FarmNotesScreen extends StatefulWidget {
  const FarmNotesScreen({Key? key}) : super(key: key);

  @override
  State<FarmNotesScreen> createState() => _FarmNotesScreenState();
}

class _FarmNotesScreenState extends State<FarmNotesScreen> {
  int _currentIndex = 2;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    if (farmProvider.selectedFarm != null) {
      await farmProvider.loadNotes(
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
        NavigationHelper.navigateToReplacement(
          context,
          const DashboardScreen(),
        );
        break;
      case 1:
        NavigationHelper.navigateToReplacement(context, const SeasonsScreen());
        break;
      case 2:
        // Already on notes
        break;
      case 3:
        NavigationHelper.navigateToReplacement(
          context,
          const ProfileSettingsScreen(),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          Strings.farmNotes,
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
            // Farm Selector
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: DropdownButtonFormField<String>(
                value: farmProvider.selectedFarm?.id,
                decoration: const InputDecoration(
                  labelText: 'Select Farm',
                  labelStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  border: InputBorder.none,
                ),
                items: [
                  if (farmProvider.farms.isEmpty)
                    const DropdownMenuItem(
                      value: null,
                      child: Text('No farms available'),
                    ),
                  ...farmProvider.farms.map((farm) {
                    return DropdownMenuItem(
                      value: farm.id,
                      child: Text(farm.name),
                    );
                  }).toList(),
                ],
                onChanged: (String? farmId) async {
                  if (farmId != null) {
                    final selectedFarm = farmProvider.farms.firstWhere(
                      (farm) => farm.id == farmId,
                    );
                    await farmProvider.selectFarm(farmId);
                    if (farmProvider.selectedFarm != null) {
                      await _loadNotes();
                    }
                  }
                },
                hint: const Text('Select a farm'),
                isExpanded: true,
              ),
            ),

            // Notes List or Empty State
            Expanded(
              child:
                  farmProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : farmProvider.notes.isEmpty
                      ? _buildEmptyState()
                      : _buildNotesList(farmProvider),
            ),
          ],
        ),
      ),
      floatingActionButton: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF000900), Color(0xFF026A02)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (farmProvider.selectedFarm != null) {
                NavigationHelper.navigateTo(
                  context,
                  AddNoteScreen(farmId: farmProvider.selectedFarm!.id),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please select a farm first'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            borderRadius: BorderRadius.circular(30),
            child: const Center(
              child: Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
    );
  }

  Widget _buildEmptyState() {
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
              Icons.note_outlined,
              size: 64,
              color: AppColors.primaryGreen.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No notes yet',
            style: AppTextStyles.heading3.copyWith(
              color: AppColors.textMedium,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Add your first farm note',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesList(FarmProvider farmProvider) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: farmProvider.notes.length,
      itemBuilder: (context, index) {
        final note = farmProvider.notes[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildNoteCard(note),
        );
      },
    );
  }

  Widget _buildNoteCard(Note note) {
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Container(
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to note details
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
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
                        color: AppColors.primaryLightGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        dateFormat.format(note.createdAt),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                      onSelected: (value) {
                        // Handle menu item selection
                      },
                      itemBuilder:
                          (context) => [
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete'),
                            ),
                          ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  note.title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMedium,
                    fontSize: 14,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
