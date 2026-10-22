import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service_item.dart';
import '../providers/sensor_provider.dart';
import '../providers/services_provider.dart';
import '../theme/adobe_colors.dart';
import '../widgets/adobe_button.dart';
import '../widgets/adobe_card.dart';
import '../widgets/live_status_indicator.dart';
import '../widgets/sensor_gauge_tile.dart';
import 'webview_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const DashboardScreen({
    super.key,
    required this.onTabChange,
  });

  @override
  Widget build(BuildContext context) {
    final sensorProv = context.watch<SensorProvider>();
    final servicesProv = context.watch<ServicesProvider>();

    final sensorData = sensorProv.data;
    final services = servicesProv.allServices;

    // Top Homelab Services für den Schnellstart
    final quickServices = services.take(6).toList();

    return Scaffold(
      backgroundColor: AdobeColors.pureBlack,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: AdobeColors.orangeAccent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'HL',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'HOMELAB // CORE',
              style: TextStyle(
                color: AdobeColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Row(
              children: [
                LiveStatusIndicator(
                  isOnline: servicesProv.onlineCount > 0,
                  latencyMs: null,
                  showLabel: false,
                ),
                const SizedBox(width: 6),
                Text(
                  '${servicesProv.onlineCount}/${services.length} AKTIV',
                  style: const TextStyle(
                    color: AdobeColors.textSecondary,
                    fontSize: 11,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AdobeColors.orangeAccent,
        backgroundColor: AdobeColors.surfaceElevated,
        onRefresh: () async {
          await Future.wait([
            servicesProv.checkAllHealth(),
            sensorProv.syncNow(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. HA SYNC STATUS CARD
            _buildHaSyncCard(context, sensorProv),

            const SizedBox(height: 20),

            // 2. SCHNELLZUGRIFF SERVICES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'SCHNELLZUGRIFF // DIENSTE',
                  style: TextStyle(
                    color: AdobeColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: () => onTabChange(1),
                  child: const Text(
                    'Alle anzeigen →',
                    style: TextStyle(
                      color: AdobeColors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildQuickServicesGrid(context, quickServices),

            const SizedBox(height: 24),

            // 3. LIVE SENSOR TELEMETRIE HIGHLIGHTS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TELEMETRIE // IPHONE SENSOREN',
                  style: TextStyle(
                    color: AdobeColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                GestureDetector(
                  onTap: () => onTabChange(2),
                  child: const Text(
                    'Details →',
                    style: TextStyle(
                      color: AdobeColors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Akku Gauge
            SensorGaugeTile(
              title: 'Akku-Ladestand',
              subtitle: sensorData.isCharging ? 'Wird geladen' : sensorData.batteryState,
              value: '${sensorData.batteryLevel ?? 0}%',
              icon: sensorData.isCharging ? Icons.battery_charging_full : Icons.battery_std,
              progress: (sensorData.batteryLevel ?? 0) / 100.0,
              iconColor: (sensorData.batteryLevel ?? 0) > 20
                  ? AdobeColors.orangeAccent
                  : AdobeColors.statusOffline,
            ),
            const SizedBox(height: 8),

            // Schrittzähler & Aktivität
            SensorGaugeTile(
              title: 'Schritte heute',
              subtitle: 'Status: ${sensorData.pedestrianStatus}',
              value: '${sensorData.steps}',
              icon: Icons.directions_walk,
              iconColor: const Color(0xFF69F0AE),
            ),
            const SizedBox(height: 8),

            // Lokales Netzwerk & IP
            SensorGaugeTile(
              title: 'Lokales Netzwerk',
              subtitle: sensorData.wifiName ?? 'Verbunden',
              value: sensorData.wifiIp ?? '192.168.188.x',
              icon: Icons.wifi,
              iconColor: const Color(0xFF40C4FF),
            ),
            const SizedBox(height: 8),

            // Display-Helligkeit
            SensorGaugeTile(
              title: 'Display-Helligkeit',
              subtitle: 'Aktueller Sensorwert',
              value: '${(sensorData.screenBrightness * 100).round()}%',
              icon: Icons.brightness_6,
              progress: sensorData.screenBrightness,
              iconColor: const Color(0xFFFFD740),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHaSyncCard(BuildContext context, SensorProvider prov) {
    final lastResult = prov.lastSyncResult;
    final isConfigured = prov.settings.haToken.isNotEmpty;

    return AdobeCard(
      borderColor: isConfigured ? AdobeColors.borderCard : AdobeColors.statusWarning.withValues(alpha: 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isConfigured ? AdobeColors.statusOnline : AdobeColors.statusWarning,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'HOME ASSISTANT STREAM',
                    style: TextStyle(
                      color: AdobeColors.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              if (prov.isSyncing)
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AdobeColors.orangeAccent),
                  ),
                )
              else if (lastResult != null)
                Text(
                  lastResult.success ? '${lastResult.sentCount} gesendet' : 'Fehler',
                  style: TextStyle(
                    color: lastResult.success ? AdobeColors.statusOnline : AdobeColors.statusOffline,
                    fontSize: 11,
                    fontFamily: 'Courier',
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            isConfigured
                ? 'Ziel: ${prov.settings.haUrl} (Intervall: ${prov.settings.syncIntervalSeconds}s)'
                : 'Achtung: Long-Lived Access Token in den Einstellungen hinterlegen.',
            style: TextStyle(
              color: isConfigured ? AdobeColors.textSecondary : AdobeColors.statusWarning,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AdobeButton(
                  text: 'JETZT SYNCHRONISIEREN',
                  icon: Icons.sync,
                  isLoading: prov.isSyncing,
                  onPressed: isConfigured ? () => prov.syncNow() : null,
                ),
              ),
              if (!isConfigured) ...[
                const SizedBox(width: 8),
                AdobeButton(
                  text: 'Einrichten',
                  style: AdobeButtonStyle.secondary,
                  onPressed: () => onTabChange(3),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickServicesGrid(BuildContext context, List<ServiceItem> services) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.1,
      ),
      itemBuilder: (context, index) {
        final service = services[index];
        return AdobeCard(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => WebViewScreen(
                  title: service.name,
                  url: service.url,
                ),
              ),
            );
          },
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      service.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AdobeColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  LiveStatusIndicator(
                    isOnline: service.isOnline,
                    latencyMs: service.latencyMs,
                    showLabel: false,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    service.category,
                    style: const TextStyle(
                      color: AdobeColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                  if (service.latencyMs != null)
                    Text(
                      '${service.latencyMs}ms',
                      style: const TextStyle(
                        color: AdobeColors.statusOnline,
                        fontSize: 10,
                        fontFamily: 'Courier',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
