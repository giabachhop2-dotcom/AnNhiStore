import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// Premium animated bottom navigation bar with flowing indicator and scale animations
class AnimatedNavBar extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartBadgeCount;

  const AnimatedNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartBadgeCount = 0,
  });

  static const tabs = [
    ('/', CupertinoIcons.house_fill, 'Trang chủ'),
    ('/products', CupertinoIcons.leaf_arrow_circlepath, 'Sản phẩm'),
    ('/news', CupertinoIcons.doc_text, 'Tin tức'),
    ('/cart', CupertinoIcons.cart, 'Giỏ hàng'),
    ('/more', CupertinoIcons.ellipsis_circle, 'Thêm'),
  ];

  @override
  State<AnimatedNavBar> createState() => _AnimatedNavBarState();
}

class _AnimatedNavBarState extends State<AnimatedNavBar>
    with TickerProviderStateMixin {
  late AnimationController _indicatorController;
  late AnimationController _badgeController;
  late Animation<double> _badgeScale;
  int _previousBadgeCount = 0;

  @override
  void initState() {
    super.initState();
    _indicatorController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _badgeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 0.9,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 0.9,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_badgeController);

    _previousBadgeCount = widget.cartBadgeCount;
  }

  @override
  void didUpdateWidget(covariant AnimatedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Bounce badge when count changes
    if (widget.cartBadgeCount != _previousBadgeCount &&
        widget.cartBadgeCount > 0) {
      _badgeController.forward(from: 0);
      _previousBadgeCount = widget.cartBadgeCount;
    }
  }

  @override
  void dispose() {
    _indicatorController.dispose();
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [AppTheme.darkElevated, AppTheme.darkSurface]
              : [AppTheme.surfaceWhite, AppTheme.primaryBg],
        ),
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(bottom: bottomPadding > 0 ? 0 : 4),
          child: SizedBox(
            height: 58,
            child: Stack(
              children: [
                // Glowing gold indicator
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  left: _indicatorLeft(context),
                  child: Container(
                    width: _tabWidth(context),
                    height: 3,
                    decoration: BoxDecoration(
                      color: const Color(0xFF114402),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF114402).withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
                // Tab items
                Row(
                  children: List.generate(AnimatedNavBar.tabs.length, (index) {
                    final tab = AnimatedNavBar.tabs[index];
                    final isActive = index == widget.currentIndex;
                    final isCart = tab.$1 == '/cart';

                    return Expanded(
                      child: _TabItem(
                        icon: tab.$2,
                        label: tab.$3,
                        isActive: isActive,
                        badgeCount: isCart ? widget.cartBadgeCount : 0,
                        badgeScale: isCart ? _badgeScale : null,
                        onTap: () {
                          if (index != widget.currentIndex) {
                            HapticFeedback.selectionClick();
                          }
                          widget.onTap(index);
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double _tabWidth(BuildContext context) {
    return MediaQuery.of(context).size.width / AnimatedNavBar.tabs.length;
  }

  double _indicatorLeft(BuildContext context) {
    return widget.currentIndex * _tabWidth(context);
  }
}

class _TabItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final int badgeCount;
  final Animation<double>? badgeScale;
  final VoidCallback onTap;

  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
    this.badgeScale,
  });

  @override
  State<_TabItem> createState() => _TabItemState();
}

class _TabItemState extends State<_TabItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(covariant _TabItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _scaleController.forward().then((_) => _scaleController.reverse());
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF114402);
    final color = widget.isActive ? activeColor : AppTheme.textMuted;

    Widget iconWidget = ScaleTransition(
      scale: _scale,
      child: Icon(widget.icon, size: 24, color: color),
    );

    // Badge overlay for cart
    if (widget.badgeCount > 0) {
      Widget badge = Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
        decoration: BoxDecoration(
          color: AppTheme.priceRed,
          borderRadius: BorderRadius.circular(8),
        ),
        constraints: const BoxConstraints(minWidth: 16, minHeight: 14),
        child: Text(
          widget.badgeCount > 99 ? '99+' : '${widget.badgeCount}',
          style: const TextStyle(
            fontSize: 10,
            color: CupertinoColors.white,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      );

      if (widget.badgeScale != null) {
        badge = ScaleTransition(scale: widget.badgeScale!, child: badge);
      }

      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(top: -4, right: -10, child: badge),
        ],
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: widget.isActive ? 10.5 : 10,
              fontWeight: widget.isActive ? FontWeight.w600 : FontWeight.w400,
              color: color,
            ),
            child: Text(widget.label),
          ),
        ],
      ),
    );
  }
}
