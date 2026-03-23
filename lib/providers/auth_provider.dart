import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Auth state — holds login status, role, user info
class AuthState {
  final bool isLoggedIn;
  final String? userRole; // null | 'sale' | 'admin'
  final String? userName;
  final String? token;
  final int? userId;

  const AuthState({
    this.isLoggedIn = false,
    this.userRole,
    this.userName,
    this.token,
    this.userId,
  });

  bool get isSales => userRole == 'sale';
  bool get isAdmin => userRole == 'admin';
  bool get isStaff => isSales || isAdmin;

  AuthState copyWith({
    bool? isLoggedIn,
    String? userRole,
    String? userName,
    String? token,
    int? userId,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userRole: userRole ?? this.userRole,
      userName: userName ?? this.userName,
      token: token ?? this.token,
      userId: userId ?? this.userId,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState()) {
    _loadFromStorage();
  }

  /// Called after successful login — saves to SharedPreferences
  Future<void> login({
    required String token,
    required Map<String, dynamic> user,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setString('auth_user', jsonEncode(user));
    await prefs.setBool('is_logged_in', true);

    state = AuthState(
      isLoggedIn: true,
      token: token,
      userId: user['id'] as int?,
      userName: (user['fullname'] as String?) ?? (user['username'] as String?),
      userRole: user['user_role'] as String?,
    );
  }

  /// Logout — clear everything
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_user');
    await prefs.setBool('is_logged_in', false);
    state = const AuthState();
  }

  /// Load auth state from SharedPreferences on app start
  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return;

    final token = prefs.getString('auth_token');
    final userJson = prefs.getString('auth_user');

    if (token != null && userJson != null) {
      try {
        final user = jsonDecode(userJson) as Map<String, dynamic>;
        state = AuthState(
          isLoggedIn: true,
          token: token,
          userId: user['id'] as int?,
          userName:
              (user['fullname'] as String?) ?? (user['username'] as String?),
          userRole: user['user_role'] as String?,
        );
      } catch (_) {
        // Corrupted data — reset
        await logout();
      }
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
