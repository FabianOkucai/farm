// lib/presentation/screens/farm_notes/farm_notes_screen.dart - Complete Updated Version

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
import '../contact/contact_screen.dart';

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

  Future<void> _syncNotes() async {
    final farmProvider = Provider.of<FarmProvider>(context, listen: false);
    await farmProvider.syncNotes();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Notes sync completed'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    }
  }

  Future<void> _deleteNote(Note note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final farmProvider = Provider.of<FarmProvider>(context, listen: false);
      await farmProvider.deleteNoteOffline(note.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${note.title}"'),
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final farmProvider = Provider.of<FarmProvider>(context);

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
        actions: [
          // Sync button with status indicator
          Consumer<FarmProvider>(
            builder: (context, provider, child) {
              final syncStatus = provider.getNoteSyncStatus();
              final pendingCount = syncStatus['pending'] ?? 0;
              final failedCount = syncStatus['failed'] ?? 0;

              IconData syncIcon = Icons.sync;
              Color syncColor = Colors.grey;

              if (provider.isLoading) {
                syncIcon = Icons.sync;
                syncColor = AppColors.primaryGreen;
              } else if (failedCount > 0) {
                syncIcon = Icons.sync_problem;
                syncColor = Colors.red;
              } else if (pendingCount > 0) {
                syncIcon = Icons.sync;
                syncColor = Colors.orange;
              } else {
                syncIcon = Icons.sync;
                syncColor = AppColors.primaryGreen;
              }

              return Stack(
                children: [
                  IconButton(
                    onPressed: provider.isLoading ? null : _syncNotes,
                    icon: provider.isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primaryGreen),
                      ),
                    )
                        : Icon(syncIcon, color: syncColor),
                    tooltip: 'Sync Notes',
                  ),
                  if (pendingCount > 0 || failedCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: failedCount > 0 ? Colors.red : Colors.orange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 12,
                          minHeight: 12,
                        ),
                        child: Text(
                          '${pendingCount + failedCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
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

            // Sync Status Banner
            Consumer<FarmProvider>(
              builder: (context, provider, child) {
                final syncStatus = provider.getNoteSyncStatus();
                final pendingCount = syncStatus['pending'] ?? 0;
                final failedCount = syncStatus['failed'] ?? 0;
                final syncedCount = syncStatus['synced'] ?? 0;
                final totalCount = syncStatus['total'] ?? 0;

                if (totalCount == 0) return const SizedBox.shrink();

                Color bannerColor = AppColors.primaryGreen;
                String statusText = 'All notes synced';
                IconData statusIcon = Icons.check_circle;

                if (failedCount > 0) {
                  bannerColor = Colors.red;
                  statusText = '$failedCount notes failed to sync';
                  statusIcon = Icons.error;
                } else if (pendingCount > 0) {
                  bannerColor = Colors.orange;
                  statusText = '$pendingCount notes pending sync';
                  statusIcon = Icons.sync;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bannerColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: bannerColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(statusIcon, color: bannerColor, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: bannerColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      if (provider.isOffline)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'OFFLINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // Notes List or Empty State
            Expanded(
              child: farmProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : farmProvider.notes.isEmpty
                  ? _buildEmptyState()
                  : _buildNotesList(farmProvider),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavigationTap,
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              NavigationHelper.navigateTo(context, const ContactScreen());
            },
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.contact_phone),
          ),
          const SizedBox(height: 16),
          Container(
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
        ],
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
            // Navigate to note details or edit
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
                    const SizedBox(width: 8),
                    // Sync status indicator
                    _buildSyncStatusIndicator(note),
                    const Spacer(),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: AppColors.textLight,
                        size: 20,
                      ),
                      onSelected: (value) async {
                        switch (value) {
                          case 'edit':
                          // Navigate to edit note
                            break;
                          case 'delete':
                            await _deleteNote(note);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 16),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 16, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
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

  Widget _buildSyncStatusIndicator(Note note) {
    IconData icon;
    Color color;
    String tooltip;

    switch (note.syncStatus) {
      case NoteSyncStatus.synced:
        icon = Icons.check_circle;
        color = AppColors.primaryGreen;
        tooltip = 'Synced';
        break;
      case NoteSyncStatus.pending:
        icon = Icons.sync;
        color = Colors.orange;
        tooltip = 'Pending sync';
        break;
      case NoteSyncStatus.failed:
        icon = Icons.error;
        color = Colors.red;
        tooltip = 'Sync failed';
        break;
    }

    return Tooltip(
      message: tooltip,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 12,
          color: color,
        ),
      ),
    );
  }
}