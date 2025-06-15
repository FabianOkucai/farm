// lib/presentation/providers/farm_provider.dart - Complete Updated Version

import 'package:flutter/material.dart';
import '../../core/models/farm.dart';
import '../../core/models/note.dart';
import '../../core/models/season.dart';
import '../../core/services/api_service.dart';
import '../../core/utils/local_storage.dart';

// Add this model class for activities
class FarmActivity {
  final String id;
  final String title;
  final DateTime date;
  final String description;
  final String farmId;

  FarmActivity({
    required this.id,
    required this.title,
    required this.date,
    required this.description,
    required this.farmId,
  });
}

class FarmProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Farm> _farms = [];
  Farm? _selectedFarm;
  List<Season> _seasons = [];
  Season? _selectedSeason;
  List<Note> _notes = [];
  List<FarmActivity> _activities = [];

  bool _isLoading = false;
  bool _isOffline = false;
  String? _error;

  FarmProvider({required ApiService apiService}) : _apiService = apiService;

  // Getters
  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  List<Season> get seasons => _seasons;
  Season? get selectedSeason => _selectedSeason;
  List<Note> get notes => _notes;
  List<FarmActivity> get activities => _activities;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get error => _error;

  /// Creates a farm, optionally with a uuid. Returns uuid from backend if present.
  Future<String?> createFarmWithUuid(
      Farm farm, {
        String? uuid,
        String? farmerName,
      }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🚀 Starting farm creation process...');
      debugPrint('📍 UUID present: ${uuid != null && uuid.isNotEmpty}');
      debugPrint('👤 Farmer name: $farmerName');

      // Call the API method
      final result = await _apiService.createFarmWithUuid(
        farm,
        uuid: uuid,
        farmerName: farmerName,
      );

      debugPrint('📥 Received response from backend');

      // Handle the response
      final returnedUuid = result['uuid'] as String?;
      final farmData = result['farm'] as Map<String, dynamic>?;
      final currentSeason = result['current_season'] as Map<String, dynamic>?;
      final allSeasons = result['all_seasons_summary'] as List<dynamic>?;

      if (farmData != null) {
        // Create farm from server response
        final serverFarm = Farm.fromJson(farmData);

        // Replace the temporary local farm with server farm
        final tempFarmIndex = _farms.indexWhere((f) => f.name == farm.name && !f.isSynced);
        if (tempFarmIndex != -1) {
          _farms[tempFarmIndex] = serverFarm;
          debugPrint('✅ Updated local farm with server data');
        } else {
          _farms.add(serverFarm);
          debugPrint('✅ Added new farm to local list');
        }

        // Store seasons data if it's the first farm
        if (allSeasons != null) {
          debugPrint('💾 Storing all seasons summary locally...');
          await _storeAllSeasons(allSeasons);
        }

        // Store current season for this farm
        if (currentSeason != null) {
          debugPrint('💾 Storing current season for farm...');
          await _storeCurrentSeason(serverFarm.id, currentSeason);
        }
      }

      _isLoading = false;
      notifyListeners();

      debugPrint('🎉 Farm creation completed successfully');
      return returnedUuid;

    } catch (e) {
      debugPrint('❌ Farm creation failed: $e');
      _isLoading = false;
      _error = e.toString();
      _isOffline = true;
      notifyListeners();
      rethrow;
    }
  }

  // Helper methods for storing seasons data
  Future<void> _storeAllSeasons(List<dynamic> seasons) async {
    try {
      final localStorage = await LocalStorage.init();
      final seasonsData = seasons.cast<Map<String, dynamic>>();
      await localStorage.setSeasons(seasonsData);
      debugPrint('✅ Stored ${seasons.length} seasons locally');
    } catch (e) {
      debugPrint('❌ Failed to store seasons: $e');
    }
  }

  Future<void> _storeCurrentSeason(String farmId, Map<String, dynamic> seasonData) async {
    try {
      final localStorage = await LocalStorage.init();
      await localStorage.setMap('current_season_$farmId', seasonData);
      debugPrint('✅ Stored current season for farm $farmId');
    } catch (e) {
      debugPrint('❌ Failed to store current season: $e');
    }
  }

  // Load farms for authenticated user
  Future<void> loadFarms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🚀 Loading farms for authenticated user...');

      final farmsData = await _apiService.getFarmsWithMetadata();

      _farms = farmsData['farms'] as List<Farm>;
      final totalFarms = farmsData['total_farms'] as int;
      final totalSize = farmsData['total_size'] as num;

      debugPrint('✅ Loaded ${_farms.length} farms');

      // Auto-select first farm if available and none is currently selected
      if (_farms.isNotEmpty && _selectedFarm == null) {
        _selectedFarm = _farms.first;
        debugPrint('🎯 Auto-selected first farm: ${_selectedFarm!.name}');

        // Store selected farm locally
        final localStorage = await LocalStorage.init();
        await localStorage.setMap('selected_farm', _selectedFarm!.toJson());
      }

      // Cache farms locally
      final localStorage = await LocalStorage.init();
      await localStorage.setFarms(_farms.map((f) => f.toJson()).toList());

      _isLoading = false;
      _isOffline = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to load farms: $e');
      _isLoading = false;
      _error = 'Unable to load farms. Please check your connection.';
      _isOffline = true;

      // Try to load from local cache
      await _loadFromLocalCache();
      notifyListeners();
    }
  }

  // Load from local cache
  Future<void> _loadFromLocalCache() async {
    try {
      final localStorage = await LocalStorage.init();

      // Load farms from cache
      final cachedFarms = await localStorage.getFarms();
      if (cachedFarms != null) {
        _farms = cachedFarms.map((json) => Farm.fromJson(json)).toList();
        debugPrint('📱 Loaded ${_farms.length} farms from cache');
      }

      // Load selected farm from cache
      final selectedFarmData = localStorage.getMap('selected_farm');
      if (selectedFarmData != null) {
        _selectedFarm = Farm.fromJson(selectedFarmData);
        debugPrint('📱 Restored selected farm: ${_selectedFarm!.name}');
      } else if (_farms.isNotEmpty && _selectedFarm == null) {
        _selectedFarm = _farms.first;
        debugPrint('📱 Auto-selected first cached farm: ${_selectedFarm!.name}');
      }
    } catch (e) {
      debugPrint('❌ Failed to load from cache: $e');
    }
  }

  // Select farm and persist selection
  Future<void> selectFarm(String farmId) async {
    try {
      final farm = _farms.firstWhere((f) => f.id == farmId);
      _selectedFarm = farm;

      // Persist selected farm
      final localStorage = await LocalStorage.init();
      await localStorage.setMap('selected_farm', farm.toJson());

      debugPrint('🎯 Selected farm: ${farm.name}');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to select farm: $e');
      _error = 'Failed to select farm';
      notifyListeners();
    }
  }

  // Get farm statistics for dashboard
  Map<String, dynamic> getFarmStatistics() {
    if (_farms.isEmpty) {
      return {
        'total_farms': 0,
        'total_size': 0.0,
        'selected_farm': null,
      };
    }

    return {
      'total_farms': _farms.length,
      'total_size': _farms.fold(0.0, (sum, farm) => sum + farm.size),
      'selected_farm': _selectedFarm?.name ?? 'No farm selected',
    };
  }

  Future<void> createFarm(Farm farm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newFarm = await _apiService.createFarm(farm);
      _farms.add(newFarm);
      _selectedFarm = newFarm;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Unable to create farm. Working in offline mode.';
      _isOffline = true;
      notifyListeners();
    }
  }

  Future<void> updateFarm(Farm farm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Update locally first
      final index = _farms.indexWhere((f) => f.id == farm.id);
      if (index != -1) {
        _farms[index] = farm.copyWith(
          isSynced: false,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      // Try to sync with backend
      try {
        final serverFarm = await _apiService.updateFarm(farm.id, farm);

        // Update local farm with server data
        if (index != -1) {
          _farms[index] = serverFarm;
        }
      } catch (e) {
        debugPrint('Failed to sync farm update with server: $e');
        _isOffline = true;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteFarm(String farmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mark as deleted locally
      final index = _farms.indexWhere((f) => f.id == farmId);
      if (index != -1) {
        _farms[index] = _farms[index].copyWith(
          isDeleted: true,
          isSynced: false,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }

      // Try to sync with backend
      try {
        await _apiService.deleteFarm(farmId);
        // Remove from local list if sync successful
        _farms.removeWhere((f) => f.id == farmId);
      } catch (e) {
        debugPrint('Failed to sync farm deletion with server: $e');
        _isOffline = true;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Season management
  Future<void> loadSeasons(String farmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock season data
      _seasons = [
        Season(
          id: '1',
          farmId: farmId,
          name: 'Spring 2023',
          startDate: DateTime(2023, 3, 1),
          endDate: DateTime(2023, 5, 31),
          status: SeasonStatus.completed,
          currentMonth: 3,
          lastUpdated: DateTime.now(),
        ),
        Season(
          id: '2',
          farmId: farmId,
          name: 'Summer 2023',
          startDate: DateTime(2023, 6, 1),
          endDate: DateTime(2023, 8, 31),
          status: SeasonStatus.active,
          currentMonth: 2,
          lastUpdated: DateTime.now(),
        ),
        Season(
          id: '3',
          farmId: farmId,
          name: 'Fall 2023',
          startDate: DateTime(2023, 9, 1),
          endDate: DateTime(2023, 11, 30),
          status: SeasonStatus.cancelled,
          currentMonth: 1,
          lastUpdated: DateTime.now(),
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // Get current season data for a farm
  Future<Map<String, dynamic>?> getCurrentSeasonData(String farmId) async {
    try {
      debugPrint('🌱 Getting current season data for farm: $farmId');

      // First, try to get from local storage
      final localStorage = await LocalStorage.init();
      final cachedSeasonData = localStorage.getMap('current_season_$farmId');

      if (cachedSeasonData != null) {
        debugPrint('✅ Found cached season data for farm');
        return cachedSeasonData;
      }

      // If not in cache, try to get from API
      try {
        // We'll need to add this method to the API service
        final seasonData = await _apiService.getCurrentSeasonForFarm(farmId);

        if (seasonData != null) {
          // Cache the season data
          await localStorage.setMap('current_season_$farmId', seasonData);

          debugPrint('✅ Retrieved and cached current season data');
          return seasonData;
        }
      } catch (e) {
        debugPrint('❌ Failed to get season data from API: $e');
        _isOffline = true;
      }

      // Fallback: Generate mock season data based on farm's planting date
      final farm = _farms.firstWhere((f) => f.id == farmId, orElse: () => throw Exception('Farm not found'));
      final mockSeasonData = _generateMockSeasonData(farm);

      // Cache the mock data
      await localStorage.setMap('current_season_$farmId', mockSeasonData);

      debugPrint('📱 Generated mock season data for offline use');
      return mockSeasonData;

    } catch (e) {
      debugPrint('❌ Failed to get current season data: $e');
      return null;
    }
  }

  // Generate mock season data based on farm's planting date
  Map<String, dynamic> _generateMockSeasonData(Farm farm) {
    final now = DateTime.now();
    final plantingDate = farm.plantingDate;
    final monthsSincePlanting = ((now.difference(plantingDate).inDays) / 30).floor() + 1;
    final currentMonth = monthsSincePlanting.clamp(1, 12);

    // Map of month activities
    final monthActivities = {
      1: {'title': 'Land Preparation', 'description': 'Prepare soil and planting area'},
      2: {'title': 'Planting', 'description': 'Plant mango seedlings'},
      3: {'title': 'Early Care', 'description': 'Water and fertilize young plants'},
      4: {'title': 'Growth Monitoring', 'description': 'Monitor plant growth and health'},
      5: {'title': 'Pest Control', 'description': 'Apply pest control measures'},
      6: {'title': 'Fertilization', 'description': 'Apply growth fertilizers'},
      7: {'title': 'Pruning', 'description': 'Prune and shape the trees'},
      8: {'title': 'Disease Prevention', 'description': 'Apply disease prevention treatments'},
      9: {'title': 'Fruit Development', 'description': 'Monitor fruit development'},
      10: {'title': 'Harvest Preparation', 'description': 'Prepare for harvest season'},
      11: {'title': 'Harvest', 'description': 'Harvest mature fruits'},
      12: {'title': 'Post-Harvest Care', 'description': 'Clean up and prepare for next season'},
    };

    final activity = monthActivities[currentMonth] ?? monthActivities[1]!;

    return {
      'month': currentMonth,
      'title': activity['title'],
      'short_description': activity['description'],
      'full_instructions': 'During month $currentMonth: ${activity['description']}. Monitor your plants regularly and follow recommended farming practices.',
      'activities': [
        {
          'title': activity['title'],
          'description': activity['description']
        }
      ],
      'is_mock': true, // Flag to indicate this is generated data
    };
  }

  Future<void> selectSeason(String seasonId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSeason = await _apiService.getSeason(seasonId);
      if (_selectedFarm != null) {
        await loadNotes(_selectedFarm!.id, _selectedFarm!.farmerId);
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createSeason(Season season) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSeason = await _apiService.createSeason(season);
      _seasons.add(newSeason);
      _selectedSeason = newSeason;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  // ============================================================================
  // NOTES MANAGEMENT (OFFLINE-FIRST APPROACH)
  // ============================================================================

  // Load notes from local storage
  Future<void> loadNotes(String farmId, String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('📚 Loading notes for farm: $farmId');

      // Load notes from local storage
      final localStorage = await LocalStorage.init();
      final localNotes = await localStorage.getNotesForFarm(farmId);

      _notes = localNotes;

      debugPrint('✅ Loaded ${_notes.length} notes from local storage');

      _isLoading = false;
      notifyListeners();

      // Background sync if needed
      _backgroundSyncNotes();

    } catch (e) {
      debugPrint('❌ Failed to load notes: $e');
      _isLoading = false;
      _error = 'Failed to load notes: ${e.toString()}';
      notifyListeners();
    }
  }

  // Create note offline
  Future<void> createNoteOffline({
    required String title,
    required String content,
    required String farmId,
    required String userId,
    String? seasonId,
  }) async {
    try {
      debugPrint('📝 Creating note offline: $title');

      final note = Note(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
        farmId: farmId,
        seasonId: seasonId,
        userId: userId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        syncStatus: NoteSyncStatus.pending,
      );

      // Store locally
      final localStorage = await LocalStorage.init();
      await localStorage.storeNote(note);

      // Add to local list for immediate UI update
      _notes.insert(0, note);
      notifyListeners();

      debugPrint('✅ Note created offline and stored locally');

      // Try immediate sync if online
      _backgroundSyncNotes();

    } catch (e) {
      debugPrint('❌ Failed to create note offline: $e');
      _error = 'Failed to create note: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Update note offline
  Future<void> updateNoteOffline(Note note, {
    String? title,
    String? content,
  }) async {
    try {
      debugPrint('✏️ Updating note offline: ${note.id}');

      final updatedNote = note.copyWith(
        title: title ?? note.title,
        content: content ?? note.content,
        updatedAt: DateTime.now(),
        syncStatus: NoteSyncStatus.pending,
      );

      // Store locally
      final localStorage = await LocalStorage.init();
      await localStorage.storeNote(updatedNote);

      // Update local list
      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index >= 0) {
        _notes[index] = updatedNote;
        notifyListeners();
      }

      debugPrint('✅ Note updated offline');

      // Try immediate sync if online
      _backgroundSyncNotes();

    } catch (e) {
      debugPrint('❌ Failed to update note offline: $e');
      _error = 'Failed to update note: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Delete note offline
  Future<void> deleteNoteOffline(String noteId) async {
    try {
      debugPrint('🗑️ Deleting note offline: $noteId');

      // Mark as deleted locally
      final localStorage = await LocalStorage.init();
      await localStorage.deleteNoteLocally(noteId);

      // Remove from local list
      _notes.removeWhere((n) => n.id == noteId);
      notifyListeners();

      debugPrint('✅ Note deleted offline');

      // Try immediate sync if online
      _backgroundSyncNotes();

    } catch (e) {
      debugPrint('❌ Failed to delete note offline: $e');
      _error = 'Failed to delete note: ${e.toString()}';
      notifyListeners();
      rethrow;
    }
  }

  // Background sync for notes
  Future<void> _backgroundSyncNotes() async {
    if (_isOffline) return;

    try {
      final localStorage = await LocalStorage.init();

      // Check if sync is needed
      final shouldSync = await localStorage.shouldSyncNotes();
      if (!shouldSync) {
        debugPrint('📱 No note sync needed');
        return;
      }

      final unsyncedNotes = await localStorage.getUnsyncedNotes();
      if (unsyncedNotes.isEmpty) {
        debugPrint('📱 No unsynced notes found');
        return;
      }

      debugPrint('🔄 Background syncing ${unsyncedNotes.length} notes...');

      final syncResult = await _apiService.syncNotes(unsyncedNotes);
      final results = syncResult['results'] as List<dynamic>;

      // Process sync results
      for (int i = 0; i < results.length; i++) {
        final result = results[i];
        final localNote = unsyncedNotes[i];

        if (result['success'] == true) {
          // Mark as synced
          await localStorage.markNoteAsSynced(
            localNote.id,
            result['server_id']?.toString() ?? '',
          );

          // Update local list sync status
          final index = _notes.indexWhere((n) => n.id == localNote.id);
          if (index >= 0) {
            _notes[index] = _notes[index].copyWith(
              serverId: result['server_id']?.toString(),
              syncStatus: NoteSyncStatus.synced,
              syncedAt: DateTime.now(),
            );
          }
        } else {
          // Mark as failed
          await localStorage.markNoteAsFailed(
            localNote.id,
            result['error']?.toString() ?? 'Unknown error',
          );

          // Update local list sync status
          final index = _notes.indexWhere((n) => n.id == localNote.id);
          if (index >= 0) {
            _notes[index] = _notes[index].copyWith(
              syncStatus: NoteSyncStatus.failed,
            );
          }
        }
      }

      // Update last sync time
      await localStorage.setLastNoteSync(DateTime.now());

      debugPrint('✅ Background note sync completed');
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Background note sync failed: $e');
      _isOffline = true;
    }
  }

  // Manual sync for notes (called from UI)
  Future<void> syncNotes() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _backgroundSyncNotes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Sync failed: ${e.toString()}';
      notifyListeners();
    }
  }

  // Get sync status for notes
  Map<String, int> getNoteSyncStatus() {
    final synced = _notes.where((n) => n.isSynced).length;
    final pending = _notes.where((n) => n.isPending).length;
    final failed = _notes.where((n) => n.hasFailed).length;

    return {
      'synced': synced,
      'pending': pending,
      'failed': failed,
      'total': _notes.length,
    };
  }

  // ============================================================================
  // LEGACY METHODS (for backward compatibility)
  // ============================================================================

  @Deprecated('Use createNoteOffline instead')
  Future<void> createNote(Note note) async {
    await createNoteOffline(
      title: note.title,
      content: note.content,
      farmId: note.farmId,
      userId: note.userId,
      seasonId: note.seasonId,
    );
  }

  @Deprecated('Use updateNoteOffline instead')
  Future<void> updateNote(Note note) async {
    await updateNoteOffline(note);
  }

  @Deprecated('Use deleteNoteOffline instead')
  Future<void> deleteNote(String noteId) async {
    await deleteNoteOffline(noteId);
  }

  Future<void> createNoteForFarm({
    required String title,
    required String content,
    required String farmId,
    required String farmerId,
    required String userId,
  }) async {
    await createNoteOffline(
      title: title,
      content: content,
      farmId: farmId,
      userId: userId,
    );
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Sync functionality
  Future<void> syncWithServer() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get all farms that need syncing
      final farmsToSync = _farms.where((f) => !f.isSynced || f.isDeleted).toList();

      if (farmsToSync.isNotEmpty) {
        // Sync farms
        final syncResult = await _apiService.syncFarms(
          farmsToSync.map((f) => f.toJson()).toList(),
        );

        // Update local farms with sync status
        _farms = _farms.map((farm) {
          if (farmsToSync.any((f) => f.id == farm.id)) {
            return farm.copyWith(
              isSynced: true,
              lastSyncedAt: DateTime.now(),
            );
          }
          return farm;
        }).toList();

        // Remove locally deleted farms that have been synced
        _farms.removeWhere((f) => f.isDeleted && f.isSynced);
      }

      // Sync notes
      await _backgroundSyncNotes();

      _isLoading = false;
      _isOffline = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _isOffline = true;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final data = await _apiService.getInitialDataPackage();

      // Load farms
      if (data['farms'] != null) {
        _farms = (data['farms'] as List).map((json) => Farm.fromJson(json)).toList();
      }

      // Load seasons
      if (data['seasons'] != null) {
        _seasons = (data['seasons'] as List)
            .map((json) => Season.fromJson(json))
            .toList();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadFarmerNotes(String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _notes = await _apiService.getAllFarmerNotes();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}