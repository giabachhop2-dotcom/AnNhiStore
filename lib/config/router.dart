import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'page_transitions.dart';
import '../screens/main_shell.dart';
import '../screens/home_screen.dart';
import '../screens/product_list_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/news_list_screen.dart';
import '../screens/news_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/more_screen.dart';
import '../screens/about_screen.dart';
import '../screens/contact_screen.dart';
import '../screens/checkout_screen.dart';
import '../screens/search_screen.dart';
import '../screens/favorites_screen.dart';
import '../screens/order_history_screen.dart';
import '../screens/tea_brewing_timer.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // ── Shell route with custom animated bottom nav ──
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const HomeScreen()),
        ),
        GoRoute(
          path: '/products',
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const ProductListScreen()),
        ),
        GoRoute(
          path: '/news',
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const NewsListScreen()),
        ),
        GoRoute(
          path: '/cart',
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const CartScreen()),
        ),
        GoRoute(
          path: '/more',
          pageBuilder: (context, state) =>
              FadeTransitionPage(child: const MoreScreen()),
        ),
      ],
    ),

    // ── Detail routes (full-screen, slide-up transition) ──
    GoRoute(
      path: '/product/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return SlideUpTransitionPage(
          child: ProductDetailScreen(productId: id),
        );
      },
    ),
    GoRoute(
      path: '/news/:id',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        return SlideUpTransitionPage(
          child: NewsDetailScreen(newsId: id),
        );
      },
    ),
    GoRoute(
      path: '/about',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const AboutScreen()),
    ),
    GoRoute(
      path: '/contact',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const ContactScreen()),
    ),
    GoRoute(
      path: '/checkout',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const CheckoutScreen()),
    ),
    GoRoute(
      path: '/search',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const SearchScreen()),
    ),
    GoRoute(
      path: '/favorites',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const FavoritesScreen()),
    ),
    GoRoute(
      path: '/orders',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const OrderHistoryScreen()),
    ),
    GoRoute(
      path: '/tea-timer',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) =>
          SlideUpTransitionPage(child: const TeaBrewingTimerScreen()),
    ),
  ],
);
