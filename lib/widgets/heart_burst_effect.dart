import 'dart:math';
import 'package:flutter/material.dart';

/// Heart burst particle effect — shows tiny particles exploding outward
/// when the user taps the favorite heart icon.
class HeartBurstEffect extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final Color burstColor;
  final VoidCallback onTap;

  const HeartBurstEffect({
    super.key,
    required this.child,
    required this.isActive,
    required this.onTap,
    this.burstColor = const Color(0xFFE53935),
  });

  @override
  State<HeartBurstEffect> createState() => _HeartBurstEffectState();
}

class _HeartBurstEffectState extends State<HeartBurstEffect>
    with TickerProviderStateMixin {
  late AnimationController _burstController;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnim;
  final List<_Particle> _particles = [];
  final _rand = Random();
  bool _wasPreviouslyActive = false;

  @override
  void initState() {
    super.initState();
    _wasPreviouslyActive = widget.isActive;

    _burstController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..addListener(() => setState(() {}));

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.35)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.35, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_scaleController);
  }

  @override
  void didUpdateWidget(covariant HeartBurstEffect oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger burst when going from inactive → active
    if (widget.isActive && !_wasPreviouslyActive) {
      _triggerBurst();
    }
    _wasPreviouslyActive = widget.isActive;
  }

  void _triggerBurst() {
    _particles.clear();
    // Generate 12 particles in a radial pattern
    for (int i = 0; i < 12; i++) {
      final angle = (i / 12) * 2 * pi + (_rand.nextDouble() * 0.3 - 0.15);
      final speed = 18.0 + _rand.nextDouble() * 14;
      final size = 3.0 + _rand.nextDouble() * 3;
      _particles.add(_Particle(
        angle: angle,
        speed: speed,
        size: size,
        color: _getParticleColor(i),
      ));
    }
    _burstController.forward(from: 0);
    _scaleController.forward(from: 0);
  }

  Color _getParticleColor(int i) {
    const colors = [
      Color(0xFFE53935), // red
      Color(0xFFFF6B6B), // light red
      Color(0xFFFF8A80), // pink
      Color(0xFFFFAB91), // peach
      Color(0xFFE53935), // red
      Color(0xFFFF5252), // coral
    ];
    return colors[i % colors.length];
  }

  @override
  void dispose() {
    _burstController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // Particles
            if (_burstController.isAnimating)
              ..._particles.map((p) {
                final progress = _burstController.value;
                final dx = cos(p.angle) * p.speed * progress;
                final dy = sin(p.angle) * p.speed * progress;
                final opacity = (1.0 - progress).clamp(0.0, 1.0);
                final scale = 1.0 - (progress * 0.5);
                return Positioned(
                  left: 20 + dx - p.size / 2,
                  top: 20 + dy - p.size / 2,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: p.size,
                        height: p.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.color,
                          boxShadow: [
                            BoxShadow(
                              color: p.color.withValues(alpha: 0.4),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            // Ring burst
            if (_burstController.isAnimating)
              Positioned.fill(
                child: Transform.scale(
                  scale: 1.0 + _burstController.value * 0.8,
                  child: Opacity(
                    opacity: (1.0 - _burstController.value).clamp(0.0, 0.6),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.burstColor.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            // Heart icon with scale bounce
            ScaleTransition(
              scale: _scaleAnim,
              child: widget.child,
            ),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double speed;
  final double size;
  final Color color;

  _Particle({
    required this.angle,
    required this.speed,
    required this.size,
    required this.color,
  });
}
