import 'dart:async';
import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// TEA BREWING TIMER — Exclusive USP feature
/// Circular countdown with steam animation, preset tea types.
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
  int _totalSeconds = 180; // default 3 min
  int _remainingSeconds = 0;
  bool _isRunning = false;
  bool _isDone = false;

  static const _presets = [
    _TeaPreset('Trà Xanh', '🍃', 120, '70-80°C', 'Thanh mát, chát nhẹ'),
    _TeaPreset('Trà Shan Tuyết', '🏔️', 180, '85-90°C', 'Đậm đà, vị ngọt hậu'),
    _TeaPreset('Trà Ô Long', '🫖', 240, '90-95°C', 'Hương hoa, đa lần hãm'),
    _TeaPreset('Trà Phổ Nhĩ', '🟤', 300, '95-100°C', 'Mạnh mẽ, đất mùn'),
    _TeaPreset('Hồng Trà', '🔴', 210, '90-95°C', 'Chát ngọt, dậy mùi'),
    _TeaPreset('Bạch Trà', '⚪', 90, '65-75°C', 'Nhẹ nhàng, tinh tế'),
  ];

  @override
  void initState() {
    super.initState();
    _steamController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _totalSeconds = _presets[0].seconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _steamController.dispose();
    super.dispose();
  }

  void _selectPreset(int index) {
    if (_isRunning) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selectedPresetIndex = index;
      _totalSeconds = _presets[index].seconds;
      _remainingSeconds = 0;
      _isDone = false;
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
            const SizedBox(height: 20),

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
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF1A3C28),
                                    Color(0xFF2D5E3E)
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
                                  color: AppTheme.accentGold
                                      .withValues(alpha: 0.4))
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
                                fontWeight:
                                    active ? FontWeight.w600 : FontWeight.w400,
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

            const SizedBox(height: 8),

            // Tea info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _InfoChip(
                      icon: CupertinoIcons.thermometer,
                      label: preset.temp,
                      isDark: isDark),
                  const SizedBox(width: 12),
                  _InfoChip(
                      icon: CupertinoIcons.timer,
                      label: _formatTime(preset.seconds),
                      isDark: isDark),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Text(
              preset.flavor,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                fontStyle: FontStyle.italic,
              ),
            ),

            // ── Circular Timer ──
            Expanded(
              child: Center(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Background ring
                      CustomPaint(
                        size: const Size(260, 260),
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
                          if (_isRunning) ...[
                            const SizedBox(height: 30),
                          ],
                          Text(
                            _isDone
                                ? 'Hoàn tất!'
                                : _isRunning
                                    ? _formatTime(_remainingSeconds)
                                    : _formatTime(_totalSeconds),
                            style: TextStyle(
                              fontSize: _isDone ? 28 : 48,
                              fontWeight: FontWeight.w300,
                              color: _isDone
                                  ? AppTheme.accentGold
                                  : (isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textPrimary),
                              letterSpacing: 2,
                              fontFeatures: const [
                                FontFeature.tabularFigures()
                              ],
                            ),
                          ),
                          if (_isDone) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Trà đã sẵn sàng thưởng thức 🍵',
                              style: TextStyle(
                                fontSize: 14,
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

            // ── Control buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: _isRunning
                  ? GestureDetector(
                      onTap: _stopTimer,
                      child: Container(
                        height: 52,
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
                  : GestureDetector(
                      onTap: _startTimer,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1A3C28), Color(0xFF2D5E3E)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.accentGold.withValues(alpha: 0.35),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppTheme.primaryDark.withValues(alpha: 0.3),
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
                                    ? CupertinoIcons.arrow_counterclockwise
                                    : CupertinoIcons.play_fill,
                                size: 18,
                                color: AppTheme.accentGold,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                _isDone ? 'Pha lại' : 'Bắt đầu pha trà',
                                style: const TextStyle(
                                  color: Color(0xFFF5F0E8),
                                  fontSize: 16,
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
          ],
        ),
      ),
    );
  }
}

class _TeaPreset {
  final String name, emoji, temp, flavor;
  final int seconds;
  const _TeaPreset(this.name, this.emoji, this.seconds, this.temp, this.flavor);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  const _InfoChip(
      {required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isDark ? AppTheme.accentGold : AppTheme.primaryDark),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              )),
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
      paint.color =
          AppTheme.accentGold.withValues(alpha: opacity.clamp(0.0, 1.0));

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
