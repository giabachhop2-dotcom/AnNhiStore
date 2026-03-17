import 'dart:math';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// TEA LEAF CELEBRATION — Bespoke confetti for orders
/// Floating tea leaves, gold sparkles, gentle drift.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeaLeafCelebration extends StatefulWidget {
  final Widget child;
  final bool showCelebration;

  const TeaLeafCelebration({
    super.key,
    required this.child,
    this.showCelebration = false,
  });

  @override
  State<TeaLeafCelebration> createState() => _TeaLeafCelebrationState();
}

class _TeaLeafCelebrationState extends State<TeaLeafCelebration>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
  }

  @override
  void didUpdateWidget(TeaLeafCelebration old) {
    super.didUpdateWidget(old);
    if (widget.showCelebration && !old.showCelebration) {
      _spawnParticles();
      _controller.forward(from: 0);
    }
  }

  void _spawnParticles() {
    _particles.clear();
    for (int i = 0; i < 35; i++) {
      _particles.add(_Particle(
        x: _rng.nextDouble(),
        startDelay: _rng.nextDouble() * 0.3,
        speed: 0.4 + _rng.nextDouble() * 0.6,
        drift: (_rng.nextDouble() - 0.5) * 0.3,
        rotation: _rng.nextDouble() * 2 * pi,
        rotationSpeed: (_rng.nextDouble() - 0.5) * 4,
        size: 12 + _rng.nextDouble() * 14,
        type: _rng.nextInt(4), // 0=leaf, 1=sparkle, 2=dot, 3=tea steam
        color: [
          AppTheme.accentGold,
          AppTheme.primaryDark,
          const Color(0xFF8B6914),
          const Color(0xFF4A7C5C),
          const Color(0xFFD4A830),
        ][_rng.nextInt(5)],
      ));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showCelebration)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _CelebrationPainter(
                      particles: _particles,
                      progress: _controller.value,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _Particle {
  final double x;
  final double startDelay;
  final double speed;
  final double drift;
  final double rotation;
  final double rotationSpeed;
  final double size;
  final int type;
  final Color color;

  _Particle({
    required this.x,
    required this.startDelay,
    required this.speed,
    required this.drift,
    required this.rotation,
    required this.rotationSpeed,
    required this.size,
    required this.type,
    required this.color,
  });
}

class _CelebrationPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _CelebrationPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = ((progress - p.startDelay) / (1 - p.startDelay)).clamp(0.0, 1.0);
      if (t <= 0) continue;

      // Fade out in last 30%
      final opacity = t > 0.7 ? (1 - (t - 0.7) / 0.3) : 1.0;
      final paint = Paint()..color = p.color.withValues(alpha: opacity * 0.8);

      final x = p.x * size.width + sin(t * pi * 3) * p.drift * size.width;
      final y = -p.size + t * (size.height + p.size * 2) * p.speed;
      final angle = p.rotation + t * p.rotationSpeed * pi;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      switch (p.type) {
        case 0: // Tea leaf shape
          _drawLeaf(canvas, paint, p.size);
          break;
        case 1: // Gold sparkle
          _drawSparkle(canvas, paint, p.size * 0.6);
          break;
        case 2: // Small dot
          canvas.drawCircle(Offset.zero, p.size * 0.2, paint);
          break;
        case 3: // Tea steam curl
          _drawSteamCurl(canvas, paint, p.size * 0.5);
          break;
      }

      canvas.restore();
    }
  }

  void _drawLeaf(Canvas canvas, Paint paint, double sz) {
    final path = Path();
    path.moveTo(0, -sz / 2);
    path.cubicTo(sz * 0.5, -sz * 0.3, sz * 0.4, sz * 0.3, 0, sz / 2);
    path.cubicTo(-sz * 0.4, sz * 0.3, -sz * 0.5, -sz * 0.3, 0, -sz / 2);
    canvas.drawPath(path, paint);

    // Leaf vein
    final veinPaint = Paint()
      ..color = paint.color.withValues(alpha: 0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, -sz * 0.35), Offset(0, sz * 0.35), veinPaint);
  }

  void _drawSparkle(Canvas canvas, Paint paint, double sz) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = (i / 4) * pi * 2;
      final outerX = cos(angle) * sz;
      final outerY = sin(angle) * sz;
      final innerAngle = angle + pi / 4;
      final innerX = cos(innerAngle) * sz * 0.3;
      final innerY = sin(innerAngle) * sz * 0.3;
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawSteamCurl(Canvas canvas, Paint paint, double sz) {
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.5;
    paint.strokeCap = StrokeCap.round;
    final path = Path();
    path.moveTo(0, sz);
    path.cubicTo(sz * 0.3, sz * 0.5, -sz * 0.3, 0, 0, -sz * 0.5);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CelebrationPainter old) => old.progress != progress;
}
