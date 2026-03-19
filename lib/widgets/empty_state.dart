import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Beautiful animated empty/error state widget with fade-in + slide-up animation
class EmptyState extends StatefulWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  /// Cart empty state
  factory EmptyState.emptyCart({VoidCallback? onBrowse}) {
    return EmptyState(
      icon: CupertinoIcons.cart,
      title: 'Giỏ hàng trống',
      description: 'Hãy khám phá bộ sưu tập trà và ấm tử sa của chúng tôi',
      actionLabel: 'Xem sản phẩm',
      onAction: onBrowse,
      iconColor: AppTheme.accentGold,
    );
  }

  /// No search results
  factory EmptyState.noResults() {
    return const EmptyState(
      icon: CupertinoIcons.search,
      title: 'Không tìm thấy kết quả',
      description: 'Thử tìm kiếm với từ khóa khác',
      iconColor: AppTheme.textMuted,
    );
  }

  /// Network error with retry
  factory EmptyState.networkError({VoidCallback? onRetry}) {
    return EmptyState(
      icon: CupertinoIcons.wifi_slash,
      title: 'Không có kết nối mạng',
      description: 'Vui lòng kiểm tra kết nối và thử lại',
      actionLabel: 'Thử lại',
      onAction: onRetry,
      iconColor: AppTheme.priceRed,
    );
  }

  /// Generic error with retry
  factory EmptyState.error({String? message, VoidCallback? onRetry}) {
    return EmptyState(
      icon: CupertinoIcons.exclamationmark_triangle,
      title: 'Đã có lỗi xảy ra',
      description: message ?? 'Vui lòng thử lại sau',
      actionLabel: 'Thử lại',
      onAction: onRetry,
      iconColor: AppTheme.priceRed,
    );
  }

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _iconScale;

  // Breathing pulse
  late AnimationController _breathController;
  late Animation<double> _breathScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.1, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _iconScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
      ),
    );

    _controller.forward();

    // Gentle breathing pulse loop
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _breathScale = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    _breathController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated icon with background circle
                ScaleTransition(
                  scale: _iconScale,
                  child: ScaleTransition(
                    scale: _breathScale,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (widget.iconColor ?? AppTheme.textMuted).withValues(
                              alpha: 0.12,
                            ),
                            (widget.iconColor ?? AppTheme.textMuted).withValues(
                              alpha: 0.05,
                            ),
                          ],
                        ),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 44,
                        color: widget.iconColor ?? AppTheme.textMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Description
                if (widget.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    widget.description!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textMuted,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],

                // Action button
                if (widget.actionLabel != null && widget.onAction != null) ...[
                  const SizedBox(height: 24),
                  CupertinoButton(
                    onPressed: widget.onAction,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 12,
                    ),
                    color: AppTheme.primaryDark,
                    borderRadius: BorderRadius.circular(12),
                    child: Text(
                      widget.actionLabel!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
