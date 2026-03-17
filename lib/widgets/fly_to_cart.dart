import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Fly-to-Cart animation overlay.
/// Shows a product thumbnail flying from source position to the cart icon position.
class FlyToCartAnimation {
  static OverlayEntry? _currentOverlay;

  /// Trigger the fly animation.
  static void fly({
    required BuildContext context,
    required Widget imageWidget,
    required Offset startGlobalOffset,
    Size startSize = const Size(60, 60),
  }) {
    final overlay = Overlay.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Target: cart tab icon (4th of 5 tabs ≈ 70% from left)
    final endX = screenWidth * 0.7 - 15;
    final endY = screenHeight - bottomPadding - 28;

    _currentOverlay?.remove();

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _FlyWidget(
        imageWidget: imageWidget,
        startOffset: startGlobalOffset,
        endOffset: Offset(endX, endY),
        startSize: startSize,
        onComplete: () {
          entry.remove();
          _currentOverlay = null;
        },
      ),
    );

    _currentOverlay = entry;
    overlay.insert(entry);
  }
}

class _FlyWidget extends StatefulWidget {
  final Widget imageWidget;
  final Offset startOffset;
  final Offset endOffset;
  final Size startSize;
  final VoidCallback onComplete;

  const _FlyWidget({
    required this.imageWidget,
    required this.startOffset,
    required this.endOffset,
    required this.startSize,
    required this.onComplete,
  });

  @override
  State<_FlyWidget> createState() => _FlyWidgetState();
}

class _FlyWidgetState extends State<_FlyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progress;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 650),
      vsync: this,
    );

    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInCubic);
    _scale = Tween<double>(begin: 1.0, end: 0.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
    _opacity = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0, curve: Curves.easeIn)),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final t = _progress.value;
        final sx = widget.startOffset.dx;
        final sy = widget.startOffset.dy;
        final ex = widget.endOffset.dx;
        final ey = widget.endOffset.dy;

        // Quadratic bezier arc (goes up first, then curves down to cart)
        final mx = (sx + ex) / 2;
        final my = sy - 120;
        final x = (1 - t) * (1 - t) * sx + 2 * (1 - t) * t * mx + t * t * ex;
        final y = (1 - t) * (1 - t) * sy + 2 * (1 - t) * t * my + t * t * ey;
        final size = widget.startSize.width * _scale.value;

        return Positioned(
          left: x - size / 2,
          top: y - size / 2,
          child: Opacity(
            opacity: _opacity.value,
            child: Transform.scale(
              scale: _scale.value,
              child: Container(
                width: widget.startSize.width,
                height: widget.startSize.height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.imageWidget,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
