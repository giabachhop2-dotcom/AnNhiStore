import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/router.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // iOS status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: AnNhiTraApp()));
}

class AnNhiTraApp extends StatelessWidget {
  const AnNhiTraApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Use MaterialApp.router but with Cupertino look
    return MaterialApp.router(
      title: 'An Nhi Trà',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.materialTheme,
      routerConfig: router,
      builder: (context, child) {
        // Apply Cupertino theme overlay for iOS-native feel
        return CupertinoTheme(
          data: AppTheme.cupertinoTheme,
          child: child!,
        );
      },
    );
  }
}
