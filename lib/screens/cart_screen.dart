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

                    // iOS swipe-to-delete with undo
                    return Dismissible(
                      key: Key('cart-${item.product.id}'),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (_) async {
                        HapticFeedback.mediumImpact();
                        // Remove immediately for visual feedback
                        cartNotifier.removeItem(item.product.id);
                        // Show undo snackbar
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child: CachedNetworkImage(
                                      imageUrl: imageUrl,
                                      width: 32,
                                      height: 32,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, e, s) =>
                                          const SizedBox(width: 32, height: 32),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Đã xóa "${item.product.namevi ?? ""}"',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: AppTheme.primaryDark.withValues(alpha: 0.95),
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.fromLTRB(
                                16, 0, 16,
                                MediaQuery.of(context).padding.bottom + 100,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'Hoàn tác',
                                textColor: AppTheme.accentGold,
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  cartNotifier.addItem(
                                    item.product,
                                    quantity: item.quantity,
                                  );
                                },
                              ),
                            ),
                          );
                        }
                        return false; // we already removed it manually
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
                                  item.product.displayPrice > 0
                                      ? Text(
                                          formatter.format(item.product.displayPrice),
                                          style: const TextStyle(
                                            color: AppTheme.priceRed,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        )
                                      : const Text('Liên hệ',
                                          style: TextStyle(
                                            color: AppTheme.accentGold,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            fontStyle: FontStyle.italic,
                                          )),
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
                                      item.lineTotal > 0
                                          ? Text(
                                              formatter.format(item.lineTotal),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: AppTheme.textPrimary,
                                              ),
                                            )
                                          : const Text('Liên hệ',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                                color: AppTheme.accentGold,
                                                fontStyle: FontStyle.italic,
                                              )),
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
                              Builder(builder: (_) {
                                final total = cart.fold(0.0, (sum, item) => sum + item.lineTotal);
                                final hasContactItems = cart.any((item) => item.product.displayPrice <= 0);
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    total > 0
                                        ? Text(formatter.format(total),
                                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.priceRed))
                                        : const Text('Liên hệ',
                                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.accentGold, fontStyle: FontStyle.italic)),
                                    if (hasContactItems && total > 0)
                                      const Text('+ SP liên hệ giá',
                                          style: TextStyle(fontSize: 11, color: AppTheme.accentGold)),
                                  ],
                                );
                              }),
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
            minimumSize: Size.zero,
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
            minimumSize: Size.zero,
            onPressed: () => onChanged(quantity + 1),
            child: const Icon(CupertinoIcons.plus, size: 14),
          ),
        ],
      ),
    );
  }
}
