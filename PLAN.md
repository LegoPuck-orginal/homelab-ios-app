# Implementierungsplan: iOS Homelab Hub & Sensor-App (Flutter)

Eine native iOS-App, entwickelt mit **Flutter & Dart**, im **Adobe Creative Cloud Design-Stil** mit **OLED-Tiefschwarz (`#000000`)** und **lebendigem Akzent-Orange (`#FF7A00`)**. Die App erfasst sämtliche verfügbaren iPhone-Sensoren, überträgt sie an Home Assistant und bietet eine integrierte Steuerzentrale für alle im lokalen Netzwerk gefundenen Homelab-Dienste (Proxmox VE, Home Assistant, Open WebUI, Pi-hole, Jellyfin u.v.m.).

---

## 1. Zielbeschreibung & Übersicht

### Kernanforderungen
1. **Technologie**: Entwickelt in **Flutter** (Dart) mit nativer iOS-Plattformunterstützung.
2. **Sensor-Streaming an Home Assistant**:
   - Kontinuierliche oder intervallbasierte Erfassung aller relevanten iPhone-Sensoren:
     - **Akku**: Ladestand in %, Ladezustand (`charging`, `discharging`, `full`), Stromsparmodus
     - **CoreMotion**: 3-Achsen-Beschleunigung ($X, Y, Z$), Drehraten (Gyroskop), Magnetometer / Kompass
     - **Pedometer**: Schrittzähler und Distanz
     - **Barometer**: Luftdruck (hPa) & relative Höhenmeter
     - **Standort (GPS)**: Breitengrad, Längengrad, Höhe, Geschwindigkeit, Genauigkeit
     - **Netzwerk**: Wi-Fi SSID, lokale IP-Adresse (`192.168.188.x`), Verbindungstyp
     - **Gerätestatus**: Display-Helligkeit, Batteriezustand, Gerätemodell, iOS-Version
   - Direkte, zuverlässige Übertragung an Home Assistant über die REST API (`/api/states/sensor...`) mit Long-Lived Access Token.
3. **Dienste-Hub (Homelab Control Center)**:
   - Schnellzugriff auf alle im Netzwerk gefundenen Services:
     - **Home Assistant** (`http://192.168.188.25:8123`)
     - **Proxmox VE** (`https://192.168.188.20:8006`)
     - **JARVIS Hub** (`http://192.168.188.88`)
     - **Open WebUI (LLMs)** (`http://192.168.188.70:3000`)
     - **CubeCoders AMP (Game Server)** (`http://192.168.188.70:8080`)
     - **Jellyfin Media Server** (`http://192.168.188.70:8096`)
     - **Authentik SSO** (`http://192.168.188.70:9000`)
     - **Takle Intercom** (`http://192.168.188.71:8080`)
     - **Pi-hole DNS & Adblock** (`http://192.168.188.83/admin`)
     - **File Browser** (`http://192.168.188.125:8080`)
     - **VoceChat** (`http://192.168.188.125:3000`)
     - **Philips Hue Bridge** (`http://192.168.188.192`)
     - **Router / Gateway** (`https://192.168.188.1`)
   - **In-App WebView**: Ausgestattet mit automatischer Akzeptanz selbstsignierter SSL-Zertifikate (`onReceivedServerTrustAuthRequest` für Proxmox VE und Hue Bridge) sowie Navigation-Toolbar (Zurück, Vorwärts, Neu laden, Externe Browser-Option).
   - **Live-Latenz & Status**: Hintergrund-Ping für jeden Dienst mit grünem/rotem Puls-Indikator.
   - **Subnetz-Discovery**: Integrierter Scanner für das Subnetz `192.168.188.0/24`.
4. **Adobe OLED Dark UI**:
   - Hintergrund: Echtes Tiefschwarz (`#000000` / True OLED Black).
   - Akzent: Adobe Creative Orange (`#FF7A00` / `#FF8A00`).
   - Oberflächen: Anthrazit Dark Slate (`#0E0E11` / `#16161A`) mit 1px-Bordern (`#26262B`).
   - Typografie: Klare, minimalistische Schrift mit Monospace-Zahlen für Telemetriedaten.

---

## 2. Flutter Dependencies (`pubspec.yaml`)

