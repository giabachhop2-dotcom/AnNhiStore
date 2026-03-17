import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An Nhi Trà iOS-native brand theme
/// Follows Apple Human Interface Guidelines
class AppTheme {
  // ── Brand Colors ──
  static const primaryDark = Color(0xFF1B322A);
  static const primaryBg = Color(0xFFF0ECE4);
  static const accentGold = Color(0xFFB8860B);
  static const priceRed = Color(0xFFD32F2F);
  static const surfaceWhite = Colors.white;
  static const textMuted = Color(0xFF8E8E93); // iOS systemGray
  static const textPrimary = Color(0xFF1C1C1E); // iOS label
  static const textSecondary = Color(0xFF3C3C43); // iOS secondaryLabel
  static const separator = Color(0xFFC6C6C8); // iOS separator
  static const groupedBg = Color(0xFFF2F2F7); // iOS systemGroupedBackground

  // ── Animation Constants ──
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Curve springCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  /// iOS Cupertino theme
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: primaryDark,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: surfaceWhite,
      scaffoldBackgroundColor: groupedBg,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryDark,
        navTitleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: textPrimary,
          letterSpacing: -0.41,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 34,
          color: textPrimary,
          letterSpacing: 0.37,
        ),
      ),
    );
  }

  /// Material theme fallback (for widgets that require MaterialApp)
  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentGold,
        surface: surfaceWhite,
        error: priceRed,
      ),
      scaffoldBackgroundColor: groupedBg,
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: separator.withValues(alpha: 0.3)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: separator),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  /// Set iOS status bar style
  static void setStatusBarStyle({bool dark = true}) {
    SystemChrome.setSystemUIOverlayStyle(
      dark
          ? SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent)
          : SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
    );
  }

  // ── Dark Mode Colors ──
  static const darkSurface = Color(0xFF1C1C1E);
  static const darkGroupedBg = Color(0xFF000000);
  static const darkElevated = Color(0xFF2C2C2E);
  static const darkSeparator = Color(0xFF38383A);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFFEBEBF5);

  /// Dark Cupertino theme
  static CupertinoThemeData get darkCupertinoTheme {
    return const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: accentGold,
      primaryContrastingColor: CupertinoColors.black,
      barBackgroundColor: darkSurface,
      scaffoldBackgroundColor: darkGroupedBg,
      textTheme: CupertinoTextThemeData(
        primaryColor: accentGold,
        navTitleTextStyle: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: darkTextPrimary,
          letterSpacing: -0.41,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 34,
          color: darkTextPrimary,
          letterSpacing: 0.37,
        ),
      ),
    );
  }

  /// Dark Material theme
  static ThemeData get darkMaterialTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        brightness: Brightness.dark,
        primary: accentGold,
        secondary: primaryDark,
        surface: darkSurface,
        error: priceRed,
      ),
      scaffoldBackgroundColor: darkGroupedBg,
      cardTheme: CardThemeData(
        color: darkElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: darkSeparator.withValues(alpha: 0.3)),
        ),
      ),
    );
  }
}
