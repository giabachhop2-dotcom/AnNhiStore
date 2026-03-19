import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'screens/onboarding_screen.dart';

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

// ── Theme mode provider ──
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((
  ref,
) {
  return ThemeModeNotifier();
});

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }

  void setMode(ThemeMode mode) {
    state = mode;
    _save();
  }

  void toggle() {
    if (state == ThemeMode.dark) {
      state = ThemeMode.light;
    } else {
      state = ThemeMode.dark;
    }
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', state.index);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('theme_mode');
    if (index != null && index < ThemeMode.values.length) {
      state = ThemeMode.values[index];
    }
  }
}

class AnNhiTraApp extends ConsumerStatefulWidget {
  const AnNhiTraApp({super.key});

  @override
  ConsumerState<AnNhiTraApp> createState() => _AnNhiTraAppState();
}

class _AnNhiTraAppState extends ConsumerState<AnNhiTraApp> {
  bool _showOnboarding = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    final done = prefs.getBool('onboarding_done') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !done;
        _initialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    if (!_initialized) {
      return const MaterialApp(
        home: CupertinoPageScaffold(
          child: Center(child: CupertinoActivityIndicator(radius: 14)),
        ),
      );
    }

    if (_showOnboarding) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.materialTheme,
        darkTheme: AppTheme.darkMaterialTheme,
        themeMode: themeMode,
        builder: (context, child) {
          return DefaultTextStyle(
            style: const TextStyle(
              fontFamily: 'UTMKhuccamta',
              color: Color(0xFFF5F0E8),
              decoration: TextDecoration.none,
            ),
            child: child!,
          );
        },
        home: OnboardingScreen(
          onComplete: () {
            setState(() => _showOnboarding = false);
          },
        ),
      );
    }

    return MaterialApp.router(
      title: 'An Nhi Trà',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.materialTheme,
      darkTheme: AppTheme.darkMaterialTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return CupertinoTheme(
          data: isDark ? AppTheme.darkCupertinoTheme : AppTheme.cupertinoTheme,
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: 'UTMKhuccamta',
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              decoration: TextDecoration.none,
            ),
            child: child!,
          ),
        );
      },
    );
  }
}
