import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'config/theme.dart';
import 'config/router.dart';
import 'screens/splash_screen.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Request notification permission (iOS)
  final messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(alert: true, badge: true, sound: true);

  // iOS status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: AnNhiTraApp()));
}

class AnNhiTraApp extends ConsumerStatefulWidget {
  const AnNhiTraApp({super.key});

  @override
  ConsumerState<AnNhiTraApp> createState() => _AnNhiTraAppState();
}

class _AnNhiTraAppState extends ConsumerState<AnNhiTraApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    // Phase 1: Splash screen
    if (_showSplash) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkMaterialTheme,
        home: SplashScreen(
          onComplete: () => setState(() => _showSplash = false),
        ),
      );
    }

    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'An Nhi Trà',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkMaterialTheme,
      darkTheme: AppTheme.darkMaterialTheme,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: const [Locale('vi'), Locale('en')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
      builder: (context, child) {
        return CupertinoTheme(
          data: AppTheme.darkCupertinoTheme,
          child: ColoredBox(
            color: AppTheme.darkGroupedBg,
            child: DefaultTextStyle(
              style: const TextStyle(
                fontFamily: 'UTMKhuccamta',
                color: AppTheme.darkTextPrimary,
                decoration: TextDecoration.none,
              ),
              child: child!,
            ),
          ),
        );
      },
    );
  }
}
