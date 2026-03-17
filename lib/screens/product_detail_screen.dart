import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import '../widgets/animated_toast.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  Product? product;
  List<Product> relatedProducts = [];
  bool isLoading = true;
  int quantity = 1;
  late AnimationController _cartAnimController;
  late Animation<double> _cartBounce;

  @override
  void initState() {
    super.initState();
    _cartAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _cartBounce = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _cartAnimController, curve: Curves.elasticOut),
    );
    _loadProduct();
  }

  @override
  void dispose() {
    _cartAnimController.dispose();
    super.dispose();
  }

  Future<void> _loadProduct() async {
    try {
      final api = ref.read(apiServiceProvider);
      final p = await api.getProductById(widget.productId);
      // Load related products from same category
      List<Product> related = [];
      if (p.idList != null) {
        try {
          final result = await api.getProducts(limit: 6, listId: p.idList);
          related = result.items.where((r) => r.id != p.id).take(4).toList();
        } catch (_) {}
      }
      if (mounted) setState(() { product = p; relatedProducts = related; isLoading = false; });
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    ref.read(cartProvider.notifier).addItem(product!, quantity: quantity);
    _cartAnimController.forward().then((_) => _cartAnimController.reverse());
    AnimatedToast.showCartAdded(context);
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final heroTag = 'product-${widget.productId}';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          product?.namevi ?? 'Chi tiết',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                child: Icon(
                  ref.watch(favoritesProvider).contains(widget.productId)
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  key: ValueKey(ref.watch(favoritesProvider).contains(widget.productId)),
                  color: ref.watch(favoritesProvider).contains(widget.productId)
                      ? AppTheme.priceRed
                      : null,
                ),
              ),
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(favoritesProvider.notifier).toggle(widget.productId);
              },
            ),
            CupertinoButton(
              padding: EdgeInsets.zero,
              child: const Icon(CupertinoIcons.share),
              onPressed: () {
                if (product != null) {
                  Share.share(
                    '${product!.namevi} - An Nhi Trà\nhttps://annhitra.com/${product!.slugvi ?? ""}',
                  );
                }
              },
            ),
          ],
        ),
      ),
      child: isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : product == null
              ? const Center(child: Text('Không tìm thấy sản phẩm'))
              : Stack(
                  children: [
                    CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Hero(
                            tag: heroTag,
                            child: CachedNetworkImage(
                              imageUrl: ApiService.getImageUrl(product!.photo, 'product'),
                              width: double.infinity,
                              height: 380,
                              fit: BoxFit.cover,
                              errorWidget: (_, _a, _b) => Container(
                                height: 380,
                                color: AppTheme.groupedBg,
                                child: const Center(
                                  child: Icon(CupertinoIcons.photo, size: 48, color: AppTheme.textMuted),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: BoxDecoration(
                              color: CupertinoColors.systemBackground.resolveFrom(context),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                            transform: Matrix4.translationValues(0, -20, 0),
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Name
                                Text(
                                  product!.namevi ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),

                                // Code
                                if (product!.code != null && product!.code!.isNotEmpty)
                                  Text(
                                    'Mã SP: ${product!.code}',
                                    style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 14,
                                    ),
                                  ),

                                const SizedBox(height: 16),

                                // Price
                                _buildPriceSection(formatter),

                                const SizedBox(height: 20),

                                // Quantity selector
                                _buildQuantitySelector(),

                                const SizedBox(height: 24),

                                // Description
                                if (product!.contentvi != null && product!.contentvi!.isNotEmpty) ...[
                                  const Text(
                                    'Mô tả sản phẩm',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  HtmlWidget(product!.contentvi ?? ''),
                                ],
                              ],
                            ),
                          ),
                        ),

                        // Related products
                        if (relatedProducts.isNotEmpty) ...[
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 4, height: 22,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Sản phẩm liên quan',
                                    style: TextStyle(
                                      fontSize: 20, fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary, letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 220,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: relatedProducts.length,
                                separatorBuilder: (_, __) => const SizedBox(width: 12),
                                itemBuilder: (context, index) {
                                  final rp = relatedProducts[index];
                                  final rpImage = ApiService.getImageUrl(rp.photo, 'product');
                                  return GestureDetector(
                                    onTap: () => context.push('/product/${rp.id}'),
                                    child: Container(
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: CupertinoColors.systemBackground.resolveFrom(context),
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.06),
                                            blurRadius: 8, offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                            child: CachedNetworkImage(
                                              imageUrl: rpImage, height: 130, width: 150,
                                              fit: BoxFit.cover,
                                              errorWidget: (_, _a, _b) => Container(height: 130, color: AppTheme.groupedBg),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(rp.namevi ?? '', maxLines: 2, overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                                                const SizedBox(height: 4),
                                                Text(formatter.format(rp.displayPrice),
                                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.priceRed)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],

                        const SliverToBoxAdapter(child: SizedBox(height: 100)),
                      ],
                    ),

                    // Bottom CTA bar
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                          20, 12, 20,
                          MediaQuery.of(context).padding.bottom + 12,
                        ),
                        decoration: BoxDecoration(
                          color: CupertinoColors.systemBackground.resolveFrom(context),
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
                                const Text('Tổng', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                                product!.displayPrice > 0
                                    ? Text(
                                        formatter.format(product!.displayPrice * quantity),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.priceRed,
                                        ),
                                      )
                                    : const Text(
                                        'Liên hệ',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.accentGold,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ScaleTransition(
                                scale: _cartBounce,
                                child: CupertinoButton.filled(
                                  onPressed: _addToCart,
                                  borderRadius: BorderRadius.circular(14),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(CupertinoIcons.cart_badge_plus, size: 20),
                                      SizedBox(width: 8),
                                      Text('Thêm vào giỏ',
                                          style: TextStyle(fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildPriceSection(NumberFormat formatter) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        if (product!.isOnSale) ...[
          Text(
            formatter.format(product!.salePrice),
            style: const TextStyle(
              color: AppTheme.priceRed,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            formatter.format(product!.regularPrice),
            style: const TextStyle(
              decoration: TextDecoration.lineThrough,
              color: AppTheme.textMuted,
              fontSize: 16,
            ),
          ),
          if (product!.discount != null && product!.discount! > 0)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.priceRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '-${product!.discount!.toInt()}%',
                style: const TextStyle(
                  color: AppTheme.priceRed,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ] else if (product!.regularPrice != null && product!.regularPrice! > 0)
          Text(
            formatter.format(product!.regularPrice),
            style: const TextStyle(
              color: AppTheme.priceRed,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          )
        else
          const Text(
            'Liên hệ báo giá',
            style: TextStyle(
              color: AppTheme.accentGold,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        const Text('Số lượng:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.groupedBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minSize: 0,
                onPressed: quantity > 1
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => quantity--);
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.minus,
                  size: 16,
                  color: quantity > 1 ? AppTheme.textPrimary : AppTheme.textMuted,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minSize: 0,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => quantity++);
                },
                child: const Icon(CupertinoIcons.plus, size: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
