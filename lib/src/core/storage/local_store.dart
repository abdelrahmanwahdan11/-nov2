import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class LocalStore {
  LocalStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalStore> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStore(prefs);
  }

  bool? getBool(String key) => _prefs.getBool(key);
  String? getString(String key) => _prefs.getString(key);

  void setBool(String key, bool value) {
    _prefs.setBool(key, value);
  }

  void setString(String key, String value) {
    _prefs.setString(key, value);
  }

  Future<void> seedFromAssets(Map<String, String> files) async {
    for (final entry in files.entries) {
      final data = await rootBundle.loadString(entry.value);
      await _prefs.setString(entry.key, data);
    }
  }

  T? get<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    return decodeOne<T>(raw);
  }

  void setModel<T>(String key, T value) {
    _prefs.setString(key, encodeOne(value));
  }

  List<T> getList<T>(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) {
      return <T>[];
    }
    try {
      return decodeList<T>(raw);
    } catch (_) {
      return <T>[];
    }
  }

  void saveList<T>(String key, List<T> list) {
    _prefs.setString(key, encodeList(list));
  }

  void clearKey(String key) {
    _prefs.remove(key);
  }

  void reset() {
    _prefs.clear();
  }
}
