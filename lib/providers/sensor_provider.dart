import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/app_settings.dart';
import '../models/sensor_data.dart';
import '../services/ha_api_service.dart';
import '../services/sensor_collector_service.dart';
import '../services/storage_service.dart';

class SensorProvider extends ChangeNotifier {
  final SensorCollectorService _collector = SensorCollectorService();
  final HaApiService _haApi = HaApiService();
  final StorageService _storage = StorageService();

  AppSettings _settings = AppSettings();
  HaSyncResult? _lastSyncResult;
  bool _isSyncing = false;
  Timer? _syncTimer;

  SensorData get data => _collector.data;
  AppSettings get settings => _settings;
  HaSyncResult? get lastSyncResult => _lastSyncResult;
  bool get isSyncing => _isSyncing;

  Future<void> initialize() async {
    _settings = await _storage.loadSettings();
    notifyListeners();

    await _collector.initialize(() {
      notifyListeners();
    });

    _setupSyncTimer();
  }

  void _setupSyncTimer() {
    _syncTimer?.cancel();
    if (!_settings.autoSyncEnabled || _settings.syncIntervalSeconds <= 0) {
      return;
    }

    _syncTimer = Timer.periodic(
      Duration(seconds: _settings.syncIntervalSeconds),
      (_) => syncNow(),
    );
  }

  Future<HaSyncResult> syncNow() async {
    if (_isSyncing) {
      return _lastSyncResult ?? HaSyncResult(success: false, sentCount: 0);
    }

    _isSyncing = true;
    notifyListeners();

    try {
      final result = await _haApi.syncSensors(
        settings: _settings,
        sensorData: _collector.data,
      );
      _lastSyncResult = result;
      return result;
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<bool> testHaConnection(String url, String token) async {
    return await _haApi.testConnection(url, token);
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    final intervalChanged = _settings.syncIntervalSeconds != newSettings.syncIntervalSeconds;
    final autoSyncChanged = _settings.autoSyncEnabled != newSettings.autoSyncEnabled;

    _settings = newSettings;
    await _storage.saveSettings(_settings);
    notifyListeners();

    if (intervalChanged || autoSyncChanged) {
      _setupSyncTimer();
    }
  }

  Future<void> refreshLocation() async {
    await _collector.refreshLocation();
    notifyListeners();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _collector.dispose();
    super.dispose();
  }
}
