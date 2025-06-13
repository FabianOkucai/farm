import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../models/season.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  static LocalStorage? _instance;

  LocalStorage._(this._prefs);

  // UUID helpers
  static const String uuidKey = 'uuid';
  static const String userDataKey = 'user_data';
  static const String farmsKey = 'farms';
  static const String seasonsKey = 'seasons';
  static const String notesKey = 'notes';
  static const String notificationsKey = 'notifications';
  static const String settingsKey = 'settings';

  static Future<LocalStorage> init() async {
    if (_instance != null) return _instance!;

    try {
      final prefs = await SharedPreferences.getInstance();
      _instance = LocalStorage._(prefs);
      return _instance!;
    } catch (e) {
      debugPrint('Failed to initialize LocalStorage: $e');
      rethrow;
    }
  }

  // UUID methods
  Future<void> setUuid(String uuid) async {
    await setString(uuidKey, uuid);
  }

  String? getUuid() {
    return getString(uuidKey);
  }

  // User data methods
  Future<void> setUserData(Map<String, dynamic> data) async {
    await setMap(userDataKey, data);
  }

  Map<String, dynamic>? getUserData() {
    return getMap(userDataKey);
  }

  // Farms methods
  Future<void> setFarms(List<Map<String, dynamic>> farms) async {
    await setList(farmsKey, farms);
  }

  Future<List<Map<String, dynamic>>?> getFarms() async {
    return await getList(farmsKey);
  }

  // Seasons methods
  Future<void> setSeasons(List<Map<String, dynamic>> seasons) async {
    await setList(seasonsKey, seasons);
  }

  Future<List<Map<String, dynamic>>?> getSeasons() async {
    return await getList(seasonsKey);
  }

  // Notes methods
  Future<void> setNotes(List<Map<String, dynamic>> notes) async {
    await setList(notesKey, notes);
  }

  Future<List<Map<String, dynamic>>?> getNotes() async {
    return await getList(notesKey);
  }

  // Notifications methods
  Future<void> setNotifications(
    List<Map<String, dynamic>> notifications,
  ) async {
    await setList(notificationsKey, notifications);
  }

  Future<List<Map<String, dynamic>>?> getNotifications() async {
    return await getList(notificationsKey);
  }

  // Settings methods
  Future<void> setSettings(Map<String, dynamic> settings) async {
    await setMap(settingsKey, settings);
  }

  Map<String, dynamic>? getSettings() {
    return getMap(settingsKey);
  }

  // Generic methods
  Future<void> setString(String key, String value) async {
    try {
      await _prefs.setString(key, value);
    } catch (e) {
      debugPrint('Failed to set string for key $key: $e');
      rethrow;
    }
  }

  String? getString(String key) {
    try {
      return _prefs.getString(key);
    } catch (e) {
      debugPrint('Failed to get string for key $key: $e');
      return null;
    }
  }

  Future<void> setBool(String key, bool value) async {
    try {
      await _prefs.setBool(key, value);
    } catch (e) {
      debugPrint('Failed to set bool for key $key: $e');
      rethrow;
    }
  }

  bool? getBool(String key) {
    try {
      return _prefs.getBool(key);
    } catch (e) {
      debugPrint('Failed to get bool for key $key: $e');
      return null;
    }
  }

  Future<void> setMap(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = json.encode(value);
      await _prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Failed to set map for key $key: $e');
      rethrow;
    }
  }

  Map<String, dynamic>? getMap(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('Failed to get map for key $key: $e');
      return null;
    }
  }

  Future<void> setList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = json.encode(value);
      await _prefs.setString(key, jsonString);
    } catch (e) {
      debugPrint('Failed to set list for key $key: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> getList(String key) async {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final List<dynamic> decoded = json.decode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      debugPrint('Failed to get list for key $key: $e');
      return null;
    }
  }

  Future<void> remove(String key) async {
    try {
      await _prefs.remove(key);
    } catch (e) {
      debugPrint('Failed to remove key $key: $e');
      rethrow;
    }
  }

  Future<void> clear() async {
    try {
      await _prefs.clear();
    } catch (e) {
      debugPrint('Failed to clear storage: $e');
      rethrow;
    }
  }

  Future<bool> containsKey(String key) async {
    try {
      return _prefs.containsKey(key);
    } catch (e) {
      debugPrint('Failed to check key $key: $e');
      return false;
    }
  }

  Future<void> reload() async {
    try {
      await _prefs.reload();
    } catch (e) {
      debugPrint('Failed to reload storage: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> getFarm(String farmId) async {
    try {
      final farms = await getFarms();
      if (farms != null) {
        return farms.firstWhere(
          (farm) => farm['id'] == farmId,
          orElse: () => <String, dynamic>{},
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting farm: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getSeason(String seasonId) async {
    try {
      final seasons = await getSeasons();
      if (seasons != null) {
        return seasons.firstWhere(
          (season) => season['id'] == seasonId,
          orElse: () => <String, dynamic>{},
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error getting season: $e');
      return null;
    }
  }
}
