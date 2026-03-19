import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import '../widgets/animated_toast.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/fly_to_cart.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final int productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  Product? product;
  List<Product> relatedProducts = [];
  List<ProductReview> reviews = [];
  int reviewsTotal = 0;
  bool reviewsLoading = false;
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
      if (mounted)
        setState(() {
          product = p;
          relatedProducts = related;
          isLoading = false;
        });
      // Load reviews in background
      _loadReviews();
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _loadReviews() async {
    if (product == null) return;
    setState(() => reviewsLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.getReviews(product!.id, limit: 5);
      if (mounted) {
        setState(() {
          reviews = result.reviews;
          reviewsTotal = result.total;
          reviewsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => reviewsLoading = false);
    }
  }

  void _addToCart() {
    HapticFeedback.mediumImpact();
    ref.read(cartProvider.notifier).addItem(product!, quantity: quantity);
    _cartAnimController.forward().then((_) => _cartAnimController.reverse());
    AnimatedToast.showCartAddedWithProduct(
      context,
      productName: product!.namevi ?? '',
      imageUrl: ApiService.getImageUrl(product!.photo, 'product'),
    );

    // Fly-to-cart
    final imgUrl = ApiService.getImageUrl(product!.photo, 'product');
    FlyToCartAnimation.fly(
      context: context,
      imageWidget: CachedNetworkImage(imageUrl: imgUrl, fit: BoxFit.cover),
      startGlobalOffset: Offset(MediaQuery.of(context).size.width / 2, 280),
    );
  }

  void _openImageViewer(BuildContext ctx) {
    if (product == null) return;
    Navigator.of(ctx).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black.withValues(alpha: 0.9),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        pageBuilder: (_, __, ___) => Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Dismiss on tap background
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(color: Colors.transparent),
              ),
              // Zoomable image
              Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: ApiService.getImageUrl(product!.photo, 'product'),
                    fit: BoxFit.contain,
                    errorWidget: (_, __, ___) => const Icon(
                      CupertinoIcons.photo,
                      size: 64,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ),
              // Close button
              Positioned(
                top: MediaQuery.of(ctx).padding.top + 8,
                right: 16,
                child: CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(ctx),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.xmark,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
              // Zoom hint
              Positioned(
                bottom: MediaQuery.of(ctx).padding.bottom + 24,
                left: 0,
                right: 0,
                child: const Center(
                  child: Text(
                    'Chụm ngón tay để phóng to',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final heroTag = 'product-${widget.productId}';
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

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
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: Icon(
                  ref.watch(favoritesProvider).contains(widget.productId)
                      ? CupertinoIcons.heart_fill
                      : CupertinoIcons.heart,
                  key: ValueKey(
                    ref.watch(favoritesProvider).contains(widget.productId),
                  ),
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
                      child: GestureDetector(
                        onTap: () => _openImageViewer(context),
                        child: Hero(
                          tag: heroTag,
                          child: CachedNetworkImage(
                            imageUrl: ApiService.getImageUrl(
                              product!.photo,
                              'product',
                            ),
                            width: double.infinity,
                            height: 380,
                            fit: BoxFit.cover,
                            errorWidget: (_, _a, _b) => Container(
                              height: 380,
                              color: AppTheme.groupedBg,
                              child: const Center(
                                child: Icon(
                                  CupertinoIcons.photo,
                                  size: 48,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkElevated
                              : AppTheme.surfaceWhite,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        transform: Matrix4.translationValues(0, -20, 0),
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Name
                            Text(
                              product!.namevi ?? '',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? AppTheme.darkTextPrimary
                                    : AppTheme.textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Code
                            if (product!.code != null &&
                                product!.code!.isNotEmpty)
                              Text(
                                'Mã SP: ${product!.code}',
                                style: TextStyle(
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textMuted,
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

                            // ── Product Info Specs ──
                            _buildInfoSection(isDark),

                            const SizedBox(height: 24),

                            // Description
                            if (product!.contentvi != null &&
                                product!.contentvi!.isNotEmpty) ...[
                              Text(
                                'Mô tả sản phẩm',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textPrimary,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 12),
                              HtmlWidget(
                                product!.contentvi ?? '',
                                textStyle: TextStyle(
                                  decoration: TextDecoration.none,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textPrimary,
                                  fontSize: 15,
                                  height: 1.7,
                                  letterSpacing: 0.1,
                                ),
                                customStylesBuilder: (element) {
                                  // GLOBAL: strip ALL underlines from every element
                                  final styles = <String, String>{
                                    'text-decoration': 'none',
                                  };
                                  if (element.localName == 'a') {
                                    styles['color'] = '#C8A96E';
                                    styles['font-weight'] = '600';
                                  }
                                  if (element.localName == 'strong' ||
                                      element.localName == 'b') {
                                    styles['color'] = isDark
                                        ? '#F5EFE3'
                                        : '#2C1810';
                                  }
                                  if (element.localName == 'u' ||
                                      element.localName == 'ins') {
                                    styles['text-decoration'] = 'none';
                                  }
                                  return styles;
                                },
                              ),
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
                                width: 4,
                                height: 22,
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'Sản phẩm liên quan',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.accentGold,
                                  letterSpacing: -0.3,
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
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, index) {
                              final rp = relatedProducts[index];
                              final rpImage = ApiService.getImageUrl(
                                rp.photo,
                                'product',
                              );
                              return GestureDetector(
                                onTap: () => context.push('/product/${rp.id}'),
                                child: Container(
                                  width: 150,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppTheme.darkElevated
                                        : AppTheme.surfaceWhite,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDark
                                          ? AppTheme.darkSeparator.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppTheme.separator.withValues(
                                              alpha: 0.4,
                                            ),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.15 : 0.05,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            const BorderRadius.vertical(
                                              top: Radius.circular(12),
                                            ),
                                        child: CachedNetworkImage(
                                          imageUrl: rpImage,
                                          height: 130,
                                          width: 150,
                                          fit: BoxFit.cover,
                                          errorWidget: (_, _a, _b) => Container(
                                            height: 130,
                                            color: isDark
                                                ? AppTheme.darkSurface
                                                : AppTheme.groupedBg,
                                            child: Center(
                                              child: Icon(
                                                CupertinoIcons.photo,
                                                color: isDark
                                                    ? AppTheme.darkTextSecondary
                                                    : AppTheme.textMuted,
                                                size: 24,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              rp.namevi ?? '',
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                                color: isDark
                                                    ? AppTheme.darkTextPrimary
                                                    : AppTheme.textPrimary,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            rp.displayPrice > 0
                                                ? Text(
                                                    formatter.format(
                                                      rp.displayPrice,
                                                    ),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppTheme.priceRed,
                                                    ),
                                                  )
                                                : const Text(
                                                    'Liên hệ',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color:
                                                          AppTheme.accentGold,
                                                      fontStyle:
                                                          FontStyle.italic,
                                                    ),
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
                        ),
                      ),
                    ],

                    // Reviews section
                    SliverToBoxAdapter(child: _buildReviewsSection(isDark)),

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
                      20,
                      12,
                      20,
                      MediaQuery.of(context).padding.bottom + 12,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppTheme.darkElevated
                          : AppTheme.surfaceWhite,
                      border: Border(
                        top: BorderSide(
                          color: isDark
                              ? AppTheme.darkSeparator.withValues(alpha: 0.2)
                              : AppTheme.separator.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    child: product!.displayPrice > 0
                        ? _buildPricedCTA(formatter, isDark)
                        : _buildContactCTA(isDark),
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

  /// Bottom CTA for products WITH a price — show price + cart button
  Widget _buildPricedCTA(NumberFormat formatter, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Tổng',
              style: TextStyle(
                color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              formatter.format(product!.displayPrice * quantity),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFC8A96E),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ScaleTransition(
            scale: _cartBounce,
            child: GoldCTAButton(
              label: 'Thêm vào giỏ',
              icon: CupertinoIcons.cart_badge_plus,
              compact: true,
              onPressed: _addToCart,
            ),
          ),
        ),
      ],
    );
  }

  /// Bottom CTA for CONTACT products — show "Liên hệ báo giá" + quick Zalo
  Widget _buildContactCTA(bool isDark) {
    final settingsAsync = ref.watch(settingsProvider);
    final opts =
        settingsAsync.whenOrNull(
          data: (s) => s['optionsParsed'] as Map<String, dynamic>?,
        ) ??
        {};
    final phone = (opts['hotline'] ?? opts['phone'] ?? '0827626962').toString();
    final zalo = (opts['zalo'] ?? phone).toString();
    final productName = product?.namevi ?? 'sản phẩm';

    return Row(
      children: [
        // Quick Zalo button
        CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: const Color(0xFF0068FF),
          borderRadius: BorderRadius.circular(12),
          minSize: 0,
          onPressed: () {
            HapticFeedback.mediumImpact();
            _launchExternalUrl('https://zalo.me/$zalo');
          },
          child: const Icon(
            CupertinoIcons.chat_bubble_fill,
            size: 20,
            color: CupertinoColors.white,
          ),
        ),
        const SizedBox(width: 10),
        // Main CTA — "Liên hệ báo giá" opens action sheet
        Expanded(
          child: GoldCTAButton(
            label: 'Liên hệ báo giá',
            icon: CupertinoIcons.phone_circle_fill,
            compact: true,
            onPressed: () {
              HapticFeedback.mediumImpact();
              _showContactSheet(phone, zalo, productName);
            },
          ),
        ),
      ],
    );
  }

  void _showContactSheet(String phone, String zalo, String productName) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text('Liên hệ báo giá'),
        message: Text(productName, style: const TextStyle(fontSize: 13)),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _launchExternalUrl('https://zalo.me/$zalo');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.chat_bubble_fill,
                  size: 20,
                  color: Color(0xFF0068FF),
                ),
                const SizedBox(width: 8),
                Text(
                  'Nhắn tin Zalo ($zalo)',
                  style: const TextStyle(color: Color(0xFF0068FF)),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _launchExternalUrl('tel:$phone');
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  CupertinoIcons.phone_fill,
                  size: 20,
                  color: Color(0xFF2D8B4E),
                ),
                const SizedBox(width: 8),
                Text(
                  'Gọi điện ($phone)',
                  style: const TextStyle(color: Color(0xFF2D8B4E)),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(ctx);
              _launchExternalUrl(
                'sms:$phone?body=Xin chào, tôi muốn hỏi giá $productName',
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.bubble_left_fill,
                  size: 20,
                  color: Color(0xFF8B6914),
                ),
                SizedBox(width: 8),
                Text(
                  'Nhắn tin SMS',
                  style: TextStyle(color: Color(0xFF8B6914)),
                ),
              ],
            ),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: phone));
              Navigator.pop(ctx);
              if (mounted) {
                AnimatedToast.show(
                  context,
                  icon: CupertinoIcons.checkmark_circle_fill,
                  message: 'Đã sao chép SĐT: $phone',
                );
              }
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.doc_on_clipboard,
                  size: 20,
                  color: CupertinoColors.systemGrey,
                ),
                SizedBox(width: 8),
                Text(
                  'Sao chép số điện thoại',
                  style: TextStyle(color: CupertinoColors.systemGrey),
                ),
              ],
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Đóng'),
        ),
      ),
    );
  }

  Future<void> _launchExternalUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Widget _buildQuantitySelector() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Row(
      children: [
        Text(
          'Số lượng:',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppTheme.darkSeparator : AppTheme.separator,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                onPressed: quantity > 1
                    ? () {
                        HapticFeedback.selectionClick();
                        setState(() => quantity--);
                      }
                    : null,
                child: Icon(
                  CupertinoIcons.minus,
                  size: 16,
                  color: quantity > 1
                      ? (isDark ? AppTheme.accentGold : AppTheme.primaryDark)
                      : AppTheme.textMuted,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppTheme.accentGold : AppTheme.primaryDark,
                  ),
                ),
              ),
              CupertinoButton(
                padding: const EdgeInsets.all(8),
                minimumSize: Size.zero,
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => quantity++);
                },
                child: Icon(
                  CupertinoIcons.plus,
                  size: 16,
                  color: isDark ? AppTheme.accentGold : AppTheme.primaryDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(bool isDark) {
    final p = product!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 22,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.accentGold, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Thông tin sản phẩm',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // 2-column specs grid
        _buildSpecsGrid(isDark, p),
      ],
    );
  }

  Widget _buildSpecsGrid(bool isDark, Product p) {
    // Meta key → icon + label mapping
    const metaConfig = <String, ({IconData icon, String label})>{
      'origin': (icon: CupertinoIcons.location, label: 'Nguồn gốc'),
      'material': (icon: CupertinoIcons.paintbrush, label: 'Chất liệu'),
      'volume': (icon: CupertinoIcons.drop, label: 'Dung tích / KL'),
      'quality': (
        icon: CupertinoIcons.leaf_arrow_circlepath,
        label: 'Chất lượng',
      ),
      'certification': (
        icon: CupertinoIcons.shield_lefthalf_fill,
        label: 'Chứng nhận',
      ),
      'storage': (icon: CupertinoIcons.cube_box, label: 'Bảo quản'),
      'artisan_level': (icon: CupertinoIcons.star, label: 'Cấp nghệ nhân'),
      'year': (icon: CupertinoIcons.calendar, label: 'Năm thu hoạch'),
      'brewing_temp': (icon: CupertinoIcons.flame, label: 'Nhiệt độ pha'),
      'brewing_time': (icon: CupertinoIcons.timer, label: 'Thời gian pha'),
      'stock_status': (icon: CupertinoIcons.archivebox, label: 'Tình trạng'),
      'weight': (icon: CupertinoIcons.gauge, label: 'Trọng lượng'),
    };

    // Always show type + code, then dynamic specs from DB
    final specs = <_SpecItem>[
      _SpecItem(CupertinoIcons.tag, 'Loại SP', p.type ?? 'Trà & Ấm'),
      _SpecItem(CupertinoIcons.barcode, 'Mã SP', p.code ?? '—'),
    ];

    for (final entry in p.specs.entries) {
      final config = metaConfig[entry.key];
      if (config != null && entry.value.isNotEmpty) {
        specs.add(_SpecItem(config.icon, config.label, entry.value));
      }
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        final spec = specs[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.darkSurface.withValues(alpha: 0.6)
                : const Color(0xFFFAF7F2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? AppTheme.darkSeparator.withValues(alpha: 0.15)
                  : AppTheme.accentGold.withValues(alpha: 0.15),
            ),
          ),
          child: Row(
            children: [
              Icon(spec.icon, size: 18, color: AppTheme.accentGold),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      spec.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                        letterSpacing: 0.3,
                      ),
                    ),
                    Text(
                      spec.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Reviews Section ────────────────────────────────
  Widget _buildReviewsSection(bool isDark) {
    final avg = product?.avgRating ?? 0;
    final total = product?.reviewsCount ?? reviewsTotal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                CupertinoIcons.star_fill,
                size: 20,
                color: const Color(0xFFFFB800),
              ),
              const SizedBox(width: 6),
              Text(
                avg > 0 ? avg.toStringAsFixed(1) : '—',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '($total đánh giá)',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textMuted,
                ),
              ),
              const Spacer(),
              CupertinoButton(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                color: AppTheme.primaryDark,
                borderRadius: BorderRadius.circular(8),
                minSize: 0,
                onPressed: () => _showReviewForm(),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.pencil,
                      size: 14,
                      color: CupertinoColors.white,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Viết đánh giá',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: CupertinoColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Star distribution bars
          if (total > 0 && reviews.isNotEmpty) ...[
            ...List.generate(5, (i) {
              final star = 5 - i;
              final count = reviews.where((r) => r.rating == star).length;
              final pct = total > 0 ? count / total : 0.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  children: [
                    SizedBox(
                      width: 14,
                      child: Text(
                        '$star',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.star_fill,
                      size: 12,
                      color: Color(0xFFFFB800),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        height: 6,
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppTheme.darkSeparator
                              : AppTheme.groupedBg,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: pct,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFB800),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 24,
                      child: Text(
                        '$count',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
          ],

          // Review cards
          if (reviewsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CupertinoActivityIndicator(),
              ),
            )
          else if (reviews.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'Chưa có đánh giá nào.\nHãy là người đầu tiên! ⭐',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...reviews.map((review) {
              final date = review.dateCreated > 0
                  ? DateTime.fromMillisecondsSinceEpoch(
                      review.dateCreated * 1000,
                    )
                  : null;
              final dateStr = date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : '';
              final initial = review.authorName.isNotEmpty
                  ? review.authorName[0].toUpperCase()
                  : '?';
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryDark.withValues(alpha: 0.8),
                                AppTheme.accentGold.withValues(alpha: 0.6),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              initial,
                              style: const TextStyle(
                                color: CupertinoColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                review.authorName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark
                                      ? AppTheme.darkTextPrimary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                dateStr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Stars
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? CupertinoIcons.star_fill
                                  : CupertinoIcons.star,
                              size: 14,
                              color: const Color(0xFFFFB800),
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (review.content != null &&
                        review.content!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        review.content!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  void _showReviewForm() {
    final nameCtrl = TextEditingController();
    final contentCtrl = TextEditingController();
    int selectedRating = 5;

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModalState) => Container(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx2).viewInsets.bottom + 20,
          ),
          decoration: BoxDecoration(
            color: CupertinoTheme.brightnessOf(ctx2) == Brightness.dark
                ? AppTheme.darkElevated
                : CupertinoColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    'Viết đánh giá',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                // Star picker
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (i) {
                      return CupertinoButton(
                        padding: const EdgeInsets.all(4),
                        minSize: 0,
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          setModalState(() => selectedRating = i + 1);
                        },
                        child: Icon(
                          i < selectedRating
                              ? CupertinoIcons.star_fill
                              : CupertinoIcons.star,
                          size: 32,
                          color: const Color(0xFFFFB800),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 12),
                CupertinoTextField(
                  controller: nameCtrl,
                  placeholder: 'Tên của bạn *',
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.groupedBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: contentCtrl,
                  placeholder: 'Nhận xét của bạn...',
                  maxLines: 3,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.groupedBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: CupertinoButton.filled(
                    borderRadius: BorderRadius.circular(12),
                    onPressed: () async {
                      if (nameCtrl.text.trim().length < 2) {
                        return;
                      }
                      HapticFeedback.mediumImpact();
                      Navigator.pop(ctx);
                      try {
                        final api = ref.read(apiServiceProvider);
                        await api.submitReview(
                          product!.id,
                          authorName: nameCtrl.text.trim(),
                          rating: selectedRating,
                          content: contentCtrl.text.trim(),
                        );
                        _loadReviews();
                        if (mounted) {
                          AnimatedToast.show(
                            context,
                            icon: CupertinoIcons.checkmark_circle_fill,
                            message: 'Cảm ơn bạn đã đánh giá!',
                          );
                        }
                      } catch (_) {
                        if (mounted) {
                          AnimatedToast.show(
                            context,
                            icon: CupertinoIcons.exclamationmark_circle,
                            message: 'Không thể gửi đánh giá',
                          );
                        }
                      }
                    },
                    child: const Text(
                      'Gửi đánh giá',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
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
}

class _SpecItem {
  final IconData icon;
  final String label;
  final String value;
  const _SpecItem(this.icon, this.label, this.value);
}
