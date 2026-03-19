import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SPLASH SCREEN — Premium Brand Introduction
/// Floating particles + pulsing glow + logo reveal
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _darkGreen = Color(0xFF0A2E14);
  static const _gold = Color(0xFFC8A96E);

  late AnimationController _particleController;
  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _pulseController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotate;
  late Animation<double> _glowOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _fadeOut;
  late Animation<double> _pulseAnim;

  final _particles = <_Particle>[];
  final _random = Random();

  @override
  void initState() {
    super.initState();

    // Generate floating particles
    for (int i = 0; i < 20; i++) {
      _particles.add(
        _Particle(
          x: _random.nextDouble(),
          y: _random.nextDouble(),
          size: _random.nextDouble() * 3 + 1,
          speed: _random.nextDouble() * 0.3 + 0.1,
          opacity: _random.nextDouble() * 0.4 + 0.1,
          phase: _random.nextDouble() * pi * 2,
        ),
      );
    }

    // Particle loop (continuous)
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    // Pulse glow (continuous breathing)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.15, end: 0.45).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Logo: spring scale + fade-in + subtle rotation (0→1000ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    _logoRotate = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutBack),
      ),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.5).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    // Tagline: fade-in + slide-up (500→1100ms)
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Fade-out to transition
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Step 1: Particles start immediately, logo springs in after 300ms
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    // Step 2: Tagline slides in
    await Future.delayed(const Duration(milliseconds: 700));
    _taglineController.forward();

    // Step 3: Hold for viewer to absorb, then fade out
    await Future.delayed(const Duration(milliseconds: 1500));
    await _fadeOutController.forward();

    // Step 4: Transition
    widget.onComplete();
  }

  @override
  void dispose() {
    _particleController.dispose();
    _logoController.dispose();
    _taglineController.dispose();
    _pulseController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _particleController,
        _logoController,
        _taglineController,
        _pulseController,
        _fadeOutController,
      ]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeOut,
          child: Container(
            color: _darkGreen,
            child: Stack(
              children: [
                // ── Floating particles ──
                CustomPaint(
                  size: Size.infinite,
                  painter: _ParticlePainter(
                    particles: _particles,
                    progress: _particleController.value,
                    goldColor: _gold,
                  ),
                ),

                // ── Radial gradient overlay ──
                Center(
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _gold.withValues(alpha: _pulseAnim.value * 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                // ── Main content ──
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // ── Logo with animated glow ──
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Pulsing glow ring
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: _gold.withValues(
                                    alpha:
                                        _glowOpacity.value * _pulseAnim.value,
                                  ),
                                  blurRadius: 80,
                                  spreadRadius: 30,
                                ),
                              ],
                            ),
                          ),
                          // Logo with scale + rotation
                          Opacity(
                            opacity: _logoOpacity.value,
                            child: Transform.scale(
                              scale: _logoScale.value,
                              child: Transform.rotate(
                                angle: _logoRotate.value,
                                child: Container(
                                  width: 140,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _gold.withValues(alpha: 0.5),
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _gold.withValues(alpha: 0.2),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  padding: const EdgeInsets.all(20),
                                  child: Image.asset(
                                    'assets/images/app_icon.png',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),

                      // ── Tagline ──
                      SlideTransition(
                        position: _taglineSlide,
                        child: FadeTransition(
                          opacity: _taglineOpacity,
                          child: Column(
                            children: [
                              Text(
                                'AN NHI TRÀ',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF5F0E8),
                                  letterSpacing: 6,
                                  fontFamily: 'UTMKhuccamta',
                                  decoration: TextDecoration.none,
                                  shadows: [
                                    Shadow(
                                      color: _gold.withValues(alpha: 0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              // Ornamental divider with animation
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _AnimatedDivider(
                                    width: 30,
                                    color: _gold.withValues(alpha: 0.5),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    CupertinoIcons.leaf_arrow_circlepath,
                                    size: 14,
                                    color: _gold.withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  _AnimatedDivider(
                                    width: 30,
                                    color: _gold.withValues(alpha: 0.5),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tinh hoa trà · Hồn gốm Việt · Vị yến quý',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(
                                    0xFFF5F0E8,
                                  ).withValues(alpha: 0.7),
                                  letterSpacing: 1.2,
                                  fontFamily: 'UTMKhuccamta',
                                  decoration: TextDecoration.none,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Bottom loading indicator ──
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: Opacity(
                    opacity: _taglineOpacity.value * 0.7,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation(
                              _gold.withValues(alpha: 0.5),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đang tải...',
                          style: TextStyle(
                            fontSize: 11,
                            color: const Color(
                              0xFFF5F0E8,
                            ).withValues(alpha: 0.4),
                            fontFamily: 'UTMKhuccamta',
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ── Floating particle data ──
class _Particle {
  double x, y, size, speed, opacity, phase;
  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.phase,
  });
}

/// ── Particle painter — floating gold dust ──
class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final Color goldColor;

  _ParticlePainter({
    required this.particles,
    required this.progress,
    required this.goldColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final t = (progress + p.phase / (pi * 2)) % 1.0;

      // Floating upward with horizontal sway
      final x = p.x * size.width + sin(t * pi * 2 + p.phase) * 20;
      final y = (p.y - t * p.speed) % 1.0 * size.height;

      final paint = Paint()
        ..color = goldColor.withValues(
          alpha: p.opacity * (0.5 + sin(t * pi) * 0.5),
        )
        ..style = PaintingStyle.fill
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, p.size * 0.5);

      canvas.drawCircle(Offset(x, y), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => true;
}

/// ── Animated divider line ──
class _AnimatedDivider extends StatelessWidget {
  final double width;
  final Color color;
  const _AnimatedDivider({required this.width, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0),
            color,
            color.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