| Paket | Zweck |
|---|---|
| `flutter_inappwebview` | In-App WebView mit SSL-Bypass für Proxmox & lokale Zertifikate |
| `sensors_plus` | Beschleunigungsmesser, Gyroskop, Magnetometer |
| `battery_plus` | Batteriestand, Ladestatus, Stromsparmodus |
| `geolocator` | GPS-Ortung, Höhe, Geschwindigkeit, Himmelsrichtung |
| `pedometer` | Schrittzähler über Apple CoreMotion |
| `network_info_plus` | Wi-Fi SSID, lokale IP-Adresse |
| `device_info_plus` | Gerätemodell, iOS Version, Hardwaredaten |
| `screen_brightness` | Displayhelligkeit |
| `http` | REST-API Übertragung an Home Assistant & Latenz-Ping |
| `provider` | State Management für Sensoren, Einstellungen und Hub |
| `shared_preferences` | Persistenz für Token, IP und Konfiguration |
| `cupertino_icons` | Apple / iOS Vektor-Icons |

---

## 3. Geplante Komponenten & Dateistruktur

```
eigenapp-fuer-ios/
├── PLAN.md                               # Dieses Dokument direkt im Projektverzeichnis
├── pubspec.yaml                          # Flutter Paket- und Asset-Definitionen
├── analysis_options.yaml                 # Strenge Dart Linter-Regeln
├── ios/
│   ├── Runner/
│   │   ├── Info.plist                    # iOS Berechtigungen (Sensoren, Location, Local Network, ATS)
│   │   └── AppDelegate.swift
├── lib/
│   ├── main.dart                         # Haupteinstieg, Theme & Provider Initialisierung
│   ├── theme/
│   │   ├── adobe_colors.dart             # OLED Schwarz (#000000), Orange (#FF7A00), Slate-Töne
│   │   └── adobe_theme.dart              # ThemeData, Card-Styles, Schriften
│   ├── models/
│   │   ├── service_item.dart             # Datenmodell für Homelab-Dienst (Name, URL, Icon, Kategorie, Status)
│   │   └── sensor_payload.dart           # Datenmodell aller aggregierten Sensordaten
│   ├── services/
│   │   ├── ha_api_service.dart           # Home Assistant REST Client (sendet Sensorwerte)
│   │   ├── sensor_collector_service.dart # Bündelt alle Flutter-Sensor-Streams
│   │   ├── network_scanner_service.dart  # Subnetz-Scan & Ping-Engine (192.168.188.x)
│   │   └── storage_service.dart          # Persistenz für Einstellungen & Konfiguration
│   ├── providers/
│   │   ├── sensor_provider.dart          # Zustand der Sensoren & automatischer Übertragungs-Timer
│   │   └── services_provider.dart        # Zustand der Dienste, Live-Ping & Filter
│   ├── screens/
│   │   ├── main_navigation_screen.dart   # Adobe TabBar (Dashboard, Services, Sensors, Settings)
│   │   ├── dashboard_screen.dart         # Hero-Übersicht: Schnellstart-Kacheln, System-Status
│   │   ├── services_screen.dart          # Komplette Dienste-Liste mit Live-Latenz und Suchleiste
│   │   ├── webview_screen.dart           # In-App Browser mit SSL-Bypass und Adobe-Navigation
│   │   ├── sensors_screen.dart           # Detaillierte Live-Sensoren mit Schaltern & "Sync Now"
│   │   └── settings_screen.dart          # Home Assistant IP/Token, Sync-Intervall, Subnetz-Scanner
│   └── widgets/
│       ├── adobe_card.dart               # Wiederverwendbare OLED-Karte mit 1px-Border
│       ├── adobe_button.dart             # Schlichter Orange/Schwarz-Aktionsbutton mit Haptik
│       ├── live_status_indicator.dart    # Pulsierender grüner/roter Punkt mit Millisekunden-Ping
│       └── sensor_gauge_tile.dart        # Visualisierung von Sensorwerten (Balken, Vektoren)
```

---

## 4. Details zur Home Assistant Übertragung

Jeder Sensor wird als Entität an Home Assistant übermittelt:
- **Ziel**: `http://192.168.188.25:8123/api/states/sensor.iphone_<sensor>`
- **Authentifizierung**: `Authorization: Bearer <TOKEN>`
- **Übertragene Sensoren**:
  - `sensor.iphone_battery` (Prozent, Ladestatus, Stromsparmodus)
  - `sensor.iphone_motion` (Beschleunigung $X, Y, Z$, Drehraten)
  - `sensor.iphone_steps` (Tages-Schrittzähler)
  - `sensor.iphone_location` (Breitengrad, Längengrad, Höhe, Geschwindigkeit)
  - `sensor.iphone_wifi` (SSID, IP-Adresse)
  - `sensor.iphone_brightness` (Display-Helligkeit)

---

## 5. Verifikation & Ausführung

1. **Abhängigkeiten auflösen**: `flutter pub get`
2. **Codeanalyse**: `flutter analyze`
3. **Ausführung auf dem iPhone**:
   - Direkt per USB / WLAN über Xcode / Flutter CLI (`flutter run -d <iPhone-ID>`).
