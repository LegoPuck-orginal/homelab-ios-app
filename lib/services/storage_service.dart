import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_settings.dart';
import '../models/service_item.dart';

class StorageService {
  static const String _keySettings = 'app_settings';
  static const String _keyCustomServices = 'custom_services';

  Future<AppSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keySettings);
    if (jsonStr == null || jsonStr.isEmpty) {
      return AppSettings();
    }
    try {
      final map = jsonDecode(jsonStr) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (_) {
      return AppSettings();
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = jsonEncode(settings.toJson());
    await prefs.setString(_keySettings, jsonStr);
  }

  Future<List<ServiceItem>> loadCustomServices() async {
    final prefs = await SharedPreferences.getInstance();
    final listStr = prefs.getStringList(_keyCustomServices);
    if (listStr == null || listStr.isEmpty) {
      return [];
    }
    final List<ServiceItem> items = [];
    for (final s in listStr) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        items.add(ServiceItem.fromJson(map));
      } catch (_) {}
    }
    return items;
  }

  Future<void> saveCustomServices(List<ServiceItem> services) async {
    final prefs = await SharedPreferences.getInstance();
    final listStr = services.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList(_keyCustomServices, listStr);
  }
}
