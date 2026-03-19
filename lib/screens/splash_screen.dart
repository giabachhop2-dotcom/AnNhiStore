import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SPLASH SCREEN — Premium Brand Introduction
/// Logo spring-scale + tagline fade + auto-transition
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _darkGreen = Color(0xFF114402);
  static const _gold = Color(0xFFC8A96E);

  late AnimationController _logoController;
  late AnimationController _taglineController;
  late AnimationController _fadeOutController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _glowOpacity;
  late Animation<double> _taglineOpacity;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    // Logo: spring scale + fade-in (0→800ms)
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _glowOpacity = Tween<double>(begin: 0.0, end: 0.35).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // Tagline: fade-in + slide-up (400→1000ms)
    _taglineController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _taglineController,
            curve: Curves.easeOutCubic,
          ),
        );

    // Fade-out to transition
    _fadeOutController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeOut = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeOutController, curve: Curves.easeIn),
    );

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Step 1: Logo spring in
    await Future.delayed(const Duration(milliseconds: 200));
    _logoController.forward();

    // Step 2: Tagline slides in after logo
    await Future.delayed(const Duration(milliseconds: 600));
    _taglineController.forward();

    // Step 3: Hold, then fade out
    await Future.delayed(const Duration(milliseconds: 1200));
    await _fadeOutController.forward();

    // Step 4: Transition
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _taglineController.dispose();
    _fadeOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _logoController,
        _taglineController,
        _fadeOutController,
      ]),
      builder: (context, _) {
        return FadeTransition(
          opacity: _fadeOut,
          child: Container(
            color: _darkGreen,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo with glow ──
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Soft glow behind logo
                      Container(
                        width: 180,
                        height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withValues(
                                alpha: _glowOpacity.value,
                              ),
                              blurRadius: 60,
                              spreadRadius: 20,
                            ),
                          ],
                        ),
                      ),
                      // Logo
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _gold.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

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
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFFF5F0E8),
                              letterSpacing: 4,
                              fontFamily: 'UTMKhuccamta',
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Ornamental divider
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 1,
                                color: _gold.withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                CupertinoIcons.leaf_arrow_circlepath,
                                size: 12,
                                color: _gold.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 20,
                                height: 1,
                                color: _gold.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Trà Shan Tuyết · Ấm Tử Sa · Yến Sào',
                            style: TextStyle(
                              fontSize: 12,
                              color: const Color(
                                0xFFF5F0E8,
                              ).withValues(alpha: 0.7),
                              letterSpacing: 1,
                              fontFamily: 'UTMKhuccamta',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
