import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// TEA BREWING TIMER — Based on real tea brewing research
/// Supports 3 strength levels per tea type + multiple infusions.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeaBrewingTimerScreen extends StatefulWidget {
  const TeaBrewingTimerScreen({super.key});

  @override
  State<TeaBrewingTimerScreen> createState() => _TeaBrewingTimerScreenState();
}

class _TeaBrewingTimerScreenState extends State<TeaBrewingTimerScreen>
    with TickerProviderStateMixin {
  late AnimationController _steamController;

  // Timer state
  Timer? _timer;
  int _selectedPresetIndex = 0;
  int _selectedStrength = 1; // 0=nhạt, 1=vừa, 2=đậm
  int _infusionNumber = 1; // Lần pha thứ mấy
  int _totalSeconds = 60;
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isDone = false;

  // ── Tea presets based on real brewing research ──
  // Sources: hacoocha.com, tamviet.net.vn, minhtea.com, artoftea.com, etc.
  static const _presets = [
    _TeaPreset(
      name: 'Trà Shan Tuyết',
      emoji: '🏔️',
      temp: '85-95°C',
      flavor: 'Đậm đà, vị ngọt hậu, pha được 4-8 nước',
      lightSeconds: 30, // Nhạt: 30s
      mediumSeconds: 60, // Vừa: 1 phút
      strongSeconds: 90, // Đậm: 1.5 phút
      infusionAdd: 15, // Mỗi lần pha thêm +15s
      maxInfusions: 8,
      tips: 'Tráng trà 5s trước khi pha. Nước 3-5 ngon nhất.',
    ),
    _TeaPreset(
      name: 'Trà Xanh',
      emoji: '🍃',
      temp: '70-80°C',
      flavor: 'Thanh mát, chát nhẹ, hậu ngọt',
      lightSeconds: 60, // 1 phút
      mediumSeconds: 120, // 2 phút
      strongSeconds: 180, // 3 phút
      infusionAdd: 30,
      maxInfusions: 3,
      tips: 'KHÔNG dùng nước sôi 100°C — sẽ làm cháy lá, gây đắng.',
    ),
    _TeaPreset(
      name: 'Trà Ô Long',
      emoji: '🫖',
      temp: '90-95°C',
      flavor: 'Hương hoa, đa lần hãm, bán lên men 30-40%',
      lightSeconds: 120, // 2 phút
      mediumSeconds: 180, // 3 phút
      strongSeconds: 300, // 5 phút
      infusionAdd: 20,
      maxInfusions: 7,
      tips: 'Ô Long nhẹ (hoa): 85°C. Ô Long rang đậm: 95°C.',
    ),
    _TeaPreset(
      name: 'Phổ Nhĩ Chín',
      emoji: '🟤',
      temp: '95-100°C',
      flavor: 'Mạnh mẽ, đất mùn, vị ngọt sâu',
      lightSeconds: 120, // 2 phút
      mediumSeconds: 180, // 3 phút
      strongSeconds: 300, // 5 phút
      infusionAdd: 15,
      maxInfusions: 10,
      tips: 'Tráng trà 10s bắt buộc. Có thể pha tới 10 nước.',
    ),
    _TeaPreset(
      name: 'Hồng Trà',
      emoji: '🔴',
      temp: '90-100°C',
      flavor: 'Chát ngọt, dậy mùi, hậu vị kéo dài',
      lightSeconds: 180, // 3 phút
      mediumSeconds: 240, // 4 phút
      strongSeconds: 300, // 5 phút
      infusionAdd: 30,
      maxInfusions: 3,
      tips: 'Darjeeling: 85-90°C. Hồng trà Shan Tuyết: 90-95°C.',
    ),
    _TeaPreset(
      name: 'Bạch Trà',
      emoji: '⚪',
      temp: '65-75°C',
      flavor: 'Nhẹ nhàng, tinh tế, oxy hóa <5%',
      lightSeconds: 60, // 1 phút
      mediumSeconds: 120, // 2 phút
      strongSeconds: 180, // 3 phút
      infusionAdd: 30,
      maxInfusions: 5,
      tips: 'Búp non sáng sớm, héo mát 48h. Nhiệt thấp nhất.',
    ),
  ];

  static const _strengthLabels = ['Nhạt', 'Vừa', 'Đậm'];
  static const _strengthEmoji = ['💧', '🍵', '🔥'];

  @override
  void initState() {
    super.initState();
    _steamController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _updateTime();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _steamController.dispose();
    super.dispose();
  }

  void _updateTime() {
    final preset = _presets[_selectedPresetIndex];
    final baseSec = _selectedStrength == 0
        ? preset.lightSeconds
        : _selectedStrength == 1
        ? preset.mediumSeconds
        : preset.strongSeconds;
    // Each subsequent infusion adds time
    _totalSeconds = baseSec + ((_infusionNumber - 1) * preset.infusionAdd);
  }

  void _selectPreset(int index) {
    if (_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPresetIndex = index;
      _infusionNumber = 1;
      _remainingSeconds = 0;
      _isDone = false;
      _updateTime();
    });
  }

  void _selectStrength(int strength) {
    if (_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedStrength = strength;
      _remainingSeconds = 0;
      _isDone = false;
      _updateTime();
    });
  }

  void _startTimer() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isRunning = true;
      _isDone = false;
      _remainingSeconds = _totalSeconds;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 0) {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
        setState(() {
          _isRunning = false;
          _isDone = true;
        });
        return;
      }
      setState(() => _remainingSeconds--);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    HapticFeedback.lightImpact();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 0;
      _isDone = false;
    });
  }

  void _nextInfusion() {
    final preset = _presets[_selectedPresetIndex];
    if (_infusionNumber >= preset.maxInfusions) return;
    HapticFeedback.selectionClick();
    setState(() {
      _infusionNumber++;
      _isDone = false;
      _remainingSeconds = 0;
      _updateTime();
    });
  }

  void _resetInfusion() {
    HapticFeedback.lightImpact();
    setState(() {
      _infusionNumber = 1;
      _isDone = false;
      _remainingSeconds = 0;
      _updateTime();
    });
  }

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final preset = _presets[_selectedPresetIndex];
    final progress = _isRunning || _isDone
        ? 1 - (_remainingSeconds / _totalSeconds)
        : 0.0;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Hẹn Giờ Pha Trà'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ── Tea type presets (horizontal chips) ──
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _presets.length,
                itemBuilder: (context, i) {
                  final p = _presets[i];
                  final active = i == _selectedPresetIndex;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => _selectPreset(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1A3C28),
                                    Color(0xFF2D5E3E),
                                  ],
                                )
                              : null,
                          color: active
                              ? null
                              : (isDark
                                    ? AppTheme.darkElevated
                                    : AppTheme.groupedBg),
                          borderRadius: BorderRadius.circular(22),
                          border: active
                              ? Border.all(
                                  color: AppTheme.accentGold.withValues(
                                    alpha: 0.4,
                                  ),
                                )
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(p.emoji, style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              p.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: active
                                    ? CupertinoColors.white
                                    : (isDark
                                          ? AppTheme.darkTextPrimary
                                          : AppTheme.textPrimary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // ── Strength selector (nhạt / vừa / đậm) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: List.generate(3, (i) {
                    final active = i == _selectedStrength;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => _selectStrength(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? (isDark
                                      ? AppTheme.primaryDark
                                      : AppTheme.primaryDark)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: active
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryDark.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                _strengthEmoji[i],
                                style: const TextStyle(fontSize: 14),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _strengthLabels[i],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: active
                                      ? CupertinoColors.white
                                      : (isDark
                                            ? AppTheme.darkTextSecondary
                                            : AppTheme.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── Info row: temp + time + infusion ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(
                    icon: CupertinoIcons.thermometer,
                    label: preset.temp,
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: CupertinoIcons.timer,
                    label: _formatTime(_totalSeconds),
                    isDark: isDark,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: CupertinoIcons.drop,
                    label: 'Nước $_infusionNumber/${preset.maxInfusions}',
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 4),

            // ── Flavor + tips ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                preset.flavor,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textMuted,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),

            // ── Circular Timer ──
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 240,
                  height: 240,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background ring
                      CustomPaint(
                        size: const Size(240, 240),
                        painter: _TimerRingPainter(
                          progress: progress,
                          isDone: _isDone,
                          isDark: isDark,
                        ),
                      ),
                      // Steam animation (when brewing)
                      if (_isRunning)
                        AnimatedBuilder(
                          animation: _steamController,
                          builder: (_, __) => CustomPaint(
                            size: const Size(80, 60),
                            painter: _SteamPainter(
                              progress: _steamController.value,
                            ),
                          ),
                        ),
                      // Time display
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isRunning) ...[const SizedBox(height: 30)],
                          Text(
                            _isDone
                                ? 'Hoàn tất!'
                                : _isRunning
                                ? _formatTime(_remainingSeconds)
                                : _formatTime(_totalSeconds),
                            style: TextStyle(
                              fontSize: _isDone ? 26 : 44,
                              fontWeight: FontWeight.w300,
                              color: _isDone
                                  ? AppTheme.accentGold
                                  : (isDark
                                        ? AppTheme.darkTextPrimary
                                        : AppTheme.textPrimary),
                              letterSpacing: 2,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                          if (_isDone) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Trà đã sẵn sàng thưởng thức 🍵',
                              style: TextStyle(
                                fontSize: 13,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Tips bar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.accentGold.withValues(alpha: 0.1)
                      : AppTheme.accentGold.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        preset.tips,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Control buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: _isRunning
                  ? // Stop button
                    GestureDetector(
                      onTap: _stopTimer,
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.priceRed.withValues(alpha: 0.6),
                            width: 1.5,
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Dừng lại',
                            style: TextStyle(
                              color: AppTheme.priceRed,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                  : // Start / Next infusion buttons
                    Row(
                      children: [
                        // Main start/restart button
                        Expanded(
                          child: GestureDetector(
                            onTap: _startTimer,
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF1A3C28),
                                    Color(0xFF2D5E3E),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.accentGold.withValues(
                                    alpha: 0.35,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryDark.withValues(
                                      alpha: 0.3,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _isDone
                                          ? CupertinoIcons
                                                .arrow_counterclockwise
                                          : CupertinoIcons.play_fill,
                                      size: 18,
                                      color: AppTheme.accentGold,
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      _isDone ? 'Pha lại' : 'Bắt đầu pha trà',
                                      style: TextStyle(
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : const Color(0xFFF5F0E8),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        // Next infusion button (only when done and more infusions left)
                        if (_isDone &&
                            _infusionNumber < preset.maxInfusions) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _nextInfusion,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: AppTheme.accentGold,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.drop_fill,
                                  size: 20,
                                  color: CupertinoColors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                        // Reset infusions
                        if (_infusionNumber > 1 && !_isRunning) ...[
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _resetInfusion,
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isDark
                                      ? AppTheme.darkSeparator
                                      : AppTheme.separator,
                                ),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Icon(
                                  CupertinoIcons.refresh,
                                  size: 18,
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ── Tea preset with 3 strength levels ──
class _TeaPreset {
  final String name, emoji, temp, flavor, tips;
  final int lightSeconds, mediumSeconds, strongSeconds;
  final int infusionAdd, maxInfusions;

  const _TeaPreset({
    required this.name,
    required this.emoji,
    required this.temp,
    required this.flavor,
    required this.lightSeconds,
    required this.mediumSeconds,
    required this.strongSeconds,
    required this.infusionAdd,
    required this.maxInfusions,
    required this.tips,
  });
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: isDark ? AppTheme.accentGold : AppTheme.primaryDark,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ring painter with gradient arc
class _TimerRingPainter extends CustomPainter {
  final double progress;
  final bool isDone;
  final bool isDark;

  _TimerRingPainter({
    required this.progress,
    required this.isDone,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 6.0;

    // Background ring
    final bgPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = isDark
          ? AppTheme.darkSeparator.withValues(alpha: 0.3)
          : AppTheme.separator.withValues(alpha: 0.2);
    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Progress arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final sweepAngle = 2 * pi * progress;

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweepAngle,
        colors: isDone
            ? [AppTheme.accentGold, const Color(0xFF8B6914)]
            : [AppTheme.primaryDark, const Color(0xFF4A7C5C)],
      ).createShader(rect);

    canvas.drawArc(rect, -pi / 2, sweepAngle, false, progressPaint);

    // Glow dot at end of arc
    final dotAngle = -pi / 2 + sweepAngle;
    final dotX = center.dx + cos(dotAngle) * radius;
    final dotY = center.dy + sin(dotAngle) * radius;
    final dotPaint = Paint()
      ..color = isDone ? AppTheme.accentGold : AppTheme.primaryDark;
    canvas.drawCircle(Offset(dotX, dotY), 5, dotPaint);

    // Glow
    final glowPaint = Paint()
      ..color = (isDone ? AppTheme.accentGold : AppTheme.primaryDark)
          .withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(dotX, dotY), 8, glowPaint);
  }

  @override
  bool shouldRepaint(_TimerRingPainter old) =>
      old.progress != progress || old.isDone != isDone;
}

/// Steam animation painter
class _SteamPainter extends CustomPainter {
  final double progress;
  _SteamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 3; i++) {
      final offset = i * 0.33;
      final t = (progress + offset) % 1.0;
      final opacity = (1 - t) * 0.4;
      paint.color = AppTheme.accentGold.withValues(
        alpha: opacity.clamp(0.0, 1.0),
      );

      final x = size.width * (0.3 + i * 0.2);
      final startY = size.height;
      final endY = size.height * (1 - t * 0.8);

      final path = Path();
      path.moveTo(x, startY);
      path.cubicTo(
        x + sin(t * pi * 2) * 8,
        startY - (startY - endY) * 0.33,
        x - sin(t * pi * 2) * 6,
        startY - (startY - endY) * 0.66,
        x + sin(t * pi * 3) * 4,
        endY,
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_SteamPainter old) => true;
}
