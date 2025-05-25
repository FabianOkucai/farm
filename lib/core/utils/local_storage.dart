import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  static Future<LocalStorage> init() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String? getString(String key) {
    return _prefs.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  Future<void> setList(String key, List<Map<String, dynamic>> value) async {
    final jsonString = json.encode(value);
    await _prefs.setString(key, jsonString);
  }

  Future<List<Map<String, dynamic>>?> getList(String key) async {
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;

    final List<dynamic> decoded = json.decode(jsonString);
    return decoded.cast<Map<String, dynamic>>();
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }
}
