import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import 'package:intl/intl.dart';

/// iOS-native Product Card with Hero animation, context menu, and haptic feedback
class ProductCard extends ConsumerWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = ApiService.getImageUrl(product.photo, 'product');
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final heroTag = 'product-${product.id}';

    return CupertinoContextMenu(
      actions: [
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            HapticFeedback.mediumImpact();
            ref.read(cartProvider.notifier).addItem(product);
            _showAddedToast(context);
          },
          trailingIcon: CupertinoIcons.cart_badge_plus,
          child: const Text('Thêm vào giỏ'),
        ),
        CupertinoContextMenuAction(
          onPressed: () {
            Navigator.pop(context);
            Share.share(
              '${product.namevi ?? ""} - An Nhi Trà\nhttps://annhitra.com/${product.slugvi ?? ""}',
            );
          },
          trailingIcon: CupertinoIcons.share,
          child: const Text('Chia sẻ'),
        ),
      ],
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          context.push('/product/${product.id}');
        },
        child: Container(
          decoration: BoxDecoration(
            color: CupertinoColors.systemBackground.resolveFrom(context),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product image with Hero + discount badge + quick add
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
                          placeholder: (_, _a) => Container(color: AppTheme.groupedBg),
                          errorWidget: (_, _a, _b) => Container(
                            color: AppTheme.groupedBg,
                            child: const Center(
                              child: Icon(CupertinoIcons.photo, color: AppTheme.textMuted, size: 32),
                            ),
                          ),
                        ),
                      ),
                      // Discount badge (top-left)
                      if (product.isOnSale && product.discount != null && product.discount! > 0)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.priceRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '-${product.discount!.toInt()}%',
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      // Quick add-to-cart button (bottom-right)
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            ref.read(cartProvider.notifier).addItem(product);
                            _showAddedToast(context);
                          },
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryDark.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
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
                          product.namevi ?? '',
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
                        // Price display
                        if (product.isOnSale) ...[
                          Text(
                            formatter.format(product.salePrice),
                            style: const TextStyle(
                              color: AppTheme.priceRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            formatter.format(product.regularPrice),
                            style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ] else if (product.regularPrice != null && product.regularPrice! > 0) ...[
                          Text(
                            formatter.format(product.regularPrice),
                            style: const TextStyle(
                              color: AppTheme.priceRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ] else ...[
                          const Text(
                            'Liên hệ',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAddedToast(BuildContext context) {
    showCupertinoDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: AppTheme.primaryDark.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.check_mark_circled, color: CupertinoColors.white, size: 22),
              SizedBox(width: 8),
              Text(
                'Đã thêm vào giỏ',
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.none,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    });
  }
}
