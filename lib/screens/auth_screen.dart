import 'dart:convert';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/api_config.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// AUTH SCREEN — Premium Login / Register
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with TickerProviderStateMixin {
  bool _isLogin = true; // toggle between login / register
  bool _isLoading = false;
  bool _obscurePassword = true;

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  late AnimationController _fadeController;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _fade = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() => _isLogin = !_isLogin);
    _fadeController.reset();
    _fadeController.forward();
    HapticFeedback.selectionClick();
  }

  Future<void> _submit() async {
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showError('Vui lòng điền đầy đủ thông tin');
      return;
    }

    if (!_isLogin) {
      final name = _nameController.text.trim();
      final confirmPw = _confirmPasswordController.text.trim();
      if (name.isEmpty) {
        _showError('Vui lòng nhập họ tên');
        return;
      }
      if (password != confirmPw) {
        _showError('Mật khẩu xác nhận không khớp');
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      final url = _isLogin ? ApiConfig.login : ApiConfig.register;
      final body = _isLogin
          ? {'username': phone, 'password': password}
          : {
              'fullname': _nameController.text.trim(),
              'phone': phone,
              'password': password,
            };

      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final resBody = jsonDecode(response.body);
      if (response.statusCode == 200 && resBody['success'] == true) {
        // Backend wraps in { success, data: { token, user }, message }
        final payload = resBody['data'] ?? {};
        final token = payload['token'] as String?;
        final user = payload['user'] as Map<String, dynamic>? ?? {};

        // Use AuthNotifier to persist state
        if (token != null) {
          await ref.read(authProvider.notifier).login(token: token, user: user);
        }

        if (mounted) {
          _showSuccess(
            _isLogin ? 'Đăng nhập thành công!' : 'Đăng ký thành công!',
          );
          await Future.delayed(const Duration(milliseconds: 800));
          if (mounted) {
            // Role-based redirect
            final role = user['user_role'] as String?;
            if (role == 'sale' || role == 'admin') {
              context.go('/sales-dashboard');
            } else {
              context.pop();
            }
          }
        }
      } else {
        _showError(resBody['message'] ?? 'Có lỗi xảy ra, vui lòng thử lại');
      }
    } catch (e) {
      _showError('Không thể kết nối máy chủ');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Thông báo'),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String msg) {
    if (!mounted) return;
    showCupertinoDialog(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: AppTheme.accentGold,
              size: 20,
            ),
            SizedBox(width: 8),
            Text('Thành công'),
          ],
        ),
        content: Text(msg),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Stack(
        children: [
          // ── Dark green gradient background ──
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF061E0D),
                  Color(0xFF0A2E14),
                  Color(0xFF114402),
                  Color(0xFF061E0D),
                ],
              ),
            ),
          ),

          // ── Decorative leaf patterns ──
          Positioned(
            right: -40,
            top: 60,
            child: Icon(
              CupertinoIcons.leaf_arrow_circlepath,
              size: 180,
              color: Colors.white.withValues(alpha: 0.03),
            ),
          ),
          Positioned(
            left: -20,
            bottom: 100,
            child: Icon(
              CupertinoIcons.leaf_arrow_circlepath,
              size: 120,
              color: Colors.white.withValues(alpha: 0.02),
            ),
          ),

          // ── Scrollable content ──
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fade,
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // ── Back button ──
                    Align(
                      alignment: Alignment.centerLeft,
                      child: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              CupertinoIcons.back,
                              color: Colors.white.withValues(alpha: 0.7),
                              size: 20,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Quay lại',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Logo ──
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: AppTheme.accentGold.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Image.asset(
                          'assets/images/app_icon.png',
                          height: 72,
                          width: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Title ──
                    Text(
                      _isLogin ? 'Chào mừng trở lại' : 'Tạo tài khoản',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin
                          ? 'Đăng nhập để trải nghiệm đầy đủ'
                          : 'Đăng ký thành viên An Nhi Trà',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Glass form card ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12),
                              width: 0.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              // Name field (register only)
                              if (!_isLogin) ...[
                                _GlassTextField(
                                  controller: _nameController,
                                  placeholder: 'Họ và tên',
                                  icon: CupertinoIcons.person,
                                  keyboardType: TextInputType.name,
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Phone field
                              _GlassTextField(
                                controller: _phoneController,
                                placeholder: 'Số điện thoại',
                                icon: CupertinoIcons.phone,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 16),

                              // Password field
                              _GlassTextField(
                                controller: _passwordController,
                                placeholder: 'Mật khẩu',
                                icon: CupertinoIcons.lock,
                                obscureText: _obscurePassword,
                                suffix: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  minSize: 0,
                                  child: Icon(
                                    _obscurePassword
                                        ? CupertinoIcons.eye_slash
                                        : CupertinoIcons.eye,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword,
                                  ),
                                ),
                              ),

                              // Confirm password (register only)
                              if (!_isLogin) ...[
                                const SizedBox(height: 16),
                                _GlassTextField(
                                  controller: _confirmPasswordController,
                                  placeholder: 'Xác nhận mật khẩu',
                                  icon: CupertinoIcons.lock_shield,
                                  obscureText: true,
                                ),
                              ],

                              const SizedBox(height: 24),

                              // ── Submit button ──
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: CupertinoButton(
                                  padding: EdgeInsets.zero,
                                  borderRadius: BorderRadius.circular(14),
                                  color: AppTheme.accentGold,
                                  onPressed: _isLoading ? null : _submit,
                                  child: _isLoading
                                      ? const CupertinoActivityIndicator(
                                          color: Colors.white,
                                        )
                                      : Text(
                                          _isLogin ? 'Đăng nhập' : 'Đăng ký',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Toggle login/register ──
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 14,
                          ),
                          children: [
                            TextSpan(
                              text: _isLogin
                                  ? 'Chưa có tài khoản? '
                                  : 'Đã có tài khoản? ',
                            ),
                            TextSpan(
                              text: _isLogin ? 'Đăng ký ngay' : 'Đăng nhập',
                              style: const TextStyle(
                                color: AppTheme.accentGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      onPressed: _toggleMode,
                    ),
                    const SizedBox(height: 32),

                    // ── Divider ──
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 0.5,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'hoặc tiếp tục với',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            height: 0.5,
                            color: Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── Social login buttons ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialButton(
                          icon: CupertinoIcons.phone_fill,
                          label: 'Zalo',
                          color: const Color(0xFF0068FF),
                        ),
                        const SizedBox(width: 16),
                        _SocialButton(
                          icon: CupertinoIcons.person_2_fill,
                          label: 'Facebook',
                          color: const Color(0xFF1877F2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ── Glass-style text field ──
class _GlassTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;

  const _GlassTextField({
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 0.5,
        ),
      ),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        keyboardType: keyboardType,
        obscureText: obscureText,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        style: const TextStyle(color: Colors.white, fontSize: 15),
        placeholderStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.35),
          fontSize: 15,
        ),
        decoration:
            const BoxDecoration(), // transparent — outer container handles it
        prefix: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Icon(
            icon,
            size: 18,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        suffix: suffix != null
            ? Padding(padding: const EdgeInsets.only(right: 10), child: suffix)
            : null,
      ),
    );
  }
}

/// ── Social login button ──
class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        // Placeholder for social auth
        showCupertinoDialog(
          context: context,
          builder: (_) => CupertinoAlertDialog(
            title: const Text('Sắp ra mắt'),
            content: Text('Đăng nhập bằng $label sẽ được hỗ trợ sớm'),
            actions: [
              CupertinoDialogAction(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 130,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: color.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
