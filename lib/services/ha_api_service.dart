import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/app_settings.dart';

class HaSyncResult {
  final bool success;
  final int sentCount;
  final String? errorMessage;
  final DateTime timestamp;

  HaSyncResult({
    required this.success,
    required this.sentCount,
    this.errorMessage,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class HaApiService {
  /// Testet die Verbindung zur Home Assistant API
  Future<bool> testConnection(String baseUrl, String token) async {
    if (baseUrl.trim().isEmpty || token.trim().isEmpty) {
      return false;
    }

    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$cleanUrl/api/');

    try {
      final response = await http.get(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.trim()}',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Sendet den Zustand einer einzelnen Entität an Home Assistant
  Future<bool> sendEntityState({
    required String baseUrl,
    required String token,
    required String entityId,
    required dynamic state,
    required Map<String, dynamic> attributes,
  }) async {
    final cleanUrl = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final uri = Uri.parse('$cleanUrl/api/states/$entityId');

    final payload = {
      'state': state.toString(),
      'attributes': attributes,
    };

    try {
      final response = await http.post(
        uri,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer ${token.trim()}',
          HttpHeaders.contentTypeHeader: 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (_) {
      return false;
    }
  }

  /// Überträgt alle aktivierten Sensoren an Home Assistant
  Future<HaSyncResult> syncSensors({
    required AppSettings settings,
    required SensorData sensorData,
  }) async {
    if (settings.haUrl.trim().isEmpty) {
      return HaSyncResult(
        success: false,
        sentCount: 0,
        errorMessage: 'Home Assistant URL ist nicht konfiguriert.',
      );
    }

    if (settings.haToken.trim().isEmpty) {
      return HaSyncResult(
        success: false,
        sentCount: 0,
        errorMessage: 'Long-Lived Access Token fehlt in den Einstellungen.',
      );
    }

    final allEntities = sensorData.toHomeAssistantEntities(settings.entityPrefix);
    final entitiesToSend = <String, Map<String, dynamic>>{};

    for (final entry in allEntities.entries) {
      final key = entry.key;
      if (key.contains('_battery') && !settings.sendBattery) continue;
      if (key.contains('_motion') && !settings.sendMotion) continue;
      if (key.contains('_steps') && !settings.sendSteps) continue;
      if (key.contains('_network') && !settings.sendNetwork) continue;
      if (key.contains('_brightness') && !settings.sendBrightness) continue;
      if (key.contains('_location') && !settings.sendLocation) continue;

      entitiesToSend[key] = entry.value;
    }

    if (entitiesToSend.isEmpty) {
      return HaSyncResult(
        success: true,
        sentCount: 0,
        errorMessage: 'Keine Sensoren zur Übertragung ausgewählt.',
      );
    }

    int successCount = 0;
    String? lastError;

    final futures = entitiesToSend.entries.map((entry) async {
      final entityId = entry.key;
      final state = entry.value['state'];
      final attributes = entry.value['attributes'] as Map<String, dynamic>;

      final ok = await sendEntityState(
        baseUrl: settings.haUrl,
        token: settings.haToken,
        entityId: entityId,
        state: state,
        attributes: attributes,
      );

      if (ok) {
        successCount++;
      } else {
        lastError = 'Fehler beim Senden von $entityId';
      }
    });

    await Future.wait(futures);

    final isOverallSuccess = successCount > 0;
    return HaSyncResult(
      success: isOverallSuccess,
      sentCount: successCount,
      errorMessage: isOverallSuccess ? null : (lastError ?? 'Verbindung zu Home Assistant fehlgeschlagen.'),
    );
  }
}
