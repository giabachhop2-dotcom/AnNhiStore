import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../config/theme.dart';
import '../main.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Thêm'),
            border: null,
          ),

          // ── Premium Brand Header ──
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF142E1F),
                    AppTheme.primaryDark,
                    Color(0xFF1E4A32),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Icon(
                      CupertinoIcons.leaf_arrow_circlepath,
                      size: 120,
                      color: CupertinoColors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  Positioned(
                    left: -10,
                    bottom: -10,
                    child: Icon(
                      CupertinoIcons.leaf_arrow_circlepath,
                      size: 80,
                      color: CupertinoColors.white.withValues(alpha: 0.03),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppTheme.accentGold.withValues(
                                    alpha: 0.5,
                                  ),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(13),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 56,
                                  width: 56,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'An Nhi Trà',
                                    style: TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Trà Đạo · Ấm Tử Sa · Yến Sào',
                                    style: TextStyle(
                                      color: AppTheme.accentGold.withValues(
                                        alpha: 0.9,
                                      ),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _BrandStat(value: '200+', label: 'Sản phẩm'),
                            Container(
                              width: 1,
                              height: 30,
                              color: CupertinoColors.white.withValues(
                                alpha: 0.15,
                              ),
                            ),
                            _BrandStat(value: '3', label: 'Thương hiệu'),
                            Container(
                              width: 1,
                              height: 30,
                              color: CupertinoColors.white.withValues(
                                alpha: 0.15,
                              ),
                            ),
                            _BrandStat(value: '2025', label: 'Top 10 VN'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Grid: Khám Phá ──
          SliverToBoxAdapter(
            child: _GridSection(
              title: 'KHÁM PHÁ',
              isDark: isDark,
              items: [
                _GridItem(
                  icon: CupertinoIcons.qrcode_viewfinder,
                  gradientColors: const [Color(0xFFD4A830), Color(0xFFB8860B)],
                  title: 'Nguồn Gốc',
                  onTap: () => context.push('/traceability'),
                ),
                _GridItem(
                  icon: CupertinoIcons.timer,
                  gradientColors: const [Color(0xFF26A69A), Color(0xFF00897B)],
                  title: 'Pha Trà',
                  onTap: () => context.push('/tea-timer'),
                ),
                _GridItem(
                  icon: CupertinoIcons.arrow_right_arrow_left,
                  gradientColors: const [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                  title: 'So Sánh',
                  onTap: () => context.push('/compare'),
                ),
                _GridItem(
                  icon: CupertinoIcons.table,
                  gradientColors: const [Color(0xFF5D4037), Color(0xFF795548)],
                  title: 'Bàn Trà',
                  onTap: () => context.push('/tea-table'),
                ),
              ],
            ),
          ),

          // ── Grid: Tài Khoản ──
          SliverToBoxAdapter(
            child: _GridSection(
              title: 'TÀI KHOẢN',
              isDark: isDark,
              items: [
                _GridItem(
                  icon: CupertinoIcons.person_crop_circle_badge_checkmark,
                  gradientColors: const [Color(0xFF114402), Color(0xFF1A6B0A)],
                  title: 'Đăng nhập',
                  onTap: () => context.push('/auth'),
                ),
                _GridItem(
                  icon: CupertinoIcons.heart_fill,
                  gradientColors: const [Color(0xFFE91E63), Color(0xFFC2185B)],
                  title: 'Yêu thích',
                  onTap: () => context.push('/favorites'),
                ),
                _GridItem(
                  icon: CupertinoIcons.cube_box_fill,
                  gradientColors: const [Color(0xFFFF9800), Color(0xFFF57C00)],
                  title: 'Đơn hàng',
                  onTap: () => context.push('/orders'),
                ),
                _GridItem(
                  icon: CupertinoIcons.star_circle_fill,
                  gradientColors: const [Color(0xFFD4A830), Color(0xFFB8860B)],
                  title: 'VIP',
                  onTap: () => context.push('/vip-card'),
                ),
                _GridItem(
                  icon: CupertinoIcons.calendar,
                  gradientColors: const [Color(0xFFE53935), Color(0xFFC62828)],
                  title: 'Sự Kiện',
                  onTap: () => context.push('/events'),
                ),
              ],
            ),
          ),

          // ── Grid: Thông Tin ──
          SliverToBoxAdapter(
            child: _GridSection(
              title: 'THÔNG TIN',
              isDark: isDark,
              items: [
                _GridItem(
                  icon: CupertinoIcons.info_circle_fill,
                  gradientColors: const [Color(0xFF4A90D9), Color(0xFF3478C7)],
                  title: 'Giới thiệu',
                  onTap: () => context.push('/about'),
                ),
                _GridItem(
                  icon: CupertinoIcons.mail_solid,
                  gradientColors: const [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                  title: 'Liên hệ',
                  onTap: () => context.push('/contact'),
                ),
              ],
            ),
          ),

          // ── Grid: Kết Nối ──
          SliverToBoxAdapter(
            child: settingsAsync.when(
              data: (settings) {
                final opts =
                    settings['optionsParsed'] as Map<String, dynamic>? ?? {};
                final phone = opts['hotline'] ?? opts['phone'] ?? '0827626962';
                final zalo = opts['zalo'] ?? phone;
                final website = opts['website'] ?? 'https://annhitra.com';
                final fanpage =
                    opts['fanpage'] ?? 'https://facebook.com/annhitra';

                return _GridSection(
                  title: 'KẾT NỐI',
                  isDark: isDark,
                  items: [
                    _GridItem(
                      icon: CupertinoIcons.phone_fill,
                      gradientColors: const [
                        Color(0xFF66BB6A),
                        Color(0xFF43A047),
                      ],
                      title: 'Hotline',
                      onTap: () => launchUrl(Uri.parse('tel:$phone')),
                    ),
                    _GridItem(
                      icon: CupertinoIcons.chat_bubble_2_fill,
                      gradientColors: const [
                        Color(0xFF42A5F5),
                        Color(0xFF1E88E5),
                      ],
                      title: 'Zalo',
                      onTap: () =>
                          launchUrl(Uri.parse('https://zalo.me/$zalo')),
                    ),
                    _GridItem(
                      icon: CupertinoIcons.globe,
                      gradientColors: const [
                        Color(0xFFAB47BC),
                        Color(0xFF8E24AA),
                      ],
                      title: 'Website',
                      onTap: () => launchUrl(Uri.parse(website.toString())),
                    ),
                    _GridItem(
                      icon: CupertinoIcons.person_2_fill,
                      gradientColors: const [
                        Color(0xFF5C6BC0),
                        Color(0xFF3F51B5),
                      ],
                      title: 'Facebook',
                      onTap: () => launchUrl(Uri.parse(fanpage.toString())),
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CupertinoActivityIndicator()),
              ),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // ── Settings + Share (keep as list for special widgets) ──
          SliverToBoxAdapter(
            child: _ListSection(
              title: 'CÀI ĐẶT',
              isDark: isDark,
              items: [
                _ListItem(
                  icon: CupertinoIcons.moon_fill,
                  gradientColors: const [Color(0xFF5C6BC0), Color(0xFF3949AB)],
                  title: 'Giao diện',
                  subtitle: 'Chế độ sáng / tối',
                  trailing: _ThemeModeSelector(),
                ),
                _ListItem(
                  icon: CupertinoIcons.share_up,
                  gradientColors: const [
                    AppTheme.accentGold,
                    Color(0xFFD4A830),
                  ],
                  title: 'Giới thiệu app cho bạn bè',
                  subtitle: 'Chia sẻ trải nghiệm trà đạo',
                  onTap: () {
                    try {
                      Share.share(
                        'Tải app An Nhi Trà - Trà Ngon & Ấm Tử Sa Chính Hãng 🍵\nhttps://annhitra.com',
                      );
                    } catch (_) {}
                  },
                ),
              ],
            ),
          ),

          // ── Footer ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              child: Center(
                child: Column(
                  children: [
                    Text(
                      'Phiên bản 1.1.0',
                      style: TextStyle(
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '© 2025 Phương Nam Group',
                      style: TextStyle(
                        color:
                            (isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textMuted)
                                .withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Grid Section — 2-column card grid
// ═════════════════════════════════════════════
class _GridSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<_GridItem> items;
  const _GridSection({
    required this.title,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ),
          GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: items.map((item) => item.build(context, isDark)).toList(),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Grid Item — Tap-to-scale card
// ═════════════════════════════════════════════
class _GridItem {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final VoidCallback? onTap;

  const _GridItem({
    required this.icon,
    required this.gradientColors,
    required this.title,
    this.onTap,
  });

  Widget build(BuildContext context, bool isDark) {
    return _GridCard(
      icon: icon,
      gradientColors: gradientColors,
      title: title,
      isDark: isDark,
      onTap: onTap,
    );
  }
}

class _GridCard extends StatefulWidget {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final bool isDark;
  final VoidCallback? onTap;

  const _GridCard({
    required this.icon,
    required this.gradientColors,
    required this.title,
    required this.isDark,
    this.onTap,
  });

  @override
  State<_GridCard> createState() => _GridCardState();
}

class _GridCardState extends State<_GridCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _scaleController.forward(),
      onTapUp: (_) {
        _scaleController.reverse();
        HapticFeedback.selectionClick();
        widget.onTap?.call();
      },
      onTapCancel: () => _scaleController.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: widget.isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.white.withValues(alpha: 0.7),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.gradientColors.first.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with gradient background
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.gradientColors,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: widget.gradientColors.first.withValues(
                            alpha: 0.35,
                          ),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      size: 22,
                      color: CupertinoColors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Title
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// List Section — For items needing trailing widgets (settings)
// ═════════════════════════════════════════════
class _ListSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final List<_ListItem> items;
  const _ListSection({
    required this.title,
    required this.isDark,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: List.generate(items.length * 2 - 1, (idx) {
                if (idx.isOdd) {
                  return Divider(
                    height: 0.5,
                    indent: 58,
                    color: isDark
                        ? AppTheme.darkSeparator.withValues(alpha: 0.3)
                        : AppTheme.separator.withValues(alpha: 0.4),
                  );
                }
                return items[idx ~/ 2].build(context, isDark);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListItem {
  final IconData icon;
  final List<Color> gradientColors;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  const _ListItem({
    required this.icon,
    required this.gradientColors,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  });

  Widget build(BuildContext context, bool isDark) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(9),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, size: 18, color: CupertinoColors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 14,
                  color: isDark
                      ? AppTheme.darkTextSecondary.withValues(alpha: 0.5)
                      : AppTheme.textMuted.withValues(alpha: 0.5),
                ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════
// Supporting Widgets
// ═════════════════════════════════════════════
class _BrandStat extends StatelessWidget {
  final String value;
  final String label;
  const _BrandStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.accentGold,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: CupertinoColors.white.withValues(alpha: 0.6),
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return CupertinoSlidingSegmentedControl<ThemeMode>(
      groupValue: mode,
      children: const {
        ThemeMode.system: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Tự động', style: TextStyle(fontSize: 12)),
        ),
        ThemeMode.light: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Sáng', style: TextStyle(fontSize: 12)),
        ),
        ThemeMode.dark: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Tối', style: TextStyle(fontSize: 12)),
        ),
      },
      onValueChanged: (value) {
        if (value != null) {
          ref.read(themeModeProvider.notifier).setMode(value);
        }
      },
    );
  }
}
