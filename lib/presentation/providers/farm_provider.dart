// Updated FarmProvider.dart

import 'package:flutter/material.dart';
import '../../core/models/farm.dart';
import '../../core/models/note.dart';
import '../../core/models/season.dart';
import '../../core/services/api_service.dart';

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

  Future<void> loadFarms(String farmerId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _farms = await _apiService.getFarms(farmerId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Unable to load farms. Working in offline mode.';
      notifyListeners();
    }
  }

  Future<void> selectFarm(String farmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // First try to find the farm in the local list
      final localFarm = _farms.firstWhere(
        (farm) => farm.id == farmId,
        orElse: () => null as Farm,
      );

      if (localFarm != null) {
        _selectedFarm = localFarm;
      } else {
        _selectedFarm = await _apiService.getFarm(farmId);
        // Add to local list if not already present
        if (!_farms.any((farm) => farm.id == _selectedFarm!.id)) {
          _farms.add(_selectedFarm!);
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = 'Unable to select farm. Working in offline mode.';
      notifyListeners();
    }
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

  Future<void> updateFarm(String farmId, Farm farm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedFarm = await _apiService.updateFarm(farmId, farm);
      final index = _farms.indexWhere((f) => f.id == farmId);
      if (index != -1) {
        _farms[index] = updatedFarm;
      }
      if (_selectedFarm?.id == farmId) {
        _selectedFarm = updatedFarm;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteFarm(String farmId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.deleteFarm(farmId);
      _farms.removeWhere((farm) => farm.id == farmId);
      if (_selectedFarm?.id == farmId) {
        _selectedFarm = null;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
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
  Future<void> syncFarms() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final farmsToSync =
          _farms
              .map(
                (farm) => {
                  'farm_id': farm.id,
                  'name': farm.name,
                  'current_season_month': farm.currentSeasonMonth,
                  'last_local_update': farm.updatedAt.toIso8601String(),
                },
              )
              .toList();

      final syncTimestamp = await _apiService.syncFarms(farmsToSync);

      // Update local farms with sync timestamp
      _farms =
          _farms
              .map((farm) => farm.copyWith(lastSyncedAt: syncTimestamp))
              .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> syncNotes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Filter notes that need syncing (not synced or deleted)
      final notesToSync =
          _notes.where((note) => !note.isSynced || note.isDeleted).toList();

      if (notesToSync.isNotEmpty) {
        final syncTimestamp = await _apiService.syncNotes(notesToSync);

        // Update local notes with sync status
        _notes =
            _notes.map((note) {
              if (notesToSync.any((n) => n.id == note.id)) {
                return note.copyWith(isSynced: true);
              }
              return note;
            }).toList();

        // Remove locally deleted notes that have been synced
        _notes.removeWhere((note) => note.isDeleted && note.isSynced);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
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
