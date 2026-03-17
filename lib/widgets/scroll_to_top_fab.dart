import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Animated Scroll-to-Top floating button.
class ScrollToTopFab extends StatelessWidget {
  final ScrollController scrollController;
  final double showAfterOffset;

  const ScrollToTopFab({
    super.key,
    required this.scrollController,
    this.showAfterOffset = 400,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scrollController,
      builder: (context, _) {
        final show = scrollController.hasClients &&
            scrollController.offset > showAfterOffset;

        return AnimatedPositioned(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          right: 16,
          bottom: show
              ? MediaQuery.of(context).padding.bottom + 80
              : -60,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: show ? 1.0 : 0.0,
            child: GestureDetector(
              onTap: () {
                scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOutCubic,
                );
              },
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.primaryDark,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryDark.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  CupertinoIcons.arrow_up,
                  color: Color(0xFFF5F0E8),
                  size: 20,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
