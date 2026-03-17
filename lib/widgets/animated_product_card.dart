import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import '../providers/providers.dart';
import 'animated_toast.dart';

/// Animated product card with:
/// - Press-to-scale (0.95x on press, spring-back on release)
/// - Staggered entry animation (cascade delay)
/// - Hero transition to detail
/// - Context menu with haptic feedback
class AnimatedProductCard extends ConsumerStatefulWidget {
  final Product product;
  final int index;

  const AnimatedProductCard({
    super.key,
    required this.product,
    this.index = 0,
  });

  @override
  ConsumerState<AnimatedProductCard> createState() =>
      _AnimatedProductCardState();
}

class _AnimatedProductCardState extends ConsumerState<AnimatedProductCard>
    with TickerProviderStateMixin {
  // Press-to-scale
  late AnimationController _pressController;
  late Animation<double> _pressScale;

  // Staggered entry
  late AnimationController _entryController;
  late Animation<double> _entryFade;
  late Animation<Offset> _entrySlide;

  // Quick add bounce
  late AnimationController _addBounceController;
  late Animation<double> _addBounce;

  @override
  void initState() {
    super.initState();

    // Press-to-scale animation
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _pressController,
        curve: Curves.easeOut,
        reverseCurve: Curves.elasticOut,
      ),
    );

    // Staggered entry animation
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _entryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOut),
    );
    _entrySlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entryController, curve: Curves.easeOutCubic),
    );

    // Quick add bounce
    _addBounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _addBounce = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.05)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 30,
      ),
    ]).animate(_addBounceController);

    // Staggered entry with delay based on index
    Future.delayed(Duration(milliseconds: 50 * widget.index), () {
      if (mounted) _entryController.forward();
    });
  }

  @override
  void dispose() {
    _pressController.dispose();
    _entryController.dispose();
    _addBounceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    _pressController.forward();
  }

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
  }

  void _onTapCancel() {
    _pressController.reverse();
  }

  void _onTap() {
    HapticFeedback.selectionClick();
    context.push('/product/${widget.product.id}');
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    ref.read(cartProvider.notifier).addItem(widget.product);
    _addBounceController.forward(from: 0);
    AnimatedToast.showCartAdded(context);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = ApiService.getImageUrl(widget.product.photo, 'product');
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final heroTag = 'product-${widget.product.id}';

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: ScaleTransition(
          scale: _pressScale,
          child: CupertinoContextMenu(
            actions: [
              CupertinoContextMenuAction(
                onPressed: () {
                  Navigator.pop(context);
                  HapticFeedback.mediumImpact();
                  _addToCart();
                },
                trailingIcon: CupertinoIcons.cart_badge_plus,
                child: const Text('Thêm vào giỏ'),
              ),
              CupertinoContextMenuAction(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/product/${widget.product.id}');
                },
                trailingIcon: CupertinoIcons.eye,
                child: const Text('Xem chi tiết'),
              ),
            ],
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onTap: _onTap,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      CupertinoColors.systemBackground.resolveFrom(context),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product image
                      Expanded(
                        flex: 3,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Hero(
                              tag: heroTag,
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (_, _a) => _buildShimmer(),
                                errorWidget: (_, _a, _b) => Container(
                                  color: AppTheme.groupedBg,
                                  child: const Center(
                                    child: Icon(CupertinoIcons.photo,
                                        color: AppTheme.textMuted, size: 32),
                                  ),
                                ),
                              ),
                            ),
                            // Discount badge
                            if (widget.product.isOnSale &&
                                widget.product.discount != null &&
                                widget.product.discount! > 0)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFE53935),
                                        Color(0xFFFF5252),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.priceRed
                                            .withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    '-${widget.product.discount!.toInt()}%',
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            // Quick add button with bounce animation
                            Positioned(
                              bottom: 6,
                              right: 6,
                              child: ScaleTransition(
                                scale: _addBounce,
                                child: GestureDetector(
                                  onTap: _addToCart,
                                  child: Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppTheme.primaryDark,
                                          Color(0xFF2D4A3E),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryDark
                                              .withValues(alpha: 0.4),
                                          blurRadius: 8,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      CupertinoIcons.cart_badge_plus,
                                      color: CupertinoColors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Product info
                      Expanded(
                        flex: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.namevi ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: AppTheme.textPrimary,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              const Spacer(),
                              _buildPrice(formatter),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrice(NumberFormat formatter) {
    final p = widget.product;
    if (p.isOnSale) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatter.format(p.salePrice),
            style: const TextStyle(
              color: AppTheme.priceRed,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          Text(
            formatter.format(p.regularPrice),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: AppTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      );
    } else if (p.regularPrice != null && p.regularPrice! > 0) {
      return Text(
        formatter.format(p.regularPrice),
        style: const TextStyle(
          color: AppTheme.priceRed,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      );
    } else {
      return const Text(
        'Liên hệ',
        style: TextStyle(
          color: AppTheme.accentGold,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          fontStyle: FontStyle.italic,
        ),
      );
    }
  }

  Widget _buildShimmer() {
    return Container(
      color: AppTheme.groupedBg,
      child: Center(
        child: Icon(
          CupertinoIcons.photo,
          color: AppTheme.separator.withValues(alpha: 0.3),
          size: 24,
        ),
      ),
    );
  }
}
