import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

/// Premium onboarding — Trà Đạo classical style
/// 3 slides for 3 brands with deep green gradients and warm parchment feel.
class OnboardingScreen extends StatefulWidget {
  final VoidCallback onComplete;
  const OnboardingScreen({super.key, required this.onComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingPage(
      logo: 'assets/images/annshan.png',
      title: 'ANNSHAN',
      subtitle: 'Trà Shan Tuyết Cổ Thụ\nCác dòng trà cao cấp chính gốc\nHương vị tinh tuý từ núi rừng Việt Nam',
      gradient: [Color(0xFF142E1F), Color(0xFF1A3C28)],
    ),
    _OnboardingPage(
      logo: 'assets/images/annhi.png',
      title: 'AN NHI',
      subtitle: 'Ấm Tử Sa & Gốm nghệ thuật\nNghệ nhân hàng đầu Nghi Hưng\nTrà cụ · Bàn trà · Phụ kiện cao cấp',
      gradient: [Color(0xFF2C1810), Color(0xFF4A2C1A)],
    ),
    _OnboardingPage(
      logo: 'assets/images/antinhyen.png',
      title: 'AN TINH YẾN',
      subtitle: 'Yến sào thiên nhiên cao cấp\nTổ yến nguyên chất · Nước yến\nSản phẩm sức khoẻ & làm đẹp',
      gradient: [Color(0xFF3A1428), Color(0xFF5C1E3E)],
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
    return CupertinoPageScaffold(
      child: Stack(
        children: [
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
                  return _buildPage(page, offset);
                },
              );
            },
          ),

          // Skip
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: CupertinoButton(
                child: Text('Bỏ qua',
                    style: TextStyle(
                      color: AppTheme.accentGold.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontFamily: 'UTMKhuccamta',
                    )),
                onPressed: _complete,
              ),
            ),

          // Bottom controls
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 32,
            child: Column(
              children: [
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
                            ? AppTheme.accentGold
                            : const Color(0xFFF5F0E8).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // CTA
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: AppTheme.accentGold,
                      borderRadius: BorderRadius.circular(14),
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Bắt đầu mua sắm' : 'Tiếp tục',
                        style: const TextStyle(
                          color: Color(0xFFF5F0E8),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          fontFamily: 'UTMKhuccamta',
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingPage page, double offset) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo in parchment circle
              Transform.translate(
                offset: Offset(offset * -60, 0),
                child: Container(
                  width: 180,
                  height: 160,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F0E8),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        blurRadius: 30,
                        spreadRadius: 2,
                        offset: const Offset(0, 8),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(22),
                  child: Image.asset(page.logo, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 44),
              // Brand name
              Transform.translate(
                offset: Offset(offset * -30, 0),
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'UTMKhuccamta',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF5F0E8),
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 6),
              // Ornamental divider
              Transform.translate(
                offset: Offset(offset * -20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(width: 30, height: 1, color: AppTheme.accentGold.withValues(alpha: 0.5)),
                    const SizedBox(width: 8),
                    Icon(CupertinoIcons.leaf_arrow_circlepath,
                        size: 14, color: AppTheme.accentGold.withValues(alpha: 0.6)),
                    const SizedBox(width: 8),
                    Container(width: 30, height: 1, color: AppTheme.accentGold.withValues(alpha: 0.5)),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              // Description
              Transform.translate(
                offset: Offset(offset * -15, 0),
                child: Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'UTMKhuccamta',
                    fontSize: 15,
                    color: const Color(0xFFF5F0E8).withValues(alpha: 0.85),
                    height: 1.7,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPage {
  final String logo;
  final String title;
  final String subtitle;
  final List<Color> gradient;

  const _OnboardingPage({
    required this.logo,
    required this.title,
    required this.subtitle,
    required this.gradient,
  });
}
