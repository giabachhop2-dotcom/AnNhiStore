import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// ONBOARDING — Tea Bliss UI Kit Style + Parallax
/// Split layout: dark green top + white card bottom
/// Logo has parallax shift + scale on swipe
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _darkGreen = Color(0xFF114402);

  static const _pages = [
    _OnboardingPage(
      logo: 'assets/images/annshan.png',
      title: 'ANNSHAN',
      subtitle:
          'Trà Shan Tuyết Cổ Thụ — Các dòng trà cao cấp chính gốc. '
          'Hương vị tinh tuý từ núi rừng Việt Nam.',
    ),
    _OnboardingPage(
      logo: 'assets/images/annhi.png',
      title: 'AN NHI',
      subtitle:
          'Ấm Tử Sa & Gốm nghệ thuật — Nghệ nhân hàng đầu Nghi Hưng. '
          'Trà cụ · Bàn trà · Phụ kiện cao cấp.',
    ),
    _OnboardingPage(
      logo: 'assets/images/antinhyen.png',
      title: 'AN TINH YẾN',
      subtitle:
          'Yến sào thiên nhiên cao cấp — Tổ yến nguyên chất · Nước yến. '
          'Sản phẩm sức khoẻ & làm đẹp.',
    ),
  ];

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      _complete();
    }
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    widget.onComplete();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // ── Full green background ──
          Container(color: _darkGreen),

          // ── Page view with parallax ──
          PageView.builder(
            controller: _controller,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, index) {
              final page = _pages[index];
              return ListenableBuilder(
                listenable: _controller,
                builder: (context, _) {
                  double offset = 0;
                  if (_controller.position.haveDimensions) {
                    offset = (_controller.page ?? 0) - index;
                  }
                  return _buildPage(page, context, offset);
                },
              );
            },
          ),

          // ── Skip button (top-right) ──
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: safeTop + 8,
              right: 8,
              child: CupertinoButton(
                child: const Text(
                  'Bỏ qua',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                onPressed: _complete,
              ),
            ),

          // ── Back chevron (from slide 2+) ──
          if (_currentPage > 0)
            Positioned(
              top: safeTop + 8,
              left: 4,
              child: CupertinoButton(
                child: const Icon(
                  CupertinoIcons.chevron_left,
                  color: Colors.white70,
                  size: 22,
                ),
                onPressed: () {
                  _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ),

          // ── Bottom white card ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: MediaQuery.of(context).size.height * 0.42,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(30, 36, 30, safeBottom + 20),
                child: Column(
                  children: [
                    // Title with animated switch
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _pages[_currentPage].title,
                        key: ValueKey('title_$_currentPage'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: _darkGreen,
                          letterSpacing: 2,
                          fontFamily: 'UTMKhuccamta',
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _pages[_currentPage].subtitle,
                          key: ValueKey('sub_$_currentPage'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.6,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ),

                    // Dot indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_pages.length, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _currentPage == i ? 28 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == i
                                ? _darkGreen
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(4),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // CTA Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: CupertinoButton(
                        color: _darkGreen,
                        borderRadius: BorderRadius.circular(14),
                        onPressed: _next,
                        child: Text(
                          _currentPage == _pages.length - 1
                              ? 'Bắt đầu mua sắm'
                              : _currentPage == 0
                              ? 'Bắt đầu'
                              : 'Tiếp tục',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            fontFamily: 'UTMKhuccamta',
                            letterSpacing: 0.5,
                          ),
                        ),
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

  Widget _buildPage(_OnboardingPage page, BuildContext context, double offset) {
    final topHeight = MediaQuery.of(context).size.height * 0.58;
    // Parallax: logo shifts horizontally + scales based on page offset
    final scale = (1 - offset.abs() * 0.15).clamp(0.85, 1.0);

    return Column(
      children: [
        SizedBox(
          height: topHeight,
          child: Center(
            child: Transform.translate(
              offset: Offset(offset * -80, 0), // Parallax shift
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.15),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Image.asset(page.logo, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPage {
  final String logo;
  final String title;
  final String subtitle;

  const _OnboardingPage({
    required this.logo,
    required this.title,
    required this.subtitle,
  });
}
