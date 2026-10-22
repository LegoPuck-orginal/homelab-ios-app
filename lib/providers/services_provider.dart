import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/service_item.dart';
import '../services/network_scanner_service.dart';
import '../services/storage_service.dart';

class ServicesProvider extends ChangeNotifier {
  final NetworkScannerService _scanner = NetworkScannerService();
  final StorageService _storage = StorageService();

  List<ServiceItem> _services = [];
  bool _isCheckingHealth = false;
  bool _isScanningSubnet = false;
  double _subnetScanProgress = 0.0;
  final List<DiscoveredHost> _discoveredHosts = [];
  Timer? _healthTimer;
  String _selectedCategory = 'Alle';
  String _searchQuery = '';

  List<ServiceItem> get allServices => _services;
  bool get isCheckingHealth => _isCheckingHealth;
  bool get isScanningSubnet => _isScanningSubnet;
  double get subnetScanProgress => _subnetScanProgress;
  List<DiscoveredHost> get discoveredHosts => _discoveredHosts;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  int get onlineCount => _services.where((s) => s.isOnline == true).length;
  int get offlineCount => _services.where((s) => s.isOnline == false).length;

  List<String> get categories {
    final set = {'Alle'};
    for (final s in _services) {
      set.add(s.category);
    }
    return set.toList();
  }

  List<ServiceItem> get filteredServices {
    return _services.where((s) {
      final matchesCategory = _selectedCategory == 'Alle' || s.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.url.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> initialize() async {
    final custom = await _storage.loadCustomServices();
    _services = [...ServiceItem.defaultServices, ...custom];
    notifyListeners();

    // Initiale Erreichbarkeitsprüfung
    checkAllHealth();

    // Alle 45 Sekunden im Hintergrund pingen
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      checkAllHealth();
    });
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> checkAllHealth() async {
    if (_isCheckingHealth) return;
    _isCheckingHealth = true;
    notifyListeners();

    try {
      final updated = await _scanner.checkAllServices(_services);
      _services = updated;
    } finally {
      _isCheckingHealth = false;
      notifyListeners();
    }
  }

  Future<void> addCustomService(ServiceItem service) async {
    _services.add(service);
    notifyListeners();

    final customOnly = _services.where((s) => s.isCustom).toList();
    await _storage.saveCustomServices(customOnly);

    // Erreichbarkeit des neuen Dienstes direkt prüfen
    await _scanner.checkServiceHealth(service);
    notifyListeners();
  }

  Future<void> removeCustomService(String id) async {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();

    final customOnly = _services.where((s) => s.isCustom).toList();
    await _storage.saveCustomServices(customOnly);
  }

  void startSubnetScan({String subnetPrefix = '192.168.188'}) {
    if (_isScanningSubnet) return;
    _isScanningSubnet = true;
    _subnetScanProgress = 0.0;
    _discoveredHosts.clear();
    notifyListeners();

    final stream = _scanner.scanSubnet(
      subnetPrefix: subnetPrefix,
      onHostFound: (host) {
        _discoveredHosts.add(host);
        notifyListeners();
      },
    );

    stream.listen(
      (progress) {
        _subnetScanProgress = progress;
        notifyListeners();
      },
      onDone: () {
        _isScanningSubnet = false;
        notifyListeners();
      },
      onError: (_) {
        _isScanningSubnet = false;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }
}
