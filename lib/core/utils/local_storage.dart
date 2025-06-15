// lib/core/utils/local_storage.dart (Updated sections)
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../models/farm.dart';
import '../models/season.dart';
import '../models/note.dart';

class LocalStorage {
  final SharedPreferences _prefs;
  static LocalStorage? _instance;

  LocalStorage._(this._prefs);

  // Existing code...
  static const String uuidKey = 'uuid';
  static const String userDataKey = 'user_data';
  static const String farmsKey = 'farms';
  static const String seasonsKey = 'seasons';
  static const String notesKey = 'notes';
  static const String notificationsKey = 'notifications';
  static const String settingsKey = 'settings';
  static const String lastNoteSyncKey = 'last_note_sync';

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

  // Existing methods remain the same...
  Future<void> setUuid(String uuid) async {
    await setString(uuidKey, uuid);
  }

  String? getUuid() {
    return getString(uuidKey);
  }

  // Enhanced Notes methods for offline-first approach
  Future<void> storeNote(Note note) async {
    try {
      final notes = await getNotes() ?? [];

      // Check if note already exists (by local ID)
      final existingIndex = notes.indexWhere((n) => n['id'] == note.id);

      if (existingIndex >= 0) {
        // Update existing note
        notes[existingIndex] = note.toLocalJson();
      } else {
        // Add new note
        notes.add(note.toLocalJson());
      }

      await setList(notesKey, notes);
      debugPrint('📝 Stored note locally: ${note.title}');
    } catch (e) {
      debugPrint('❌ Failed to store note: $e');
      rethrow;
    }
  }

  Future<List<Note>> getNotesForFarm(String farmId) async {
    try {
      final notesData = await getNotes() ?? [];
      final farmNotes = notesData
          .where((noteData) => noteData['farm_id'] == farmId && (noteData['is_deleted'] ?? 0) == 0)
          .map((noteData) => Note.fromLocalJson(noteData))
          .toList();

      // Sort by creation date (newest first)
      farmNotes.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      debugPrint('📚 Retrieved ${farmNotes.length} notes for farm: $farmId');
      return farmNotes;
    } catch (e) {
      debugPrint('❌ Failed to get notes for farm: $e');
      return [];
    }
  }

  Future<List<Note>> getUnsyncedNotes() async {
    try {
      final notesData = await getNotes() ?? [];
      final unsyncedNotes = notesData
          .where((noteData) =>
      noteData['sync_status'] == 'pending' &&
          (noteData['is_deleted'] ?? 0) == 0)
          .map((noteData) => Note.fromLocalJson(noteData))
          .toList();

      debugPrint('🔄 Found ${unsyncedNotes.length} unsynced notes');
      return unsyncedNotes;
    } catch (e) {
      debugPrint('❌ Failed to get unsynced notes: $e');
      return [];
    }
  }

  Future<void> markNoteAsSynced(String localId, String serverId) async {
    try {
      final notes = await getNotes() ?? [];
      final noteIndex = notes.indexWhere((n) => n['id'] == localId);

      if (noteIndex >= 0) {
        notes[noteIndex]['server_id'] = serverId;
        notes[noteIndex]['sync_status'] = 'synced';
        notes[noteIndex]['synced_at'] = DateTime.now().toIso8601String();

        await setList(notesKey, notes);
        debugPrint('✅ Marked note as synced: $localId -> $serverId');
      }
    } catch (e) {
      debugPrint('❌ Failed to mark note as synced: $e');
    }
  }

  Future<void> markNoteAsFailed(String localId, String error) async {
    try {
      final notes = await getNotes() ?? [];
      final noteIndex = notes.indexWhere((n) => n['id'] == localId);

      if (noteIndex >= 0) {
        notes[noteIndex]['sync_status'] = 'failed';
        notes[noteIndex]['sync_error'] = error;
        notes[noteIndex]['last_sync_attempt'] = DateTime.now().toIso8601String();

        await setList(notesKey, notes);
        debugPrint('❌ Marked note as failed: $localId');
      }
    } catch (e) {
      debugPrint('❌ Failed to mark note as failed: $e');
    }
  }

  Future<void> deleteNoteLocally(String localId) async {
    try {
      final notes = await getNotes() ?? [];
      final noteIndex = notes.indexWhere((n) => n['id'] == localId);

      if (noteIndex >= 0) {
        notes[noteIndex]['is_deleted'] = 1;
        notes[noteIndex]['updated_at'] = DateTime.now().toIso8601String();

        // If not synced yet, we can remove it completely
        if (notes[noteIndex]['sync_status'] == 'pending') {
          notes.removeAt(noteIndex);
        } else {
          // Mark as deleted but keep for sync
          notes[noteIndex]['sync_status'] = 'pending';
        }

        await setList(notesKey, notes);
        debugPrint('🗑️ Deleted note locally: $localId');
      }
    } catch (e) {
      debugPrint('❌ Failed to delete note: $e');
    }
  }

  // Sync timestamp management
  Future<void> setLastNoteSync(DateTime timestamp) async {
    await setString(lastNoteSyncKey, timestamp.toIso8601String());
  }

  DateTime? getLastNoteSync() {
    final timestampStr = getString(lastNoteSyncKey);
    return timestampStr != null ? DateTime.parse(timestampStr) : null;
  }

  Future<bool> shouldSyncNotes() async {
    final lastSync = getLastNoteSync();
    if (lastSync == null) return true;

    // Sync every 24 hours or if there are failed notes
    final daysSinceSync = DateTime.now().difference(lastSync).inDays;
    final unsyncedNotes = await getUnsyncedNotes();

    return daysSinceSync >= 1 || unsyncedNotes.isNotEmpty;
  }

  // Existing methods remain the same...
  Future<void> setUserData(Map<String, dynamic> data) async {
    await setMap(userDataKey, data);
  }

  Map<String, dynamic>? getUserData() {
    return getMap(userDataKey);
  }

  Future<void> setFarms(List<Map<String, dynamic>> farms) async {
    await setList(farmsKey, farms);
  }

  Future<List<Map<String, dynamic>>?> getFarms() async {
    return await getList(farmsKey);
  }

  Future<void> setSeasons(List<Map<String, dynamic>> seasons) async {
    await setList(seasonsKey, seasons);
  }

  Future<List<Map<String, dynamic>>?> getSeasons() async {
    return await getList(seasonsKey);
  }

  Future<void> setNotes(List<Map<String, dynamic>> notes) async {
    await setList(notesKey, notes);
  }

  Future<List<Map<String, dynamic>>?> getNotes() async {
    return await getList(notesKey);
  }

  Future<void> setNotifications(List<Map<String, dynamic>> notifications) async {
    await setList(notificationsKey, notifications);
  }

  Future<List<Map<String, dynamic>>?> getNotifications() async {
    return await getList(notificationsKey);
  }

  Future<void> setSettings(Map<String, dynamic> settings) async {
    await setMap(settingsKey, settings);
  }

  Map<String, dynamic>? getSettings() {
    return getMap(settingsKey);
  }

  // Generic methods (keep existing implementation)
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