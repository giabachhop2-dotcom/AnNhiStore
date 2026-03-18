import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// AN NHI TRÀ — DESIGN TOKENS 2.0
/// Centralized design constants for premium consistency.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

// ────────────────────────────────────────────────────
// SPACING — 4px base grid
// ────────────────────────────────────────────────────
class Spacing {
  Spacing._();
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 48;
  static const double massive = 64;

  /// Common paddings
  static const EdgeInsets screenH = EdgeInsets.symmetric(horizontal: base);
  static const EdgeInsets screenAll = EdgeInsets.all(base);
  static const EdgeInsets cardInner = EdgeInsets.all(md);
  static const EdgeInsets sectionV = EdgeInsets.symmetric(vertical: lg);
}

// ────────────────────────────────────────────────────
// RADIUS — rounded corner tokens
// ────────────────────────────────────────────────────
class Radii {
  Radii._();
  static const double xs = 6;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double pill = 999;

  static BorderRadius get borderSm => BorderRadius.circular(sm);
  static BorderRadius get borderMd => BorderRadius.circular(md);
  static BorderRadius get borderLg => BorderRadius.circular(lg);
  static BorderRadius get borderXl => BorderRadius.circular(xl);
  static BorderRadius get borderPill => BorderRadius.circular(pill);
  static BorderRadius get borderFull => BorderRadius.circular(pill);
}

// ────────────────────────────────────────────────────
// TYPOGRAPHY — Text style factory
// ────────────────────────────────────────────────────
class AppTypo {
  AppTypo._();

  // ── Display / Hero ──
  static TextStyle displayLarge(bool isDark) => TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
    height: 1.2,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  static TextStyle displayMedium(bool isDark) => TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    height: 1.25,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  // ── Headings ──
  static TextStyle heading1(bool isDark) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  static TextStyle heading2(bool isDark) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.3,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  static TextStyle heading3(bool isDark) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.35,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  // ── Body ──
  static TextStyle bodyLarge(bool isDark) => TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  static TextStyle bodyMedium(bool isDark) => TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  static TextStyle bodySmall(bool isDark) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.4,
    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
  );

  // ── Caption / Label ──
  static TextStyle caption(bool isDark) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
  );

  static TextStyle label(bool isDark) => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    height: 1.2,
    color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
  );

  // ── Special Styles ──

  /// Gold metallic price tag
  static const TextStyle priceGold = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Color(0xFFC8A96E), // Vàng đồng kim loại sáng
    letterSpacing: -0.3,
  );

  /// Large price for detail screen
  static const TextStyle priceLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: Color(0xFFC8A96E),
    letterSpacing: -0.5,
  );

  /// Sale / original price (strikethrough)
  static const TextStyle priceStrike = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.lineThrough,
    color: Color(0xFF8C7E6A),
  );

  /// "Liên hệ" italic gold tag
  static const TextStyle contactTag = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.italic,
    color: Color(0xFFC8A96E),
  );

  /// Product name on card
  static TextStyle productName(bool isDark) => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: -0.2,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  /// Category / chip label
  static TextStyle chipLabel(bool isDark) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
  );

  /// Section header "See all" link
  static const TextStyle seeAll = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: Color(0xFFC49B2C),
  );
}

// ────────────────────────────────────────────────────
// SHADOWS — elevation presets
// ────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  /// Subtle card shadow (light mode)
  static List<BoxShadow> cardLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Subtle card shadow (dark mode)
  static List<BoxShadow> cardDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Elevated card (modals, bottom sheets)
  static List<BoxShadow> elevatedLight = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  static List<BoxShadow> elevatedDark = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 6),
    ),
  ];

  /// Gold glow for CTA buttons / badges
  static List<BoxShadow> goldGlow = [
    BoxShadow(
      color: AppTheme.accentGold.withValues(alpha: 0.25),
      blurRadius: 12,
      spreadRadius: 1,
    ),
  ];

  /// Banner / hero shadow
  static List<BoxShadow> hero = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.15),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];

  /// Helper
  static List<BoxShadow> card(bool isDark) => isDark ? cardDark : cardLight;
  static List<BoxShadow> elevated(bool isDark) =>
      isDark ? elevatedDark : elevatedLight;
}

// ────────────────────────────────────────────────────
// GRADIENTS — brand gradient presets
// ────────────────────────────────────────────────────
class AppGradients {
  AppGradients._();

  /// Primary tea-green gradient (headers, CTAs)
  static const LinearGradient teaGreen = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1A3C28), Color(0xFF2D5E3E)],
  );

  /// Gold shimmer gradient (price badges, accents)
  static const LinearGradient gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC49B2C), Color(0xFFD4AF47), Color(0xFFC8A96E)],
  );

  /// Warm parchment gradient (light mode cards)
  static const LinearGradient parchment = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8F4EC), Color(0xFFF0E8D8)],
  );

  /// Dark elevated gradient (dark mode cards)
  static const LinearGradient darkCard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF16291E), Color(0xFF0D1F14)],
  );

  /// Overlay gradient for images (bottom fade)
  static LinearGradient imageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
  );

  /// Hero category card gradient
  static LinearGradient heroCategoryCard(Color accent) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent.withValues(alpha: 0.15), accent.withValues(alpha: 0.05)],
  );
}

// ────────────────────────────────────────────────────
// ANIMATION TOKENS
// ────────────────────────────────────────────────────
class Anim {
  Anim._();

  // Durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration page = Duration(milliseconds: 400);

  // Curves
  static const Curve springy = Curves.elasticOut;
  static const Curve smooth = Curves.easeOutCubic;
  static const Curve spring = Curves.elasticOut;
  static const Curve decelerate = Curves.decelerate;
  static const Curve sharp = Curves.easeInOutCubic;

  /// Stagger delay for list items (index * stagger)
  static Duration stagger(int index) =>
      Duration(milliseconds: 50 + (index * 60).clamp(0, 400));
}

// ────────────────────────────────────────────────────
// BRAND COLORS — extended palette
// ────────────────────────────────────────────────────
class BrandColors {
  BrandColors._();

  /// Product type accent colors
  static const Color amTuSa = Color(0xFF8B4513); // Sienna / đất nung
  static const Color tra = Color(0xFF2E7D32); // Xanh lá đậm
  static const Color traCu = Color(0xFF5D4037); // Nâu gỗ
  static const Color quaTang = Color(0xFFC62828); // Đỏ quà tặng

  /// Status colors
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFE65100);
  static const Color info = Color(0xFF1565C0);
  static const Color zalo = Color(0xFF0068FF);

  /// Gold variants
  static const Color goldLight = Color(0xFFD4AF47);
  static const Color goldMid = Color(0xFFC8A96E);
  static const Color goldDark = Color(0xFFC49B2C);
  static const Color goldSubtle = Color(0x1AC8A96E); // 10% opacity
}
