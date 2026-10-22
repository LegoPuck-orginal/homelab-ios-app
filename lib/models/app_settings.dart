class AppSettings {
  String haUrl;
  String haToken;
  String entityPrefix;
  int syncIntervalSeconds;
  bool autoSyncEnabled;

  // Sensor Toggles
  bool sendBattery;
  bool sendMotion;
  bool sendSteps;
  bool sendLocation;
  bool sendNetwork;
  bool sendBrightness;

  // Web / Network
  bool bypassSslWarnings;

  AppSettings({
    this.haUrl = 'http://192.168.188.25:8123',
    this.haToken = '',
    this.entityPrefix = 'iphone',
    this.syncIntervalSeconds = 10,
    this.autoSyncEnabled = true,
    this.sendBattery = true,
    this.sendMotion = true,
    this.sendSteps = true,
    this.sendLocation = true,
    this.sendNetwork = true,
    this.sendBrightness = true,
    this.bypassSslWarnings = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'haUrl': haUrl,
      'haToken': haToken,
      'entityPrefix': entityPrefix,
      'syncIntervalSeconds': syncIntervalSeconds,
      'autoSyncEnabled': autoSyncEnabled,
      'sendBattery': sendBattery,
      'sendMotion': sendMotion,
      'sendSteps': sendSteps,
      'sendLocation': sendLocation,
      'sendNetwork': sendNetwork,
      'sendBrightness': sendBrightness,
      'bypassSslWarnings': bypassSslWarnings,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      haUrl: json['haUrl'] as String? ?? 'http://192.168.188.25:8123',
      haToken: json['haToken'] as String? ?? '',
      entityPrefix: json['entityPrefix'] as String? ?? 'iphone',
      syncIntervalSeconds: json['syncIntervalSeconds'] as int? ?? 10,
      autoSyncEnabled: json['autoSyncEnabled'] as bool? ?? true,
      sendBattery: json['sendBattery'] as bool? ?? true,
      sendMotion: json['sendMotion'] as bool? ?? true,
      sendSteps: json['sendSteps'] as bool? ?? true,
      sendLocation: json['sendLocation'] as bool? ?? true,
      sendNetwork: json['sendNetwork'] as bool? ?? true,
      sendBrightness: json['sendBrightness'] as bool? ?? true,
      bypassSslWarnings: json['bypassSslWarnings'] as bool? ?? true,
    );
  }

  AppSettings copyWith({
    String? haUrl,
    String? haToken,
    String? entityPrefix,
    int? syncIntervalSeconds,
    bool? autoSyncEnabled,
    bool? sendBattery,
    bool? sendMotion,
    bool? sendSteps,
    bool? sendLocation,
    bool? sendNetwork,
    bool? sendBrightness,
    bool? bypassSslWarnings,
  }) {
    return AppSettings(
      haUrl: haUrl ?? this.haUrl,
      haToken: haToken ?? this.haToken,
      entityPrefix: entityPrefix ?? this.entityPrefix,
      syncIntervalSeconds: syncIntervalSeconds ?? this.syncIntervalSeconds,
      autoSyncEnabled: autoSyncEnabled ?? this.autoSyncEnabled,
      sendBattery: sendBattery ?? this.sendBattery,
      sendMotion: sendMotion ?? this.sendMotion,
      sendSteps: sendSteps ?? this.sendSteps,
      sendLocation: sendLocation ?? this.sendLocation,
      sendNetwork: sendNetwork ?? this.sendNetwork,
      sendBrightness: sendBrightness ?? this.sendBrightness,
      bypassSslWarnings: bypassSslWarnings ?? this.bypassSslWarnings,
    );
  }
}
