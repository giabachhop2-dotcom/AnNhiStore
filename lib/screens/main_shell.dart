import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../widgets/animated_nav_bar.dart';

/// Main shell with animated bottom navigation
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  int _currentIndex(String location) {
    final tabs = AnimatedNavBar.tabs;
    for (int i = tabs.length - 1; i >= 0; i--) {
      if (location.startsWith(tabs[i].$1)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.path;
    final currentIdx = _currentIndex(location);
    final cartCount =
        ref.watch(cartProvider).fold(0, (sum, e) => sum + e.quantity);

    return Scaffold(
      body: child,
      bottomNavigationBar: AnimatedNavBar(
        currentIndex: currentIdx,
        cartBadgeCount: cartCount,
        onTap: (index) => context.go(AnimatedNavBar.tabs[index].$1),
      ),
    );
  }
}
