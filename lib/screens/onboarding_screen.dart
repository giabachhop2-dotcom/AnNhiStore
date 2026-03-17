import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';

/// Premium onboarding flow shown only on first app launch.
/// 3-slide intro featuring 3 brands: Annshan, An Nhi Trà, An Tinh Yến.
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
      gradient: [Color(0xFF1B5E20), Color(0xFF388E3C)],
    ),
    _OnboardingPage(
      logo: 'assets/images/annhi.png',
      title: 'AN NHI',
      subtitle: 'Ấm Tử Sa & Gốm nghệ thuật\nNghệ nhân hàng đầu Nghi Hưng\nTrà cụ · Bàn trà · Phụ kiện cao cấp',
      gradient: [Color(0xFF3E2723), Color(0xFF6D4C41)],
    ),
    _OnboardingPage(
      logo: 'assets/images/antinhyen.png',
      title: 'AN TINH YẾN',
      subtitle: 'Yến sào thiên nhiên cao cấp\nTổ yến nguyên chất · Nước yến\nSản phẩm sức khoẻ & làm đẹp',
      gradient: [Color(0xFF880E4F), Color(0xFFAD1457)],
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
          // Pages
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

          // Skip button
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 16,
              child: CupertinoButton(
                child: const Text('Bỏ qua',
                    style: TextStyle(color: CupertinoColors.white, fontSize: 15)),
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
                // Page indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == i ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == i
                            ? CupertinoColors.white
                            : CupertinoColors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 32),
                // CTA button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    child: CupertinoButton(
                      color: CupertinoColors.white,
                      borderRadius: BorderRadius.circular(16),
                      onPressed: _next,
                      child: Text(
                        _currentPage == _pages.length - 1 ? 'Bắt đầu mua sắm' : 'Tiếp tục',
                        style: TextStyle(
                          color: _pages[_currentPage].gradient[0],
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: page.gradient,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Brand logo with parallax
              Transform.translate(
                offset: Offset(offset * -60, 0),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: ClipOval(
                    child: Image.asset(
                      page.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // Brand name with parallax
              Transform.translate(
                offset: Offset(offset * -30, 0),
                child: Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Description
              Transform.translate(
                offset: Offset(offset * -15, 0),
                child: Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: CupertinoColors.white.withValues(alpha: 0.9),
                    height: 1.6,
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
