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
  /// Create a farm with or without uuid. Returns {'farm': ..., 'uuid': ...}
  Future<Map<String, dynamic>> createFarmWithUuid(
    Farm farm, {
    String? uuid,
  }) async {
    try {
      if (_isOffline) {
        return {'farm': _createMockFarm(farm), 'uuid': uuid ?? 'mock_uuid'};
      }
      final Map<String, dynamic> payload = farm.toJson();
      if (uuid != null && uuid.isNotEmpty) {
        payload['uuid'] = uuid;
      }
      final response = await _httpClient.post(
        Uri.parse('baseUrl/farms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final farmData = responseData['data']['farm'] ?? responseData['data'];
          final returnedUuid = responseData['data']['uuid'] ?? uuid;
          return {'farm': farmData, 'uuid': returnedUuid};
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create farm: {response.statusCode}');
      }
    } catch (e) {
      _isOffline = true;
      return {'farm': _createMockFarm(farm), 'uuid': uuid ?? 'mock_uuid'};
    }
  }

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

    // Add auth token if available
    final userData = _localStorage.getUserData();
    if (userData != null && userData['token'] != null) {
      headers['Authorization'] = 'Bearer ${userData['token']}';
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

  // Farms API
  Future<List<Farm>> getFarms(String farmerId) async {
    try {
      final response = await _makeRequest('GET', '/farms/$farmerId');
      final List<dynamic> farmsData = response['data']['farms'];
      return farmsData.map((json) => Farm.fromJson(json)).toList();
    } catch (e) {
      // If online request fails, try to get from local storage
      final farms = await _localStorage.getFarms();
      if (farms != null) {
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

  // Seasons API
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

  // Notes API
  Future<List<Note>> getFarmerNotes(String farmerId) async {
    try {
      final response = await _makeRequest('GET', '/notes/$farmerId');
      final List<dynamic> notesData = response['data']['notes'];
      return notesData.map((json) => Note.fromJson(json)).toList();
    } catch (e) {
      // If online request fails, try to get from local storage
      final notes = await _localStorage.getNotes();
      if (notes != null) {
        return notes.map((json) => Note.fromJson(json)).toList();
      }
      rethrow;
    }
  }

  Future<Note> createNote(Note note) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/notes',
        body: note.toJson(),
      );
      return Note.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final response = await _makeRequest(
        'PUT',
        '/notes/${note.id}',
        body: note.toJson(),
      );
      return Note.fromJson(response['data']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteNote(String noteId) async {
    await _makeRequest('DELETE', '/notes/$noteId');
  }

  // Seasonal Data API
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

  // Sync Endpoints
  Future<DateTime> syncNotes(List<Note> notes) async {
    try {
      final response = await _makeRequest(
        'POST',
        '/sync/notes',
        body: {'notes': notes.map((n) => n.toJson()).toList()},
      );
      return DateTime.parse(response['sync_timestamp']);
    } catch (e) {
      rethrow;
    }
  }

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

  // Mock data helpers
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
