import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../theme/adobe_colors.dart';
import '../widgets/adobe_button.dart';
import '../widgets/adobe_card.dart';
import '../widgets/sensor_gauge_tile.dart';

class SensorsScreen extends StatelessWidget {
  const SensorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<SensorProvider>();
    final data = prov.data;
    final settings = prov.settings;
    final lastResult = prov.lastSyncResult;

    return Scaffold(
      backgroundColor: AdobeColors.pureBlack,
      appBar: AppBar(
        title: const Text(
          'SENSOREN // TELEMETRIE',
          style: TextStyle(
            color: AdobeColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          IconButton(
            icon: prov.isSyncing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AdobeColors.orangeAccent),
                    ),
                  )
                : const Icon(Icons.sync, color: AdobeColors.orangeAccent, size: 20),
            tooltip: 'Telemetrie an HA senden',
            onPressed: prov.isSyncing ? null : () => prov.syncNow(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. SYNC CONTROL PANEL
          AdobeCard(
            borderColor: AdobeColors.borderCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'HA SYNC STATUS',
                      style: TextStyle(
                        color: AdobeColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (lastResult != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: lastResult.success ? const Color(0x2200E676) : const Color(0x22FF334B),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: lastResult.success ? AdobeColors.statusOnline : AdobeColors.statusOffline,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          lastResult.success ? 'Erfolgreich (${lastResult.sentCount} Entitäten)' : 'Fehler',
                          style: TextStyle(
                            color: lastResult.success ? AdobeColors.statusOnline : AdobeColors.statusOffline,
                            fontSize: 10,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Auto-Sync aktiv',
                      style: TextStyle(color: AdobeColors.textSecondary, fontSize: 13),
                    ),
                    Switch(
                      value: settings.autoSyncEnabled,
                      onChanged: (val) {
                        prov.updateSettings(settings.copyWith(autoSyncEnabled: val));
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AdobeButton(
                  text: prov.isSyncing ? 'ÜBERTRAGE TELEMETRIE...' : 'JETZT AN HA SENDEN',
                  icon: Icons.send,
                  isLoading: prov.isSyncing,
                  onPressed: () => prov.syncNow(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. AKKU-TELEMETRIE
          _buildSectionHeader('AKKU & ENERGIE (BATTERY_PLUS)'),
          SensorGaugeTile(
            title: 'Batteriestand',
            subtitle: data.isCharging ? 'Wird geladen' : 'Entladen (${data.batteryState})',
            value: '${data.batteryLevel ?? 0}%',
            icon: data.isCharging ? Icons.battery_charging_full : Icons.battery_std,
            progress: (data.batteryLevel ?? 0) / 100.0,
            iconColor: (data.batteryLevel ?? 0) > 20 ? AdobeColors.orangeAccent : AdobeColors.statusOffline,
            trailing: Switch(
              value: settings.sendBattery,
              onChanged: (val) {
                prov.updateSettings(settings.copyWith(sendBattery: val));
              },
            ),
          ),

          const SizedBox(height: 20),

          // 3. CORE MOTION & GYRO
          _buildSectionHeader('BEWEGUNG & GYROSKOP (SENSORS_PLUS)'),
          TriAxisGauge(
            title: 'Beschleunigungssensor (G-Kräfte)',
            x: data.accelX,
            y: data.accelY,
            z: data.accelZ,
            unit: 'm/s²',
            icon: Icons.screen_rotation,
          ),
          const SizedBox(height: 8),
          TriAxisGauge(
            title: 'Gyroskop (Drehraten)',
            x: data.gyroX,
            y: data.gyroY,
            z: data.gyroZ,
            unit: 'rad/s',
            icon: Icons.threed_rotation,
          ),
          const SizedBox(height: 8),
          TriAxisGauge(
            title: 'Magnetometer (Erdmagnetfeld)',
            x: data.magX,
            y: data.magY,
            z: data.magZ,
            unit: 'µT',
            icon: Icons.explore_outlined,
          ),
          const SizedBox(height: 8),
          AdobeCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Bewegungsdaten an HA senden', style: TextStyle(color: AdobeColors.textSecondary, fontSize: 12)),
                Switch(
                  value: settings.sendMotion,
                  onChanged: (val) {
                    prov.updateSettings(settings.copyWith(sendMotion: val));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. SCHRITTZÄHLER (PEDOMETER)
          _buildSectionHeader('PEDOMETER (COREMOTION CO-PROZESSOR)'),
          SensorGaugeTile(
            title: 'Tages-Schrittzähler',
            subtitle: 'Aktivität: ${data.pedestrianStatus}',
            value: '${data.steps}',
            icon: Icons.directions_walk,
            iconColor: const Color(0xFF69F0AE),
            trailing: Switch(
              value: settings.sendSteps,
              onChanged: (val) {
                prov.updateSettings(settings.copyWith(sendSteps: val));
              },
            ),
          ),

          const SizedBox(height: 20),

          // 5. GPS & STANDORT (GEOLOCATOR)
          _buildSectionHeader('STANDORT & ORTUNG (GEOLOCATOR)'),
          AdobeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 18, color: AdobeColors.orangeAccent),
                        const SizedBox(width: 8),
                        Text(
                          data.latitude != null
                              ? '${data.latitude!.toStringAsFixed(4)}, ${data.longitude!.toStringAsFixed(4)}'
                              : 'Standort noch nicht geladen',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: settings.sendLocation,
                      onChanged: (val) {
                        prov.updateSettings(settings.copyWith(sendLocation: val));
                      },
                    ),
                  ],
                ),
                if (data.altitude != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Höhe: ${data.altitude!.toStringAsFixed(1)} m | Genauigkeit: ±${data.accuracy?.toStringAsFixed(1) ?? "?"} m | Speed: ${(data.speed ?? 0).toStringAsFixed(1)} m/s',
                    style: const TextStyle(color: AdobeColors.textMuted, fontSize: 11, fontFamily: 'Courier'),
                  ),
                ],
                const SizedBox(height: 12),
                AdobeButton(
                  text: 'GPS Position ermitteln',
                  icon: Icons.my_location,
                  style: AdobeButtonStyle.secondary,
                  onPressed: () => prov.refreshLocation(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 6. NETZWERK & SYSTEM
          _buildSectionHeader('NETZWERK & SYSTEM TELEMETRIE'),
          SensorGaugeTile(
            title: 'WLAN & IP-Adresse',
            subtitle: data.wifiName ?? 'Verbunden',
            value: data.wifiIp ?? '192.168.188.x',
            icon: Icons.wifi,
            iconColor: const Color(0xFF40C4FF),
            trailing: Switch(
              value: settings.sendNetwork,
              onChanged: (val) {
                prov.updateSettings(settings.copyWith(sendNetwork: val));
              },
            ),
          ),
          const SizedBox(height: 8),
          SensorGaugeTile(
            title: 'Display-Helligkeit',
            subtitle: 'Hardware-Sensor',
            value: '${(data.screenBrightness * 100).round()}%',
            icon: Icons.brightness_6,
            progress: data.screenBrightness,
            iconColor: const Color(0xFFFFD740),
            trailing: Switch(
              value: settings.sendBrightness,
              onChanged: (val) {
                prov.updateSettings(settings.copyWith(sendBrightness: val));
              },
            ),
          ),
          const SizedBox(height: 8),
          SensorGaugeTile(
            title: 'Gerätemodell',
            subtitle: data.osVersion,
            value: data.deviceName,
            icon: Icons.phone_iphone,
            iconColor: AdobeColors.textSecondary,
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Text(
        title,
        style: const TextStyle(
          color: AdobeColors.textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
