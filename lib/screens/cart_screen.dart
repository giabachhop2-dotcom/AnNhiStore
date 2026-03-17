import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import '../widgets/empty_state.dart';

/// iOS-native Cart with swipe-to-delete, haptic feedback, and premium animations
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Giỏ Hàng (${cartNotifier.totalItems})'),
        trailing: cart.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Xóa tất cả',
                    style: TextStyle(color: AppTheme.priceRed, fontSize: 14)),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Xóa toàn bộ giỏ hàng?'),
                      content: const Text('Thao tác này không thể hoàn tác.'),
                      actions: [
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            cartNotifier.clearCart();
                            Navigator.pop(ctx);
                          },
                          child: const Text('Xóa'),
                        ),
                        CupertinoDialogAction(
                          isDefaultAction: true,
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Hủy'),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
      child: cart.isEmpty
          ? EmptyState.emptyCart(
              onBrowse: () => context.go('/products'),
            )
          : Stack(
              children: [
                // Cart items list
                ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    16, 16, 16,
                    MediaQuery.of(context).padding.bottom + 100,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: cart.length,
                  itemBuilder: (context, index) {
                    final item = cart[index];
                    final imageUrl = ApiService.getImageUrl(item.product.photo, 'product');

                    // iOS swipe-to-delete
                    return Dismissible(
                      key: Key('cart-${item.product.id}'),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) {
                        HapticFeedback.mediumImpact();
                        cartNotifier.removeItem(item.product.id);
                      },
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: CupertinoColors.destructiveRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(CupertinoIcons.trash, color: CupertinoColors.white),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground.resolveFrom(context),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorWidget: (_, _a, _b) =>
                                    Container(width: 80, height: 80, color: AppTheme.groupedBg),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.namevi ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    formatter.format(item.product.displayPrice),
                                    style: const TextStyle(
                                      color: AppTheme.priceRed,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // iOS-style stepper
                                  Row(
                                    children: [
                                      _IosStepper(
                                        quantity: item.quantity,
                                        onChanged: (qty) {
                                          HapticFeedback.selectionClick();
                                          cartNotifier.updateQuantity(item.product.id, qty);
                                        },
                                      ),
                                      const Spacer(),
                                      Text(
                                        formatter.format(item.lineTotal),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                // Bottom checkout bar (frosted glass)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(
                        20, 14, 20,
                        MediaQuery.of(context).padding.bottom + 14,
                      ),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground
                            .resolveFrom(context)
                            .withValues(alpha: 0.95),
                        border: Border(
                          top: BorderSide(
                            color: AppTheme.separator.withValues(alpha: 0.3),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Tổng cộng:',
                                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                              Text(
                                formatter.format(cart.fold(0.0, (sum, item) => sum + item.lineTotal)),
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.priceRed,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: CupertinoButton.filled(
                              onPressed: () {
                                HapticFeedback.mediumImpact();
                                context.push('/checkout');
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: const Text('Đặt hàng',
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                            ),
                          ),
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

class _IosStepper extends StatelessWidget {
  final int quantity;
  final ValueChanged<int> onChanged;

  const _IosStepper({required this.quantity, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.groupedBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(6),
            minSize: 0,
            onPressed: quantity > 1 ? () => onChanged(quantity - 1) : null,
            child: Icon(
              CupertinoIcons.minus,
              size: 14,
              color: quantity > 1 ? AppTheme.textPrimary : AppTheme.textMuted,
            ),
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(6),
            minSize: 0,
            onPressed: () => onChanged(quantity + 1),
            child: const Icon(CupertinoIcons.plus, size: 14),
          ),
        ],
      ),
    );
  }
}
