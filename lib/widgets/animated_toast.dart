import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Premium slide-in toast that doesn't block interaction
class AnimatedToast {
  static OverlayEntry? _currentEntry;

  /// Show a non-blocking toast that slides in from top
  static void show(
    BuildContext context, {
    required String message,
    IconData icon = CupertinoIcons.check_mark_circled,
    Duration duration = const Duration(milliseconds: 2000),
    Color? backgroundColor,
    Color? iconColor,
  }) {
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        icon: icon,
        duration: duration,
        backgroundColor: backgroundColor,
        iconColor: iconColor,
        onDismiss: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Convenience: show "added to cart" toast
  static void showCartAdded(BuildContext context) {
    show(
      context,
      message: 'Đã thêm vào giỏ hàng',
      icon: CupertinoIcons.cart_badge_plus,
      iconColor: AppTheme.accentGold,
    );
  }

  /// Convenience: show error toast
  static void showError(BuildContext context, {String? message}) {
    show(
      context,
      message: message ?? 'Đã có lỗi xảy ra',
      icon: CupertinoIcons.exclamationmark_triangle,
      backgroundColor: AppTheme.priceRed.withValues(alpha: 0.9),
      iconColor: Colors.white,
    );
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final IconData icon;
  final Duration duration;
  final Color? backgroundColor;
  final Color? iconColor;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.icon,
    required this.duration,
    required this.onDismiss,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeIn,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _controller.forward();

    // Auto-dismiss
    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          if (mounted) widget.onDismiss();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 8,
      left: 16,
      right: 16,
      child: IgnorePointer(
        ignoring: false,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: GestureDetector(
                onVerticalDragEnd: (details) {
                  if (details.primaryVelocity != null &&
                      details.primaryVelocity! < -100) {
                    _controller.reverse().then((_) {
                      if (mounted) widget.onDismiss();
                    });
                  }
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: widget.backgroundColor ??
                            AppTheme.primaryDark.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            widget.icon,
                            color: widget.iconColor ?? CupertinoColors.white,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              widget.message,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                          // Swipe up hint
                          Icon(
                            CupertinoIcons.chevron_up,
                            color: CupertinoColors.white.withValues(alpha: 0.4),
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
