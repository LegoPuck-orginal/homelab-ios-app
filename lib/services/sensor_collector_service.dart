import 'dart:async';
import 'dart:io';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:pedometer/pedometer.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/sensor_data.dart';

class SensorCollectorService {
  final SensorData data = SensorData();

  final Battery _battery = Battery();
  final Connectivity _connectivity = Connectivity();
  final NetworkInfo _networkInfo = NetworkInfo();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final ScreenBrightness _screenBrightness = ScreenBrightness();

  final List<StreamSubscription> _subscriptions = [];
  Timer? _pollingTimer;

  bool _isInitialized = false;

  /// Startet die Erfassung aller Sensoren und registriert die Listener
  Future<void> initialize(Function() onDataChanged) async {
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Geräteinformationen einmalig abrufen
    await _loadDeviceInfo();

    // 2. Akku Listener
    try {
      data.batteryLevel = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      _updateBatteryState(state);
      data.isLowPowerMode = await _battery.isInBatterySaveMode;
    } catch (_) {}

    _subscriptions.add(
      _battery.onBatteryStateChanged.listen((BatteryState state) {
        _updateBatteryState(state);
        onDataChanged();
      }, onError: (_) {}),
    );

    // 3. CoreMotion: Beschleunigungssensor
    try {
      _subscriptions.add(
        accelerometerEventStream().listen((AccelerometerEvent event) {
          data.accelX = event.x;
          data.accelY = event.y;
          data.accelZ = event.z;
          data.lastUpdated = DateTime.now();
          onDataChanged();
        }, onError: (_) {}),
      );
    } catch (_) {}

    // 4. CoreMotion: Gyroskop
    try {
      _subscriptions.add(
        gyroscopeEventStream().listen((GyroscopeEvent event) {
          data.gyroX = event.x;
          data.gyroY = event.y;
          data.gyroZ = event.z;
          data.lastUpdated = DateTime.now();
          onDataChanged();
        }, onError: (_) {}),
      );
    } catch (_) {}

    // 5. CoreMotion: Magnetometer
    try {
      _subscriptions.add(
        magnetometerEventStream().listen((MagnetometerEvent event) {
          data.magX = event.x;
          data.magY = event.y;
          data.magZ = event.z;
          data.lastUpdated = DateTime.now();
          onDataChanged();
        }, onError: (_) {}),
      );
    } catch (_) {}

    // 6. Pedometer (Schrittzähler)
    try {
      _subscriptions.add(
        Pedometer.stepCountStream.listen((StepCount event) {
          data.steps = event.steps;
          data.lastUpdated = DateTime.now();
          onDataChanged();
        }, onError: (_) {}),
      );

      _subscriptions.add(
        Pedometer.pedestrianStatusStream.listen((PedestrianStatus event) {
          data.pedestrianStatus = event.status;
          data.lastUpdated = DateTime.now();
          onDataChanged();
        }, onError: (_) {}),
      );
    } catch (_) {}

    // 7. Netzwerk & Konnektivität
    _subscriptions.add(
      _connectivity.onConnectivityChanged.listen((dynamic results) {
        _updateConnectivity(results);
        _refreshNetworkInfo();
        onDataChanged();
      }, onError: (_) {}),
    );

    // Initialer Netzwerk-Check
    await _refreshNetworkInfo();

    // 8. Periodische Aktualisierung für Akku, Helligkeit, GPS und Netzwerk
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) async {
      await _pollPeriodicSensors();
      onDataChanged();
    });
  }

  void _updateBatteryState(BatteryState state) {
    switch (state) {
      case BatteryState.charging:
        data.batteryState = 'Laden';
        data.isCharging = true;
        break;
      case BatteryState.full:
        data.batteryState = 'Voll';
        data.isCharging = false;
        break;
      case BatteryState.discharging:
        data.batteryState = 'Entladen';
        data.isCharging = false;
        break;
      default:
        data.batteryState = 'Unbekannt';
        data.isCharging = false;
        break;
    }
  }

  void _updateConnectivity(dynamic results) {
    if (results is List && results.isNotEmpty) {
      final first = results.first;
      data.isConnected = first != ConnectivityResult.none;
      data.connectionType = _formatConnectivity(first);
    } else if (results is ConnectivityResult) {
      data.isConnected = results != ConnectivityResult.none;
      data.connectionType = _formatConnectivity(results);
    }
  }

  String _formatConnectivity(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'Wi-Fi';
      case ConnectivityResult.mobile:
        return 'Mobilfunk';
      case ConnectivityResult.ethernet:
        return 'Ethernet';
      case ConnectivityResult.none:
        return 'Keine Verbindung';
      default:
        return 'Aktiv';
    }
  }

  Future<void> _refreshNetworkInfo() async {
    try {
      data.wifiName = await _networkInfo.getWifiName();
      data.wifiIp = await _networkInfo.getWifiIP();
    } catch (_) {}
  }

  Future<void> _loadDeviceInfo() async {
    try {
      if (Platform.isIOS) {
        final ios = await _deviceInfo.iosInfo;
        data.deviceName = ios.name;
        data.deviceModel = ios.model;
        data.osVersion = '${ios.systemName} ${ios.systemVersion}';
      } else {
        data.deviceName = 'iPhone Simulation';
        data.deviceModel = 'iPhone';
        data.osVersion = 'iOS 18.0';
      }
    } catch (_) {
      data.deviceName = 'iPhone';
    }
  }

  Future<void> _pollPeriodicSensors() async {
    // Akku prüfen
    try {
      data.batteryLevel = await _battery.batteryLevel;
      data.isLowPowerMode = await _battery.isInBatterySaveMode;
    } catch (_) {}

    // Display-Helligkeit prüfen
    try {
      data.screenBrightness = await _screenBrightness.application;
    } catch (_) {}

    // IP-Adresse prüfen
    try {
      final ip = await _networkInfo.getWifiIP();
      if (ip != null && ip.isNotEmpty) {
        data.wifiIp = ip;
      }
    } catch (_) {}
  }

  /// Fragt GPS-Berechtigung an und ermittelt einmalig die aktuelle Position
  Future<void> refreshLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      data.latitude = position.latitude;
      data.longitude = position.longitude;
      data.altitude = position.altitude;
      data.accuracy = position.accuracy;
      data.speed = position.speed;
      data.heading = position.heading;
      data.lastUpdated = DateTime.now();
    } catch (_) {}
  }

  void dispose() {
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    _pollingTimer?.cancel();
  }
}
