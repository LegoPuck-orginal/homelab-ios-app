import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'adobe_colors.dart';

class AdobeTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AdobeColors.pureBlack,
      canvasColor: AdobeColors.pureBlack,
      colorScheme: const ColorScheme.dark(
        primary: AdobeColors.orangeAccent,
        onPrimary: Colors.black,
        secondary: AdobeColors.orangeGlow,
        onSecondary: Colors.black,
        surface: AdobeColors.surfaceCard,
        onSurface: AdobeColors.textPrimary,
        error: AdobeColors.statusOffline,
        onError: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AdobeColors.pureBlack,
        foregroundColor: AdobeColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          color: AdobeColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
        shape: Border(
          bottom: BorderSide(
            color: AdobeColors.borderSubtle,
            width: 1,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: AdobeColors.surfaceCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: AdobeColors.borderCard,
            width: 1,
          ),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AdobeColors.pureBlack,
        selectedItemColor: AdobeColors.orangeAccent,
        unselectedItemColor: AdobeColors.textMuted,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: AdobeColors.borderSubtle,
        thickness: 1,
        space: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AdobeColors.surfaceBase,
        labelStyle: const TextStyle(color: AdobeColors.textSecondary, fontSize: 13),
        hintStyle: const TextStyle(color: AdobeColors.textMuted, fontSize: 13),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdobeColors.borderCard, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdobeColors.orangeAccent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdobeColors.statusOffline, width: 1),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AdobeColors.orangeAccent;
          }
          return AdobeColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AdobeColors.orangeDim;
          }
          return AdobeColors.surfaceElevated;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AdobeColors.orangeAccent.withValues(alpha: 0.5);
          }
          return AdobeColors.borderCard;
        }),
      ),
    );
  }
}
