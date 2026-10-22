class SensorData {
  // Akku-Telemetrie
  int? batteryLevel;
  String batteryState;
  bool isCharging;
  bool isLowPowerMode;

  // CoreMotion
  double accelX;
  double accelY;
  double accelZ;
  double gyroX;
  double gyroY;
  double gyroZ;
  double magX;
  double magY;
  double magZ;

  // Pedometer (Schritte)
  int steps;
  String pedestrianStatus;

  // GPS & Geolocation
  double? latitude;
  double? longitude;
  double? altitude;
  double? accuracy;
  double? speed;
  double? heading;

  // Netzwerk
  String? wifiName;
  String? wifiIp;
  bool isConnected;
  String connectionType;

  // System & Hardware
  String deviceName;
  String deviceModel;
  String osVersion;
  double screenBrightness;

  // Zeitstempel
  DateTime lastUpdated;

  SensorData({
    this.batteryLevel,
    this.batteryState = 'unbekannt',
    this.isCharging = false,
    this.isLowPowerMode = false,
    this.accelX = 0.0,
    this.accelY = 0.0,
    this.accelZ = 0.0,
    this.gyroX = 0.0,
    this.gyroY = 0.0,
    this.gyroZ = 0.0,
    this.magX = 0.0,
    this.magY = 0.0,
    this.magZ = 0.0,
    this.steps = 0,
    this.pedestrianStatus = 'inaktiv',
    this.latitude,
    this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.wifiName,
    this.wifiIp,
    this.isConnected = true,
    this.connectionType = 'Wi-Fi',
    this.deviceName = 'iPhone',
    this.deviceModel = 'iPhone',
    this.osVersion = 'iOS',
    this.screenBrightness = 0.5,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Erzeugt die Entitäten-Payloads für die Home Assistant REST API
  Map<String, Map<String, dynamic>> toHomeAssistantEntities(String entityPrefix) {
    final prefix = entityPrefix.trim().isEmpty ? 'iphone' : entityPrefix.trim();

    return {
      'sensor.${prefix}_battery': {
        'state': batteryLevel ?? 0,
        'attributes': {
          'unit_of_measurement': '%',
          'device_class': 'battery',
          'friendly_name': '$deviceName Akku',
          'state_class': 'measurement',
          'is_charging': isCharging,
          'battery_state': batteryState,
          'low_power_mode': isLowPowerMode,
          'icon': isCharging ? 'mdi:battery-charging' : 'mdi:battery',
        }
      },
      'sensor.${prefix}_motion': {
        'state': (accelX.abs() > 0.3 || accelY.abs() > 0.3) ? 'active' : 'idle',
        'attributes': {
          'friendly_name': '$deviceName Bewegung & Neigung',
          'accel_x': double.parse(accelX.toStringAsFixed(3)),
          'accel_y': double.parse(accelY.toStringAsFixed(3)),
          'accel_z': double.parse(accelZ.toStringAsFixed(3)),
          'gyro_x': double.parse(gyroX.toStringAsFixed(3)),
          'gyro_y': double.parse(gyroY.toStringAsFixed(3)),
          'gyro_z': double.parse(gyroZ.toStringAsFixed(3)),
          'mag_x': double.parse(magX.toStringAsFixed(2)),
          'mag_y': double.parse(magY.toStringAsFixed(2)),
          'mag_z': double.parse(magZ.toStringAsFixed(2)),
          'icon': 'mdi:axis-arrow',
        }
      },
      'sensor.${prefix}_steps': {
        'state': steps,
        'attributes': {
          'unit_of_measurement': 'steps',
          'friendly_name': '$deviceName Schrittzähler',
          'state_class': 'total_increasing',
          'status': pedestrianStatus,
          'icon': 'mdi:walk',
        }
      },
      'sensor.${prefix}_network': {
        'state': isConnected ? 'connected' : 'disconnected',
        'attributes': {
          'friendly_name': '$deviceName Netzwerk',
          'wifi_ssid': wifiName ?? 'Unbekannt',
          'ip_address': wifiIp ?? '0.0.0.0',
          'connection_type': connectionType,
          'icon': 'mdi:wifi',
        }
      },
      'sensor.${prefix}_brightness': {
        'state': (screenBrightness * 100).round(),
        'attributes': {
          'unit_of_measurement': '%',
          'friendly_name': '$deviceName Display-Helligkeit',
          'brightness_raw': double.parse(screenBrightness.toStringAsFixed(2)),
          'icon': 'mdi:brightness-6',
        }
      },
      if (latitude != null && longitude != null)
        'sensor.${prefix}_location': {
          'state': '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}',
          'attributes': {
            'friendly_name': '$deviceName Standort',
            'latitude': latitude,
            'longitude': longitude,
            'altitude': altitude ?? 0.0,
            'accuracy': accuracy ?? 0.0,
            'speed': speed ?? 0.0,
            'heading': heading ?? 0.0,
            'icon': 'mdi:crosshairs-gps',
          }
        },
    };
  }
}
