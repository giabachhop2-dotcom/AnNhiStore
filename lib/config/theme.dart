import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// An Nhi Trà – Trà Đạo Classical Theme
/// Deep tea-green tones, warm parchment, antique gold accents.
/// Inspired by traditional Vietnamese/Asian tea ceremony aesthetics.
class AppTheme {
  // ── Trà Đạo Brand Colors ──
  static const primaryDark   = Color(0xFF1A3C28); // Rêu trà đậm
  static const primaryMid    = Color(0xFF2D5E3E); // Lá trà tươi
  static const primaryLight  = Color(0xFF4A7C5C); // Lá trà nhạt
  static const primaryBg     = Color(0xFFF5F0E8); // Giấy dó cổ / parchment
  static const accentGold    = Color(0xFFC49B2C); // Vàng đồng cổ
  static const priceRed      = Color(0xFFC62828); // Đỏ son
  static const surfaceWhite  = Color(0xFFFAF8F4); // Trắng ngà
  static const textPrimary   = Color(0xFF2C2416); // Mực nâu đậm
  static const textSecondary = Color(0xFF5C4E3C); // Mực nâu nhạt
  static const textMuted     = Color(0xFF8C7E6A); // Nâu bạc
  static const separator     = Color(0xFFD9CEBD); // Gạch ngà
  static const groupedBg     = Color(0xFFF0EBE0); // Nền grouped ấm

  // ── Animation Constants ──
  static const Duration animFast = Duration(milliseconds: 150);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);
  static const Curve springCurve = Curves.elasticOut;
  static const Curve smoothCurve = Curves.easeOutCubic;

  /// Cupertino theme — Trà Đạo classical style
  static CupertinoThemeData get cupertinoTheme {
    return const CupertinoThemeData(
      primaryColor: primaryDark,
      primaryContrastingColor: CupertinoColors.white,
      barBackgroundColor: surfaceWhite,
      scaffoldBackgroundColor: groupedBg,
      textTheme: CupertinoTextThemeData(
        primaryColor: primaryDark,
        navTitleTextStyle: TextStyle(
          fontFamily: 'UTMKhuccamta',
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: textPrimary,
          letterSpacing: -0.3,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: 'UTMKhuccamta',
          fontWeight: FontWeight.bold,
          fontSize: 34,
          color: textPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Material theme — classical tea ceremony
  static ThemeData get materialTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'UTMKhuccamta',
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryDark,
        primary: primaryDark,
        secondary: accentGold,
        surface: surfaceWhite,
        error: priceRed,
      ),
      scaffoldBackgroundColor: groupedBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: separator.withValues(alpha: 0.4)),
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

  // ── Dark Mode — Trà Đạo đêm (warm candlelight) ──
  static const darkSurface       = Color(0xFF241F19); // Gỗ nâu ấm
  static const darkGroupedBg     = Color(0xFF1C1814); // Nền ấm đêm trà
  static const darkElevated      = Color(0xFF322B23); // Gỗ nâu nổi
  static const darkSeparator     = Color(0xFF4A4038); // Viền gỗ ấm
  static const darkTextPrimary   = Color(0xFFF5F0E8); // Giấy dó sáng
  static const darkTextSecondary = Color(0xFFD9CEBD); // Ngà nhạt

  /// Dark Cupertino — tea ceremony by candlelight
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
          fontFamily: 'UTMKhuccamta',
          fontWeight: FontWeight.w600,
          fontSize: 17,
          color: darkTextPrimary,
          letterSpacing: -0.3,
        ),
        navLargeTitleTextStyle: TextStyle(
          fontFamily: 'UTMKhuccamta',
          fontWeight: FontWeight.bold,
          fontSize: 34,
          color: darkTextPrimary,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  /// Dark Material theme — candlelight tea
  static ThemeData get darkMaterialTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'UTMKhuccamta',
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
          side: BorderSide(color: darkSeparator.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
