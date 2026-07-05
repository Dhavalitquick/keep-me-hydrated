import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/water_data.dart';

class StorageService {
  static const String _waterDataKey = 'water_data';
  static const String _settingsKey = 'app_settings';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  Future<void> saveWaterData(WaterData data) async {
    await _prefs.setString(_waterDataKey, jsonEncode(data.toJson()));
  }

  Future<void> saveHistory(List<WaterData> history) async {
    final historyList = history.map((e) => e.toJson()).toList();
    await _prefs.setString('water_history', jsonEncode(historyList));
  }

  List<WaterData> getHistory() {
    final String? historyString = _prefs.getString('water_history');
    if (historyString == null) return [];
    final List decoded = jsonDecode(historyString);
    return decoded.map((e) => WaterData.fromJson(e)).toList();
  }

  WaterData? getWaterData() {
    final String? dataString = _prefs.getString(_waterDataKey);
    if (dataString == null) return null;
    return WaterData.fromJson(jsonDecode(dataString));
  }

  Future<void> saveSettings(int interval, bool enabled, bool darkMode) async {
    final settings = {
      'interval': interval,
      'enabled': enabled,
      'darkMode': darkMode,
    };
    await _prefs.setString(_settingsKey, jsonEncode(settings));
  }

  Map<String, dynamic>? getSettings() {
    final String? settingsString = _prefs.getString(_settingsKey);
    if (settingsString == null) return null;
    return jsonDecode(settingsString);
  }
}
