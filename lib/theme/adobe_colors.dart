import 'package:flutter/material.dart';

/// Adobe Creative Suite & OLED optimierte Farbpalette.
/// Reines Tiefschwarz (#000000) für minimale Pixel-Leistungsaufnahme auf OLED-Displays,
/// kombiniert mit Adobe Signature Orange (#FF7A00) und feinen Dark Slate Konturen.
class AdobeColors {
  // Reines OLED-Schwarz
  static const Color pureBlack = Color(0xFF000000);

  // Adobe Akzent-Orange
  static const Color orangeAccent = Color(0xFFFF7A00);
  static const Color orangeGlow = Color(0xFFFF9124);
  static const Color orangeMuted = Color(0xFF803D00);
  static const Color orangeDim = Color(0x22FF7A00);

  // Dark Slate Oberflächen (für Karten & Panels)
  static const Color surfaceBase = Color(0xFF09090C);
  static const Color surfaceCard = Color(0xFF121216);
  static const Color surfaceElevated = Color(0xFF19191F);
  static const Color surfaceHover = Color(0xFF22222A);

  // 1px Konturen & Trennlinien (Adobe Border Style)
  static const Color borderSubtle = Color(0xFF202026);
  static const Color borderCard = Color(0xFF292933);
  static const Color borderActive = Color(0xFFFF7A00);

  // Typografie
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9EB0);
  static const Color textMuted = Color(0xFF5E5E6E);

  // Status & Telemetrie Indikatoren
  static const Color statusOnline = Color(0xFF00E676);
  static const Color statusWarning = Color(0xFFFFAB00);
  static const Color statusOffline = Color(0xFFFF334B);
  static const Color statusSyncing = Color(0xFF29B6F6);
}
