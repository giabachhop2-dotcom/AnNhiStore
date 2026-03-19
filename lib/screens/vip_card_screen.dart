import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// DIGITAL VIP CARD — Membership card with points
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class VipCardScreen extends StatefulWidget {
  const VipCardScreen({super.key});

  @override
  State<VipCardScreen> createState() => _VipCardScreenState();
}

class _VipCardScreenState extends State<VipCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  String _memberName = '';
  String _memberId = '';
  int _points = 0;
  String _tier = 'Silver';

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _loadMemberData();
  }

  Future<void> _loadMemberData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _memberName = prefs.getString('vip_name') ?? '';
      _memberId = prefs.getString('vip_id') ?? _generateId();
      _points = prefs.getInt('vip_points') ?? 0;
      _tier = _points >= 5000
          ? 'Diamond'
          : (_points >= 2000 ? 'Gold' : 'Silver');
    });
    if (prefs.getString('vip_id') == null) {
      await prefs.setString('vip_id', _memberId);
    }
  }

  String _generateId() {
    final r = Random();
    return 'ANT${DateTime.now().year}-${r.nextInt(9000) + 1000}';
  }

  Future<void> _register() async {
    final nameCtrl = TextEditingController();
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Đăng ký thành viên'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: nameCtrl,
            placeholder: 'Nhập họ tên của bạn',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context, nameCtrl.text.trim()),
            child: const Text('Đăng ký'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vip_name', result);
      await prefs.setInt('vip_points', 100); // Welcome bonus
      HapticFeedback.heavyImpact();
      _loadMemberData();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Thẻ Thành Viên'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ── VIP Card ──
              AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, _) {
                  return Container(
                    width: double.infinity,
                    height: 210,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: _tier == 'Diamond'
                            ? [
                                const Color(0xFF1A1A2E),
                                const Color(0xFF16213E),
                                const Color(0xFF0F3460),
                              ]
                            : _tier == 'Gold'
                            ? [
                                const Color(0xFF8B6914),
                                const Color(0xFFD4A830),
                                const Color(0xFF8B6914),
                              ]
                            : [
                                const Color(0xFF374151),
                                const Color(0xFF6B7280),
                                const Color(0xFF374151),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color:
                              (_tier == 'Gold'
                                      ? AppTheme.accentGold
                                      : const Color(0xFF6B7280))
                                  .withValues(alpha: 0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Shimmer sweep
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: CustomPaint(
                              painter: _CardShimmerPainter(
                                progress: _shimmerController.value,
                              ),
                            ),
                          ),
                        ),
                        // Content
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'AN NHI TRÀ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _tier.toUpperCase(),
                                      style: TextStyle(
                                        color: _tier == 'Gold'
                                            ? const Color(0xFFFFD700)
                                            : _tier == 'Diamond'
                                            ? const Color(0xFF87CEEB)
                                            : Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Text(
                                _memberId,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                  letterSpacing: 3,
                                  fontFeatures: [FontFeature.tabularFigures()],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _memberName.isEmpty
                                        ? 'Chưa đăng ký'
                                        : _memberName.toUpperCase(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text(
                                        'ĐIỂM',
                                        style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      Text(
                                        '$_points',
                                        style: TextStyle(
                                          color: _tier == 'Gold'
                                              ? const Color(0xFFFFD700)
                                              : Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // Register button if not registered
              if (_memberName.isEmpty)
                GestureDetector(
                  onTap: _register,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A3C28), Color(0xFF2D5E3E)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.accentGold.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.person_badge_plus,
                          color: AppTheme.accentGold,
                          size: 18,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Đăng ký thành viên — nhận 100 điểm',
                          style: TextStyle(
                            color: Color(0xFFF5F0E8),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Tier progress
              _buildTierProgress(isDark),

              const SizedBox(height: 20),

              // Benefits
              _buildBenefits(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierProgress(bool isDark) {
    const tiers = [
      ('Silver', 0, CupertinoIcons.shield, Color(0xFF9E9E9E)),
      ('Gold', 2000, CupertinoIcons.shield_fill, Color(0xFFFFD700)),
      ('Diamond', 5000, CupertinoIcons.sparkles, Color(0xFF87CEEB)),
    ];
    final currentTierIdx = tiers.indexWhere((t) => t.$1 == _tier);
    final nextTier = currentTierIdx < 2 ? tiers[currentTierIdx + 1] : null;
    final progress = nextTier != null
        ? (_points / nextTier.$2).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    tiers[currentTierIdx].$3,
                    size: 18,
                    color: tiers[currentTierIdx].$4,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hạng hiện tại: $_tier',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              if (nextTier != null)
                Row(
                  children: [
                    Icon(nextTier.$3, size: 14, color: nextTier.$4),
                    const SizedBox(width: 4),
                    Text(
                      'Còn ${nextTier.$2 - _points} điểm',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: isDark
                  ? AppTheme.darkSeparator
                  : AppTheme.separator.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                _tier == 'Diamond'
                    ? const Color(0xFF87CEEB)
                    : AppTheme.accentGold,
              ),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits(bool isDark) {
    const benefits = [
      (
        CupertinoIcons.gift_fill,
        'Tặng quà sinh nhật',
        'Voucher 200K cho thành viên Gold+',
        Color(0xFFE57373),
      ),
      (
        CupertinoIcons.car_fill,
        'Miễn phí giao hàng',
        'Đơn từ 500K cho thành viên Silver+',
        Color(0xFF64B5F6),
      ),
      (
        CupertinoIcons.tag_fill,
        'Giảm giá độc quyền',
        'Ưu đãi 15% cho Diamond member',
        Color(0xFFBA68C8),
      ),
      (
        Icons.emoji_food_beverage_rounded,
        'Workshop trà đạo',
        'Tham gia miễn phí 2 lần/năm',
        Color(0xFF81C784),
      ),
      (
        CupertinoIcons.cube_box_fill,
        'Gói quà premium',
        'Hộp sơn mài miễn phí cho Gold+',
        Color(0xFFFFB74D),
      ),
      (
        CupertinoIcons.star_fill,
        'Tích điểm đổi quà',
        'Mỗi 10.000₫ = 1 điểm tích lũy',
        AppTheme.accentGold,
      ),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quyền lợi thành viên',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...benefits.map(
            (b) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(b.$1, size: 20, color: b.$4),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.$2,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                            color: isDark
                                ? AppTheme.darkTextPrimary
                                : AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          b.$3,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardShimmerPainter extends CustomPainter {
  final double progress;
  _CardShimmerPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final shimmerWidth = size.width * 0.3;
    final x = -shimmerWidth + (size.width + shimmerWidth * 2) * progress;

    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.white.withValues(alpha: 0),
          Colors.white.withValues(alpha: 0.06),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(x, 0, shimmerWidth, size.height));

    canvas.drawRect(Rect.fromLTWH(x, 0, shimmerWidth, size.height), paint);
  }

  @override
  bool shouldRepaint(_CardShimmerPainter old) => true;
}
