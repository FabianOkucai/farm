// lib/core/services/api_service.dart - Complete Updated Version

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/local_storage.dart';
import '../models/farm.dart';
import '../models/note.dart';
import '../models/season.dart';
import '../models/season_data.dart';
import '../../constants/config.dart';

class ApiService {
  final String baseUrl;
  final http.Client _httpClient;
  final LocalStorage _localStorage;
  bool _isOffline = false;

  ApiService({
    required this.baseUrl,
    required LocalStorage localStorage,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client(),
        _localStorage = localStorage {
    _checkConnectivity();
  }

  bool get isOffline => _isOffline;

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOffline = result.isEmpty || result[0].rawAddress.isEmpty;
    } on SocketException catch (_) {
      _isOffline = true;
    }
  }

  Future<Map<String, String>> _getHeaders() async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Add UUID header if available (for existing farmers)
    final uuid = _localStorage.getUuid();
    if (uuid != null && uuid.isNotEmpty) {
      headers['X-User-ID'] = uuid;
      debugPrint('🔑 Adding X-User-ID header: ${uuid.substring(0, 8)}...');
    } else {
      debugPrint('🆕 No UUID found - treating as first-time user');
    }

    return headers;
  }

  Future<dynamic> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (e) {
        debugPrint('Error parsing JSON response: $e');
        throw FormatException('Invalid JSON response from server');
      }
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized. Please log in again.');
    } else if (response.statusCode == 403) {
      throw Exception('Access forbidden');
    } else if (response.statusCode == 404) {
      throw Exception('Resource not found');
    } else if (response.statusCode >= 500) {
      throw Exception('Server error. Please try again later.');
    } else {
      try {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed with status ${response.statusCode}');
      }
    }
  }

  Future<dynamic> _makeRequest(
      String method,
      String endpoint, {
        Map<String, dynamic>? body,
        Map<String, String>? queryParams,
      }) async {
    if (_isOffline) {
      throw Exception('No internet connection. Working in offline mode.');
    }

    try {
      final headers = await _getHeaders();
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);

      http.Response response;
      switch (method.toUpperCase()) {
        case 'GET':
          response = await _httpClient.get(uri, headers: headers);
          break;
        case 'POST':
          response = await _httpClient.post(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await _httpClient.put(
            uri,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await _httpClient.delete(uri, headers: headers);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      return await _handleResponse(response);
    } on SocketException {
      _isOffline = true;
      throw Exception('No internet connection. Working in offline mode.');
    } on TimeoutException {
      throw Exception('Request timed out. Please try again.');
    } catch (e) {
      debugPrint('API request failed: $e');
      rethrow;
    }
  }

  // ============================================================================
  // FARM MANAGEMENT API
  // ============================================================================

  /// Create a farm with or without uuid. Returns {'farm': ..., 'uuid': ...}
  Future<Map<String, dynamic>> createFarmWithUuid(
      Farm farm, {
        String? uuid,
        String? farmerName,
      }) async {
    try {
      if (_isOffline) {
        return {
          'farm': _createMockFarm(farm),
          'uuid': uuid ?? 'mock_uuid_${DateTime.now().millisecondsSinceEpoch}',
          'current_season': _createMockCurrentSeason(),
          'all_seasons_summary': uuid == null ? _createMockAllSeasons() : null,
        };
      }

      // Build proper request payload
      Map<String, dynamic> requestBody;

      if (uuid == null || uuid.isEmpty) {
        // First farm - Laravel expects farmer + farm data
        debugPrint('🆕 Building first farm payload with farmer data');

        requestBody = {
          // Farmer information (required for first farm)
          'farmer_name': farmerName ?? 'Unknown Farmer',

          // Farm information with correct field names
          'farm_name': farm.name,
          'farm_size': farm.size,
          'farm_district': farm.district,
          'farm_village': farm.village,
          'planting_date': _formatDateForLaravel(farm.plantingDate),
        };

        debugPrint('📤 First farm payload: ${requestBody.keys.join(', ')}');
      } else {
        // Subsequent farm - Laravel expects only farm data
        debugPrint('🔄 Building subsequent farm payload (farm data only)');

        requestBody = {
          // Only farm information (no farmer data needed)
          'farm_name': farm.name,
          'farm_size': farm.size,
          'farm_district': farm.district,
          'farm_village': farm.village,
          'planting_date': _formatDateForLaravel(farm.plantingDate),
        };

        debugPrint('📤 Subsequent farm payload: ${requestBody.keys.join(', ')}');
      }

      debugPrint('📡 Sending farm creation request to: POST /farms');
      debugPrint('📋 Payload size: ${requestBody.length} fields');

      final response = await _makeRequest(
        'POST',
        '/farms',
        body: requestBody,
      );

      if (response['status'] == 'success') {
        final data = response['data'];
        debugPrint('✅ Backend accepted request successfully');

        // Handle different response structures
        Map<String, dynamic> result = {};

        // Extract farm data
        if (data['farm'] != null) {
          result['farm'] = data['farm'];
          debugPrint('✅ Farm data received: ${data['farm']['id']}');
        }

        // Extract UUID (for first farm only)
        if (data['farmer_uuid'] != null) {
          result['uuid'] = data['farmer_uuid'];
          debugPrint('🔑 New farmer UUID: ${data['farmer_uuid']}');
        } else if (uuid != null) {
          result['uuid'] = uuid;
          debugPrint('🔑 Using existing UUID: ${uuid.substring(0, 8)}...');
        }

        // Extract current season
        if (data['current_season'] != null) {
          result['current_season'] = data['current_season'];
          debugPrint('🌱 Current season: Month ${data['current_season']['month']}');
        }

        // Extract all seasons summary (first farm only)
        if (data['all_seasons_summary'] != null) {
          result['all_seasons_summary'] = data['all_seasons_summary'];
          debugPrint('📅 Seasons summary: ${data['all_seasons_summary'].length} seasons');
        }

        return result;
      } else {
        throw Exception(response['message'] ?? 'Failed to create farm');
      }
    } catch (e) {
      debugPrint('❌ Farm creation failed: $e');
      _isOffline = true;

      // Return mock data as fallback
      return {
        'farm': _createMockFarm(farm),
        'uuid': uuid ?? 'mock_uuid_${DateTime.now().millisecondsSinceEpoch}',
        'current_season': _createMockCurrentSeason(),
        'all_seasons_summary': uuid == null ? _createMockAllSeasons() : null,
      };
    }
  }

  // Helper method for date formatting
  String _formatDateForLaravel(DateTime date) {
    // Convert from: 2023-03-15T10:30:00.000Z
    // Convert to:   2023-03-15
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // Helper method to create mock current season
  Map<String, dynamic> _createMockCurrentSeason() {
    return {
      'month': 1,
      'title': 'Land Preparation',
      'short_description': 'Prepare the land for mango planting',
      'full_instructions': 'Clear the land, test soil pH, and prepare planting holes...',
      'activities': [
        {
          'title': 'Soil Testing',
          'description': 'Test soil pH and nutrient levels'
        },
        {
          'title': 'Land Clearing',
          'description': 'Clear weeds and prepare the field'
        }
      ]
    };
  }

  // Helper method to create mock all seasons
  List<Map<String, dynamic>> _createMockAllSeasons() {
    return List.generate(12, (index) => {
      'month': index + 1,
      'title': 'Month ${index + 1} Activities',
      'short_description': 'Important activities for month ${index + 1}',
    });
  }

  // Load farms with metadata
  Future<Map<String, dynamic>> getFarmsWithMetadata() async {
    try {
      debugPrint('🌐 Loading farms with metadata...');

      final response = await _makeRequest('GET', '/farms');

      if (response['status'] == 'success') {
        final data = response['data'];
        final List<dynamic> farmsData = data['farms'];

        return {
          'farms': farmsData.map((json) => Farm.fromJson(json)).toList(),
          'total_farms': data['total_farms'],
          'total_size': data['total_size'],
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to load farms');
      }
    } catch (e) {
      debugPrint('❌ Failed to load farms with metadata: $e');

      // Fallback to local storage
      final farms = await _localStorage.getFarms();
      if (farms != null) {
        final farmsList = farms.map((json) => Farm.fromJson(json)).toList();
        return {
          'farms': farmsList,
          'total_farms': farmsList.length,
          'total_size': farmsList.fold(0.0, (sum, farm) => sum + farm.size),
        };
      }
      rethrow;
    }
  }

  Future<List<Farm>> getFarms() async {
    try {
      debugPrint('🌐 Loading farms for authenticated user...');

      final response = await _makeRequest('GET', '/farms');

      if (response['status'] == 'success') {
        final List<dynamic> farmsData = response['data']['farms'];
        final totalFarms = response['data']['total_farms'];
        final totalSize = response['data']['total_size'];

        debugPrint('✅ Loaded $totalFarms farms with total size: $totalSize');

        return farmsData.map((json) => Farm.fromJson(json)).toList();
      } else {
        throw Exception(response['message'] ?? 'Failed to load farms');
      }
    } catch (e) {
      debugPrint('❌ Failed to load farms: $e');

      // If online request fails, try to get from local storage
      final farms = await _localStorage.getFarms();
      if (farms != null) {
        debugPrint('📱 Using cached farms from local storage');
        return farms.map((json) => Farm.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  Future<Farm> getFarm(String farmId) async {
    try {
      final response = await _makeRequest('GET', '/farms/$farmId');
      return Farm.fromJson(response['data']);
    } catch (e) {
      // If online request fails, try to get from local storage
      final farm = await _localStorage.getFarm(farmId);
      if (farm != null) {
        return Farm.fromJson(farm);
      }
      rethrow;
    }
  }

  Future<Farm> createFarm(Farm farm) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/farms',
        body: farm.toJson(),
      );
      return Farm.fromJson(response['data']);
    } catch (e) {
      // If online request fails, try to get from local storage
      final savedFarm = await _localStorage.getFarm(farm.id);
      if (savedFarm != null) {
        return Farm.fromJson(savedFarm);
      }
      rethrow;
    }
  }

  Future<Farm> updateFarm(String farmId, Farm farm) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/farms/$farmId',
        body: farm.toJson(),
      );
      return Farm.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFarm(String farmId) async {
    await _makeRequest('DELETE', '/farms/$farmId');
  }

  // ============================================================================
  // NOTES API - UPDATED FOR OFFLINE-FIRST APPROACH
  // ============================================================================

  /// Sync notes to backend (bulk sync)
  Future<Map<String, dynamic>> syncNotes(List<Note> unsyncedNotes) async {
    try {
      debugPrint('🔄 Syncing ${unsyncedNotes.length} notes to backend...');

      if (unsyncedNotes.isEmpty) {
        return {'synced_count': 0, 'failed_count': 0, 'results': []};
      }

      // Prepare notes for sync
      final notesToSync = unsyncedNotes.map((note) => note.toSyncJson()).toList();

      debugPrint('📤 Sending notes sync request: POST /notes/sync');
      debugPrint('📋 Notes to sync: ${notesToSync.length}');

      final response = await _makeRequest(
        'POST',
        '/notes/sync',
        body: {'notes': notesToSync},
      );

      if (response['status'] == 'success') {
        final results = response['data']['results'] as List<dynamic>;
        final syncedCount = response['data']['synced_count'] as int;
        final failedCount = response['data']['failed_count'] as int;

        debugPrint('✅ Notes sync completed: $syncedCount synced, $failedCount failed');

        return {
          'synced_count': syncedCount,
          'failed_count': failedCount,
          'results': results,
        };
      } else {
        throw Exception(response['message'] ?? 'Failed to sync notes');
      }
    } catch (e) {
      debugPrint('❌ Failed to sync notes: $e');

      // Return failure result for all notes
      final results = unsyncedNotes.map((note) => {
        'local_id': note.id,
        'success': false,
        'error': e.toString(),
      }).toList();

      return {
        'synced_count': 0,
        'failed_count': unsyncedNotes.length,
        'results': results,
      };
    }
  }

  /// Get all farmer notes from backend
  Future<List<Note>> getAllFarmerNotes() async {
    try {
      debugPrint('📚 Loading all farmer notes...');

      final response = await _makeRequest('GET', '/notes');

      if (response['status'] == 'success') {
        final List<dynamic> notesData = response['data']['notes'];
        final notes = notesData.map((json) => Note.fromJson(json)).toList();

        debugPrint('✅ Loaded ${notes.length} notes from backend');
        return notes;
      } else {
        throw Exception(response['message'] ?? 'Failed to load notes');
      }
    } catch (e) {
      debugPrint('❌ Failed to load farmer notes: $e');
      rethrow;
    }
  }

  /// Download and sync all notes from backend to local storage
  Future<void> downloadAndSyncNotes() async {
    try {
      debugPrint('📥 Downloading notes from backend...');

      final backendNotes = await getAllFarmerNotes();

      // Store backend notes locally (these override local ones)
      for (final note in backendNotes) {
        await _localStorage.storeNote(note.copyWith(
          syncStatus: NoteSyncStatus.synced,
          syncedAt: DateTime.now(),
        ));
      }

      debugPrint('✅ Downloaded and stored ${backendNotes.length} notes locally');
    } catch (e) {
      debugPrint('❌ Failed to download notes: $e');
      rethrow;
    }
  }

  // ============================================================================
  // SEASONS API
  // ============================================================================

  Future<List<Season>> getSeasons(String farmId) async {
    try {
      final response = await _makeRequest('GET', '/farms/$farmId/seasons');
      final List<dynamic> data = response['data'];
      return data.map((json) => Season.fromJson(json)).toList();
    } catch (e) {
      // If online request fails, try to get from local storage
      final seasons = await _localStorage.getSeasons();
      if (seasons != null) {
        return seasons.map((json) => Season.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  Future<Season> getSeason(String seasonId) async {
    try {
      final response = await _makeRequest('GET', '/seasons/$seasonId');
      return Season.fromJson(response['data']);
    } catch (e) {
      // If online request fails, try to get from local storage
      final season = await _localStorage.getSeason(seasonId);
      if (season != null) {
        return Season.fromJson(season);
      }
      rethrow;
    }
  }

  Future<Season> createSeason(Season season) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/seasons',
        body: season.toJson(),
      );
      return Season.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Season> updateSeason(String seasonId, Season season) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/seasons/$seasonId',
        body: season.toJson(),
      );
      return Season.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSeason(String seasonId) async {
    await _makeRequest('DELETE', '/seasons/$seasonId');
  }

  // ============================================================================
  // SEASONAL DATA API
  // ============================================================================

  Future<Map<String, dynamic>?> getCurrentSeasonForFarm(String farmId) async {
    try {
      debugPrint('🌱 Getting current season for farm: $farmId');

      final response = await _makeRequest('GET', '/farms/$farmId/current-season');

      if (response['status'] == 'success') {
        return response['data'];
      } else {
        throw Exception(response['message'] ?? 'Failed to get current season');
      }
    } catch (e) {
      debugPrint('❌ Failed to get current season for farm: $e');
      return null;
    }
  }

  Future<SeasonData> getSeasonInfo(int monthNumber) async {
    try {
      final response = await _makeRequest('GET', '/seasons/$monthNumber');
      return SeasonData.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SeasonData>> getAllSeasons() async {
    try {
      final response = await _makeRequest('GET', '/seasons');
      final List<dynamic> seasonsData = response['data']['seasons'];
      return seasonsData.map((json) => SeasonData.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // ============================================================================
  // SYNC ENDPOINTS
  // ============================================================================

  Future<DateTime> syncFarms(List<Map<String, dynamic>> farms) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/sync/farms',
        body: {'farms': farms},
      );
      return DateTime.parse(response['sync_timestamp']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getInitialDataPackage() async {
    try {
      final response = await _makeRequest('GET', '/initial-data');
      return response['data'];
    } catch (e) {
      // If online request fails, try to get from local storage
      final farms = await _localStorage.getFarms();
      final seasons = await _localStorage.getSeasons();
      final notes = await _localStorage.getNotes();

      return {'farms': farms, 'seasons': seasons, 'notes': notes};
    }
  }

  // ============================================================================
  // DEPRECATED METHODS (for backward compatibility)
  // ============================================================================

  @Deprecated('Use syncNotes and local storage instead')
  Future<List<Note>> getFarmerNotes(String farmerId) async {
    // Keep for backward compatibility but redirect to new method
    return await getAllFarmerNotes();
  }

  @Deprecated('Use local storage and sync instead')
  Future<Note> createNote(Note note) async {
    // This should not be used anymore - notes are created locally
    throw UnsupportedError('Use local storage for note creation');
  }

  @Deprecated('Use local storage and sync instead')
  Future<Note> updateNote(Note note) async {
    // This should not be used anymore - notes are updated locally
    throw UnsupportedError('Use local storage for note updates');
  }

  @Deprecated('Use local storage and sync instead')
  Future<void> deleteNote(String noteId) async {
    // This should not be used anymore - notes are deleted locally
    throw UnsupportedError('Use local storage for note deletion');
  }

  // ============================================================================
  // MOCK DATA HELPERS
  // ============================================================================

  List<Farm> _getMockFarms(String farmerId) {
    return [
      Farm(
        id: 'farm_1',
        name: 'Mango Farm 1',
        size: 5.0,
        district: 'Central District',
        village: 'Green Village',
        farmerId: farmerId,
        plantingDate: DateTime(2023, 1, 15),
        currentSeasonMonth: 3,
        createdAt: DateTime.now().subtract(const Duration(days: 90)),
        updatedAt: DateTime.now(),
      ),
      Farm(
        id: 'farm_2',
        name: 'Mango Farm 2',
        size: 3.5,
        district: 'Eastern District',
        village: 'Palm Village',
        farmerId: farmerId,
        plantingDate: DateTime(2023, 3, 20),
        currentSeasonMonth: 1,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  Farm _getMockFarm(String farmId) {
    return Farm(
      id: farmId,
      name: 'Mock Farm',
      size: 4.0,
      district: 'Sample District',
      village: 'Sample Village',
      farmerId: 'mock_farmer_id',
      plantingDate: DateTime.now().subtract(const Duration(days: 60)),
      currentSeasonMonth: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 60)),
      updatedAt: DateTime.now(),
    );
  }

  Farm _createMockFarm(Farm farm) {
    return farm.copyWith(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  void dispose() {
    _httpClient.close();
  }
}