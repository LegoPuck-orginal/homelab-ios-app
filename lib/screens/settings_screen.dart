import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/services_provider.dart';
import '../theme/adobe_colors.dart';
import '../widgets/add_service_dialog.dart';
import '../widgets/adobe_button.dart';
import '../widgets/adobe_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final TextEditingController _urlController;
  late final TextEditingController _tokenController;
  late final TextEditingController _prefixController;

  bool _obscureToken = true;
  bool _isTestingConnection = false;
  bool? _connectionTestResult;

  final List<int> _intervalOptions = [5, 10, 30, 60, 120, 300];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SensorProvider>().settings;
    _urlController = TextEditingController(text: settings.haUrl);
    _tokenController = TextEditingController(text: settings.haToken);
    _prefixController = TextEditingController(text: settings.entityPrefix);
  }

  @override
  void dispose() {
    _urlController.dispose();
    _tokenController.dispose();
    _prefixController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final prov = context.read<SensorProvider>();
    final current = prov.settings;

    final updated = current.copyWith(
      haUrl: _urlController.text.trim(),
      haToken: _tokenController.text.trim(),
      entityPrefix: _prefixController.text.trim(),
    );

    await prov.updateSettings(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Einstellungen erfolgreich gespeichert'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
      _connectionTestResult = null;
    });

    final prov = context.read<SensorProvider>();
    final ok = await prov.testHaConnection(
      _urlController.text.trim(),
      _tokenController.text.trim(),
    );

    if (mounted) {
      setState(() {
        _isTestingConnection = false;
        _connectionTestResult = ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sensorProv = context.watch<SensorProvider>();
    final servicesProv = context.watch<ServicesProvider>();
    final settings = sensorProv.settings;

    return Scaffold(
      backgroundColor: AdobeColors.pureBlack,
      appBar: AppBar(
        title: const Text(
          'EINSTELLUNGEN // HA & NETZWERK',
          style: TextStyle(
            color: AdobeColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.8,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AdobeButton(
              text: 'Speichern',
              height: 32,
              onPressed: _saveSettings,
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. HOME ASSISTANT KONFIGURATION
          _buildSectionHeader('HOME ASSISTANT INTEGRATION'),
          AdobeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _urlController,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'Home Assistant Server URL',
                    hintText: 'http://192.168.188.25:8123',
                    prefixIcon: Icon(Icons.dns_outlined, size: 18, color: AdobeColors.textMuted),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _tokenController,
                  obscureText: _obscureToken,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Courier'),
                  decoration: InputDecoration(
                    labelText: 'Long-Lived Access Token',
                    hintText: 'In HA unter Profil -> Langlebige Zugriffstoken erstellen',
                    prefixIcon: const Icon(Icons.key_outlined, size: 18, color: AdobeColors.textMuted),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureToken ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        size: 18,
                        color: AdobeColors.textMuted,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureToken = !_obscureToken;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _prefixController,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Courier'),
                  decoration: const InputDecoration(
                    labelText: 'Entitäten-Präfix (z.B. iphone)',
                    hintText: 'iphone',
                    helperText: 'Erzeugt: sensor.iphone_battery, sensor.iphone_motion, etc.',
                    helperStyle: TextStyle(color: AdobeColors.textMuted, fontSize: 11),
                    prefixIcon: Icon(Icons.tag, size: 18, color: AdobeColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AdobeButton(
                        text: 'Verbindung testen',
                        icon: Icons.check_circle_outline,
                        style: AdobeButtonStyle.secondary,
                        isLoading: _isTestingConnection,
                        onPressed: _testConnection,
                      ),
                    ),
                    if (_connectionTestResult != null) ...[
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _connectionTestResult == true
                              ? const Color(0x2200E676)
                              : const Color(0x22FF334B),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _connectionTestResult == true
                                ? AdobeColors.statusOnline
                                : AdobeColors.statusOffline,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          _connectionTestResult == true ? 'OK (200)' : 'FEHLER',
                          style: TextStyle(
                            color: _connectionTestResult == true
                                ? AdobeColors.statusOnline
                                : AdobeColors.statusOffline,
                            fontSize: 11,
                            fontFamily: 'Courier',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 2. SYNCHRONISIERUNGS-INTERVALL
          _buildSectionHeader('SYNC-INTERVALL (SEKUNDEN)'),
          AdobeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Wie oft sollen die Sensoren im Hintergrund an Home Assistant gesendet werden?',
                  style: TextStyle(color: AdobeColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _intervalOptions.map((sec) {
                    final isSelected = settings.syncIntervalSeconds == sec;
                    return ChoiceChip(
                      label: Text('${sec}s'),
                      selected: isSelected,
                      selectedColor: AdobeColors.orangeAccent,
                      backgroundColor: AdobeColors.surfaceElevated,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : AdobeColors.textSecondary,
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: isSelected ? AdobeColors.orangeAccent : AdobeColors.borderCard,
                        width: 1,
                      ),
                      onSelected: (_) {
                        sensorProv.updateSettings(settings.copyWith(syncIntervalSeconds: sec));
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 3. SUBSETZ DISCOVERY SCANNER
          _buildSectionHeader('NETZWERK-DISCOVERY // 192.168.188.0/24'),
          AdobeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Durchsucht das lokale Subnetz nach aktiven Ports (Proxmox, HA, Jellyfin, Docker etc.)',
                  style: TextStyle(color: AdobeColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 12),
                if (servicesProv.isScanningSubnet) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: servicesProv.subnetScanProgress,
                      backgroundColor: AdobeColors.surfaceBase,
                      valueColor: const AlwaysStoppedAnimation<Color>(AdobeColors.orangeAccent),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Scanne Subnetz... ${(servicesProv.subnetScanProgress * 100).round()}%',
                    style: const TextStyle(
                      color: AdobeColors.textMuted,
                      fontSize: 11,
                      fontFamily: 'Courier',
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                AdobeButton(
                  text: servicesProv.isScanningSubnet ? 'SCAN LÄUFT...' : 'SUBSETZ SCAN STARTEN',
                  icon: Icons.radar,
                  isLoading: servicesProv.isScanningSubnet,
                  onPressed: servicesProv.isScanningSubnet ? null : () => servicesProv.startSubnetScan(),
                ),
                if (servicesProv.discoveredHosts.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(color: AdobeColors.borderSubtle),
                  const SizedBox(height: 10),
                  Text(
                    'GEFUNDENE GERÄTE (${servicesProv.discoveredHosts.length}):',
                    style: const TextStyle(
                      color: AdobeColors.orangeAccent,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...servicesProv.discoveredHosts.map((host) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                host.suggestedName,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                '${host.suggestedUrl} (Ports: ${host.openPorts.join(", ")})',
                                style: const TextStyle(color: AdobeColors.textMuted, fontSize: 10, fontFamily: 'Courier'),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AddServiceDialog(
                                  onAdd: (item) => servicesProv.addCustomService(item),
                                  initialIp: host.ip,
                                  initialPort: host.openPorts.first,
                                  initialName: host.suggestedName,
                                  initialCategory: host.suggestedCategory,
                                ),
                              );
                            },
                            child: const Text(
                              '+ Hinzufügen',
                              style: TextStyle(color: AdobeColors.orangeAccent, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 4. DESIGN & INFO
          _buildSectionHeader('INFO & DESIGN'),
          AdobeCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: AdobeColors.pureBlack,
                        shape: BoxShape.circle,
                        border: Border.fromBorderSide(BorderSide(color: AdobeColors.orangeAccent, width: 2)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'OLED True Black (#000000) & Adobe Orange (#FF7A00)',
                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Das UI ist für iPhone OLED-Displays optimiert: Reines Schwarz schaltet die Pixel physisch ab und spart maximalen Akku beim Sensor-Streaming.',
                  style: TextStyle(color: AdobeColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
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
