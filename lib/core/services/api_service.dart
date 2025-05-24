import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/farm.dart';
import '../models/note.dart';
import '../models/season.dart';
import '../models/season_data.dart';

class ApiService {
  final String baseUrl;
  final http.Client _httpClient;

  ApiService({
    required this.baseUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  // Farms API
  Future<List<Farm>> getFarms(String farmerId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/farms/$farmerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> farmsData = responseData['data']['farms'];
          return farmsData.map((json) => Farm.fromJson(json)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load farms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load farms: $e');
    }
  }

  Future<Farm> getFarm(String farmId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/farms/$farmId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Farm.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load farm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load farm: $e');
    }
  }

  Future<Farm> createFarm(Farm farm) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/farms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(farm.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Farm.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create farm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create farm: $e');
    }
  }

  Future<Farm> updateFarm(String farmId, Farm farm) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/farms/$farmId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(farm.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Farm.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to update farm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update farm: $e');
    }
  }

  Future<void> deleteFarm(String farmId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/farms/$farmId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] != 'success') {
          throw Exception('Failed to delete farm: ${responseData['message']}');
        }
      } else {
        throw Exception('Failed to delete farm: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete farm: $e');
    }
  }

  // Seasons API
  Future<List<Season>> getSeasons(String farmId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/farms/$farmId/seasons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Season.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load seasons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load seasons: $e');
    }
  }

  Future<Season> getSeason(String seasonId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/seasons/$seasonId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Season.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load season: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load season: $e');
    }
  }

  Future<Season> createSeason(Season season) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/seasons'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(season.toJson()),
      );

      if (response.statusCode == 201) {
        return Season.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create season: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create season: $e');
    }
  }

  // Notes API
  Future<List<Note>> getFarmerNotes(String farmerId) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/notes/$farmerId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> notesData = responseData['data']['notes'];
          return notesData.map((json) => Note.fromJson(json)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load notes: $e');
    }
  }

  Future<Note> createNote(Note note) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/notes'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toJson()),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Note.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to create note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create note: $e');
    }
  }

  Future<Note> updateNote(Note note) async {
    try {
      final response = await _httpClient.put(
        Uri.parse('$baseUrl/notes/${note.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(note.toJson()),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return Note.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to update note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update note: $e');
    }
  }

  Future<void> deleteNote(String noteId) async {
    try {
      final response = await _httpClient.delete(
        Uri.parse('$baseUrl/notes/$noteId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete note: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to delete note: $e');
    }
  }

  // Seasonal Data API
  Future<SeasonData> getSeasonInfo(int monthNumber) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/seasons/$monthNumber'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return SeasonData.fromJson(responseData['data']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load season info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load season info: $e');
    }
  }

  Future<List<SeasonData>> getAllSeasons() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/seasons'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          final List<dynamic> seasonsData = responseData['data']['seasons'];
          return seasonsData.map((json) => SeasonData.fromJson(json)).toList();
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to load seasons: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load seasons: $e');
    }
  }

  // Sync Endpoints
  Future<DateTime> syncNotes(List<Note> notes) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/notes/sync'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'notes': notes.map((note) => note.toJson()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return DateTime.parse(responseData['data']['sync_timestamp']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to sync notes: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to sync notes: $e');
    }
  }

  Future<DateTime> syncFarms(List<Map<String, dynamic>> farms) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/sync/farms'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'farms': farms,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return DateTime.parse(responseData['data']['sync_timestamp']);
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception('Failed to sync farms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to sync farms: $e');
    }
  }

  Future<Map<String, dynamic>> getInitialDataPackage() async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl/sync/initial-package'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success' &&
            responseData['data'] != null) {
          return responseData['data'];
        }
        throw Exception('Invalid response format');
      } else {
        throw Exception(
            'Failed to load initial data package: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load initial data package: $e');
    }
  }
}
