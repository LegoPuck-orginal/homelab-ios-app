import 'dart:async';
import 'dart:io';
import '../models/service_item.dart';

class DiscoveredHost {
  final String ip;
  final List<int> openPorts;
  final String suggestedName;
  final String suggestedUrl;
  final String suggestedCategory;

  DiscoveredHost({
    required this.ip,
    required this.openPorts,
    required this.suggestedName,
    required this.suggestedUrl,
    required this.suggestedCategory,
  });
}

class NetworkScannerService {
  /// Überprüft die Erreichbarkeit und Latenz eines Homelab-Dienstes
  Future<ServiceItem> checkServiceHealth(ServiceItem service) async {
    final uri = Uri.tryParse(service.url);
    if (uri == null) {
      service.isOnline = false;
      service.latencyMs = null;
      service.lastChecked = DateTime.now();
      return service;
    }

    final stopwatch = Stopwatch()..start();
    HttpClient? client;

    try {
      client = HttpClient();
      // Erlaubt selbstsignierte Zertifikate (Proxmox, Pi-hole, Hue etc.)
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
      client.connectionTimeout = const Duration(milliseconds: 1800);

      final request = await client.getUrl(uri).timeout(const Duration(milliseconds: 1800));
      final response = await request.close().timeout(const Duration(milliseconds: 1800));
      stopwatch.stop();

      // Jeder HTTP-Statuscode (selbst 401 Unauthorized oder 302) bedeutet, dass der Dienst aktiv ist
      service.isOnline = response.statusCode > 0 && response.statusCode < 599;
      service.latencyMs = stopwatch.elapsedMilliseconds;
      service.lastChecked = DateTime.now();
    } catch (_) {
      stopwatch.stop();
      service.isOnline = false;
      service.latencyMs = null;
      service.lastChecked = DateTime.now();
    } finally {
      client?.close(force: true);
    }

    return service;
  }

  /// Überprüft alle Dienste parallel mit max. 10 gleichzeitigen Anfragen
  Future<List<ServiceItem>> checkAllServices(List<ServiceItem> services) async {
    final results = <ServiceItem>[];
    for (int i = 0; i < services.length; i += 6) {
      final chunk = services.skip(i).take(6);
      final checked = await Future.wait(chunk.map((s) => checkServiceHealth(s)));
      results.addAll(checked);
    }
    return results;
  }

  /// Scannt das Subnetz (z.B. 192.168.188.x) nach aktiven Ports
  Stream<double> scanSubnet({
    String subnetPrefix = '192.168.188',
    required Function(DiscoveredHost) onHostFound,
  }) async* {
    final List<int> commonPorts = [80, 443, 8006, 8123, 3000, 8080, 8096, 9000, 5000];
    const totalIps = 254;

    for (int i = 1; i <= totalIps; i++) {
      final ip = '$subnetPrefix.$i';
      final openPorts = <int>[];

      for (final port in commonPorts) {
        final isOpen = await _checkSocketPort(ip, port, timeoutMs: 220);
        if (isOpen) {
          openPorts.add(port);
        }
      }

      if (openPorts.isNotEmpty) {
        final host = _createDiscoveredHost(ip, openPorts);
        onHostFound(host);
      }

      yield i / totalIps;
    }
  }

  Future<bool> _checkSocketPort(String ip, int port, {int timeoutMs = 250}) async {
    try {
      final socket = await Socket.connect(
        ip,
        port,
        timeout: Duration(milliseconds: timeoutMs),
      );
      socket.destroy();
      return true;
    } catch (_) {
      return false;
    }
  }

  DiscoveredHost _createDiscoveredHost(String ip, List<int> ports) {
    String name = 'Server ($ip)';
    String category = 'Netzwerk';
    String url = 'http://$ip';

    if (ports.contains(8006)) {
      name = 'Proxmox Node ($ip)';
      category = 'Virtualisierung';
      url = 'https://$ip:8006';
    } else if (ports.contains(8123)) {
      name = 'Home Assistant ($ip)';
      category = 'Smart Home';
      url = 'http://$ip:8123';
    } else if (ports.contains(8096)) {
      name = 'Jellyfin Media ($ip)';
      category = 'KI & Medien';
      url = 'http://$ip:8096';
    } else if (ports.contains(3000)) {
      name = 'Web App ($ip:3000)';
      category = 'KI & Medien';
      url = 'http://$ip:3000';
    } else if (ports.contains(8080)) {
      name = 'Web Service ($ip:8080)';
      category = 'Server';
      url = 'http://$ip:8080';
    } else if (ports.contains(9000)) {
      name = 'Portainer / Auth ($ip)';
      category = 'Tools';
      url = 'http://$ip:9000';
    } else if (ports.contains(443)) {
      url = 'https://$ip';
    }

    return DiscoveredHost(
      ip: ip,
      openPorts: ports,
      suggestedName: name,
      suggestedUrl: url,
      suggestedCategory: category,
    );
  }
}
