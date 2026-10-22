class ServiceItem {
  final String id;
  final String name;
  final String url;
  final String category;
  final String iconName;
  final bool isCustom;
  final int? port;
  bool? isOnline;
  int? latencyMs;
  DateTime? lastChecked;

  ServiceItem({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.iconName,
    this.isCustom = false,
    this.port,
    this.isOnline,
    this.latencyMs,
    this.lastChecked,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'category': category,
      'iconName': iconName,
      'isCustom': isCustom,
      'port': port,
    };
  }

  factory ServiceItem.fromJson(Map<String, dynamic> json) {
    return ServiceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      category: json['category'] as String? ?? 'General',
      iconName: json['iconName'] as String? ?? 'server',
      isCustom: json['isCustom'] as bool? ?? false,
      port: json['port'] as int?,
    );
  }

  ServiceItem copyWith({
    String? id,
    String? name,
    String? url,
    String? category,
    String? iconName,
    bool? isCustom,
    int? port,
    bool? isOnline,
    int? latencyMs,
    DateTime? lastChecked,
  }) {
    final item = ServiceItem(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      category: category ?? this.category,
      iconName: iconName ?? this.iconName,
      isCustom: isCustom ?? this.isCustom,
      port: port ?? this.port,
      isOnline: isOnline ?? this.isOnline,
      latencyMs: latencyMs ?? this.latencyMs,
      lastChecked: lastChecked ?? this.lastChecked,
    );
    return item;
  }

  static List<ServiceItem> get defaultServices => [
        ServiceItem(
          id: 'home_assistant',
          name: 'Home Assistant',
          url: 'http://192.168.188.25:8123',
          category: 'Smart Home',
          iconName: 'home',
          port: 8123,
        ),
        ServiceItem(
          id: 'proxmox',
          name: 'Proxmox VE',
          url: 'https://192.168.188.20:8006',
          category: 'Virtualisierung',
          iconName: 'layers',
          port: 8006,
        ),
        ServiceItem(
          id: 'jarvis',
          name: 'JARVIS Hub',
          url: 'http://192.168.188.88',
          category: 'Smart Home',
          iconName: 'cpu',
          port: 80,
        ),
        ServiceItem(
          id: 'open_webui',
          name: 'Open WebUI (LLMs)',
          url: 'http://192.168.188.70:3000',
          category: 'KI & Medien',
          iconName: 'brain',
          port: 3000,
        ),
        ServiceItem(
          id: 'amp_panel',
          name: 'CubeCoders AMP',
          url: 'http://192.168.188.70:8080',
          category: 'Gaming & Server',
          iconName: 'gamepad',
          port: 8080,
        ),
        ServiceItem(
          id: 'jellyfin',
          name: 'Jellyfin Media',
          url: 'http://192.168.188.70:8096',
          category: 'KI & Medien',
          iconName: 'play',
          port: 8096,
        ),
        ServiceItem(
          id: 'authentik',
          name: 'Authentik SSO',
          url: 'http://192.168.188.70:9000',
          category: 'Security & Auth',
          iconName: 'shield',
          port: 9000,
        ),
        ServiceItem(
          id: 'pihole',
          name: 'Pi-hole DNS',
          url: 'http://192.168.188.83/admin',
          category: 'Netzwerk',
          iconName: 'crosshair',
          port: 80,
        ),
        ServiceItem(
          id: 'file_browser',
          name: 'File Browser',
          url: 'http://192.168.188.125:8080',
          category: 'Dateien & Cloud',
          iconName: 'folder',
          port: 8080,
        ),
        ServiceItem(
          id: 'voce_chat',
          name: 'VoceChat',
          url: 'http://192.168.188.125:3000',
          category: 'Kommunikation',
          iconName: 'message',
          port: 3000,
        ),
        ServiceItem(
          id: 'takle_intercom',
          name: 'Takle Intercom',
          url: 'http://192.168.188.71:8080',
          category: 'Kommunikation',
          iconName: 'mic',
          port: 8080,
        ),
        ServiceItem(
          id: 'philips_hue',
          name: 'Philips Hue Bridge',
          url: 'http://192.168.188.192',
          category: 'Smart Home',
          iconName: 'lightbulb',
          port: 80,
        ),
        ServiceItem(
          id: 'router_gateway',
          name: 'Router Gateway',
          url: 'https://192.168.188.1',
          category: 'Netzwerk',
          iconName: 'router',
          port: 443,
        ),
        ServiceItem(
          id: 'netgear_switch',
          name: 'NETGEAR GS108E',
          url: 'http://192.168.188.99',
          category: 'Netzwerk',
          iconName: 'terminal',
          port: 80,
        ),
        ServiceItem(
          id: 'waydroid_remote',
          name: 'Waydroid TV Remote',
          url: 'http://192.168.188.91:8080',
          category: 'Gaming & Server',
          iconName: 'tv',
          port: 8080,
        ),
      ];
}
