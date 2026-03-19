import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'design_tokens.dart';

/// An Nhi Trà – Trà Đạo Classical Theme
/// Deep tea-green tones, warm parchment, antique gold accents.
/// Inspired by traditional Vietnamese/Asian tea ceremony aesthetics.
class AppTheme {
  // ── Trà Đạo Brand Colors ──
  static const primaryDark = Color(0xFF1A3C28); // Rêu trà đậm
  static const primaryMid = Color(0xFF2D5E3E); // Lá trà tươi
  static const primaryLight = Color(0xFF4A7C5C); // Lá trà nhạt
  static const primaryBg = Color(0xFFFFF9EE); // Vàng kem nhạt
  static const accentGold = Color(0xFFC49B2C); // Vàng đồng cổ
  static const surfaceWhite = Color(0xFFFFF9EE); // Kem ấm
  static const textPrimary = Color(0xFF2C2416); // Mực nâu đậm
  static const textSecondary = Color(0xFF5C4E3C); // Mực nâu nhạt
  static const textMuted = Color(0xFF8C7E6A); // Nâu bạc
  static const separator = Color(0xFFD9CEBD); // Gạch ngà
  static const groupedBg = Color(0xFFFFF9EE); // Nền grouped vàng kem

  /// ⚠️ DEPRECATED — use BrandColors.goldMid instead
  static const priceRed = BrandColors.goldMid;

  // ── Animation Constants (delegate to design tokens) ──
  static const Duration animFast = Anim.fast;
  static const Duration animNormal = Anim.normal;
  static const Duration animSlow = Anim.slow;
  static const Curve springCurve = Anim.spring;
  static const Curve smoothCurve = Anim.smooth;

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
      colorScheme: const ColorScheme.light(
        primary: primaryDark,
        onPrimary: surfaceWhite,
        secondary: accentGold,
        onSecondary: surfaceWhite,
        surface: surfaceWhite,
        onSurface: textPrimary,
        surfaceContainerHighest: groupedBg,
        error: BrandColors.error,
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
          borderRadius: Radii.borderMd,
          side: BorderSide(color: separator.withValues(alpha: 0.4)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        border: OutlineInputBorder(
          borderRadius: Radii.borderSm,
          borderSide: BorderSide(color: separator),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
      ),
    );
  }

  /// Set iOS status bar style
  static void setStatusBarStyle({bool dark = true}) {
    SystemChrome.setSystemUIOverlayStyle(
      dark
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
    );
  }

  // ── Dark Mode — Trà Đạo đêm (deep tea-green, NOT black) ──
  static const darkSurface = Color(0xFF0F2518); // Rêu trà đậm đêm
  static const darkGroupedBg = Color(0xFF0B1E12); // Nền xanh trà sâu
  static const darkElevated = Color(0xFF162D1E); // Lá trà nổi
  static const darkSeparator = Color(0xFF2A4A35); // Viền rêu ấm
  static const darkTextPrimary = Color(0xFFF5F0E8); // Giấy dó sáng
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
      colorScheme: const ColorScheme.dark(
        primary: accentGold,
        onPrimary: darkGroupedBg,
        secondary: primaryDark,
        onSecondary: darkTextPrimary,
        surface: darkSurface,
        onSurface: darkTextPrimary,
        surfaceContainerHighest: darkGroupedBg,
        error: BrandColors.error,
      ),
      scaffoldBackgroundColor: darkGroupedBg,
      cardTheme: CardThemeData(
        color: darkElevated,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: Radii.borderMd,
          side: BorderSide(color: darkSeparator.withValues(alpha: 0.4)),
        ),
      ),
    );
  }
}
