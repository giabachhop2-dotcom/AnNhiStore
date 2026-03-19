import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../widgets/animated_nav_bar.dart';
import 'home_screen.dart';
import 'product_list_screen.dart';
import 'news_list_screen.dart';
import 'cart_screen.dart';
import 'more_screen.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// MAIN SHELL — Swipeable Tabs + Animated Bottom Nav
/// PageView keeps all 5 tabs alive for smooth UX
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MainShell extends ConsumerStatefulWidget {
  final Widget child; // kept for GoRouter compatibility
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late PageController _pageController;
  int _currentIndex = 0;

  // All main tab screens — kept alive
  final _screens = const [
    HomeScreen(),
    ProductListScreen(),
    NewsListScreen(),
    CartScreen(),
    MoreScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Sync PageView with GoRouter location
    final location = GoRouterState.of(context).uri.path;
    final newIndex = _indexFromLocation(location);
    if (newIndex != _currentIndex) {
      _currentIndex = newIndex;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(newIndex);
      }
    }
  }

  int _indexFromLocation(String location) {
    final tabs = AnimatedNavBar.tabs;
    for (int i = tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(tabs[i].$1)) return i;
    }
    return 0;
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
    // Sync GoRouter
    context.go(AnimatedNavBar.tabs[index].$1);
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
    HapticFeedback.selectionClick();
    context.go(AnimatedNavBar.tabs[index].$1);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartCount = ref
        .watch(cartProvider)
        .fold(0, (sum, e) => sum + e.quantity);

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        physics: const BouncingScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: _currentIndex,
        cartBadgeCount: cartCount,
        onTap: _onNavTap,
      ),
    );
  }
}
