// Updated FarmProvider.dart

import 'package:flutter/material.dart';
import '../../core/models/farm.dart';
import '../../core/models/note.dart';
import '../../core/models/season.dart';
import '../../core/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../core/utils/local_storage.dart';
import '../../presentation/providers/auth_provider.dart';

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
  List<FarmActivity> _activities = []; // Added activities list

  bool _isLoading = false;
  String? _error;

  FarmProvider({required ApiService apiService}) : _apiService = apiService;

  List<Farm> get farms => _farms;
  Farm? get selectedFarm => _selectedFarm;
  List<Season> get seasons => _seasons;
  Season? get selectedSeason => _selectedSeason;
  List<Note> get notes => _notes;
  List<FarmActivity> get activities => _activities; // Updated getter
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get current season data for a specific farm
  Future<Map<String, dynamic>?> getCurrentSeasonData(String farmId) async {
    try {
      debugPrint('🌱 Loading current season data for farm: $farmId');

      if (_apiService.isOffline) {
        // Try to get from local cache
        final localStorage = await LocalStorage.init();
        final cachedData = localStorage.getMap('current_season_$farmId');
        if (cachedData != null) {
          debugPrint('📱 Using cached season data');
          return cachedData;
        }
        throw Exception('No cached data available');
      }

      // Make API call to get farm with current season
      final response = await _apiService.getFarmWithCurrentSeason(farmId);

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;

        // Cache the response for offline use
        final localStorage = await LocalStorage.init();
        await localStorage.setMap('current_season_$farmId', data);

        debugPrint('✅ Season data loaded and cached for farm $farmId');
        return data;
      } else {
        throw Exception(response['message'] ?? 'Failed to load season data');
      }
    } catch (e) {
      debugPrint('❌ Failed to load season data: $e');

      // Try to get from local cache as fallback
      try {
        final localStorage = await LocalStorage.init();
        final cachedData = localStorage.getMap('current_season_$farmId');
        if (cachedData != null) {
          debugPrint('📱 Using cached season data as fallback');
          return cachedData;
        }
      } catch (cacheError) {
        debugPrint('❌ Failed to load from cache: $cacheError');
      }

      return null;
    }
  }

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

      // 🔄 Call the NEW API method
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
      notifyListeners();
      rethrow;
    }
  }

// Add these helper methods to store seasons data
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

// UPDATE: Replace the existing loadFarms method
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
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Failed to load farms: $e');
      _isLoading = false;
      _error = 'Unable to load farms. Please check your connection.';

      // Try to load from local cache
      await _loadFromLocalCache();
      notifyListeners();
    }
  }

// ADD: New method to load from local cache
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

// UPDATE: Enhance selectFarm to persist selection
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

// ADD: Get farm statistics for dashboard
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

  Future<void> loadNotes(String farmId, String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get all farmer notes and filter by farmId
      final allNotes = await _apiService.getFarmerNotes(farmerId);
      _notes = allNotes.where((note) => note.farmId == farmId).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newNote = await _apiService.createNote(note);
      _notes.add(newNote);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedNote = await _apiService.updateNote(note);

      final index = _notes.indexWhere((n) => n.id == note.id);
      if (index != -1) {
        _notes[index] = updatedNote;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteNote(String noteId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Mark note as deleted locally
      final index = _notes.indexWhere((note) => note.id == noteId);
      if (index != -1) {
        _notes[index] = _notes[index].copyWith(isDeleted: true);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> createNoteForFarm({
    required String title,
    required String content,
    required String farmId,
    required String farmerId,
    required String userId,
  }) async {
    final note = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID
      farmId: farmId,
      userId: userId,
      title: title,
      content: content,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await createNote(note);
  }

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
      final farmsToSync =
      _farms.where((f) => !f.isSynced || f.isDeleted).toList();

      if (farmsToSync.isNotEmpty) {
        // Sync farms
        final syncResult = await _apiService.syncFarms(
          farmsToSync.map((f) => f.toJson()).toList(),
        );

        // Update local farms with sync status
        _farms =
            _farms.map((farm) {
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
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

      // Update farmer data if needed
      // This would typically be handled by the AuthProvider

      // Load farms
      if (data['farms'] != null) {
        _farms =
            (data['farms'] as List).map((json) => Farm.fromJson(json)).toList();
      }

      // Load seasons
      if (data['seasons'] != null) {
        _seasons =
            (data['seasons'] as List)
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
      _notes = await _apiService.getFarmerNotes(farmerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }
}