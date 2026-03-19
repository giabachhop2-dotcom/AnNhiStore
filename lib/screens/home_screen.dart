import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/providers.dart';
import '../services/api_service.dart';
import '../models/models.dart';
import '../config/theme.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/shimmer_grid.dart';
import '../widgets/empty_state.dart';
import '../widgets/scroll_to_top_fab.dart';
import '../widgets/floating_contact_cta.dart';
import '../widgets/daily_tea_wisdom.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<PhotoItem> slides = [];
  List<Product> productsAmTuSa = [];
  List<Product> productsTra = [];
  List<Product> productsTraCu = [];
  List<NewsArticle> newsItems = [];
  List<PhotoItem> certificates = [];
  List<NewsArticle> testimonials = [];
  bool isLoading = true;
  bool hasError = false;
  int _currentSlide = 0;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    setState(() => _scrollOffset = _scrollController.offset);
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Chào buổi sáng! ☀️';
    if (hour < 18) return 'Chào buổi chiều! 🌤️';
    return 'Chào buổi tối! 🌙';
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final api = ref.read(apiServiceProvider);
    try {
      final results = await Future.wait([
        api.getPhotos(type: 'slide'), // 0: slides
        api.getProducts(limit: 8), // 1: all latest (for Ấm Tử Sa filter)
        api.getProducts(limit: 8, listId: 44), // 2: Trà túi lọc 2026
        api.getNews(limit: 10), // 3: all news
        api.getPhotos(type: 'chung-nhan'), // 4: certificates
        api.getNews(limit: 6, type: 'camnhan'), // 5: testimonials
      ]);

      if (mounted) {
        // Parse all products — split by type
        final allProducts =
            (results[1] as ({List<Product> items, int total, int totalPages}))
                .items;
        final traProducts =
            (results[2] as ({List<Product> items, int total, int totalPages}))
                .items;

        // Client-side: split by type
        final amTuSaList = allProducts
            .where((p) => p.type == 'am-tu-sa')
            .toList();
        final traList = allProducts.where((p) => p.type == 'tra').toList();
        final traCuList = allProducts.where((p) => p.type == 'tra-cu').toList();

        // If type-filtered are sparse, fill from all
        if (amTuSaList.isEmpty) amTuSaList.addAll(allProducts.take(4));

        // Client-side news filter: exclude policy articles
        final allNews =
            (results[3] as ({List<NewsArticle> items, int total})).items;
        final filteredNews = allNews.where((n) {
          final name = (n.namevi ?? '').toLowerCase();
          // Exclude spam/policy articles uploaded by previous developers
          const excludeKeywords = [
            'chính sách',
            'thanh toán',
            'vận chuyển',
            'giao nhận',
            'bảo hành',
            'đổi trả',
            'miễn phí',
            'bảo mật',
            'sở nhiên',
            'phương hằng',
            'tại công ty',
            'chuyển khoản',
          ];
          // Also exclude generic "An Nhi Trà" alone (without substantial content)
          final isGenericAnNhi =
              name == 'an nhi trà' ||
              name == 'an nhi tra' ||
              name == 'an nhi trà sg';
          return !excludeKeywords.any((kw) => name.contains(kw)) &&
              !isGenericAnNhi;
        }).toList();

        setState(() {
          slides = results[0] as List<PhotoItem>;
          productsAmTuSa = amTuSaList;
          productsTra = traList.isNotEmpty ? traList : traProducts;
          productsTraCu = traCuList;
          newsItems = filteredNews;
          certificates = results[4] as List<PhotoItem>;
          testimonials =
              (results[5] as ({List<NewsArticle> items, int total})).items;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (hasError && !isLoading) {
      return CupertinoPageScaffold(
        child: EmptyState.networkError(onRetry: _loadData),
      );
    }

    return CupertinoPageScaffold(
      child: isLoading
          ? _buildShimmerLoading()
          : Stack(
              children: [
                CustomScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    // ── Greeting Header (Tea Bliss style) ──
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 12,
                          left: 20,
                          right: 20,
                          bottom: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color:
                                          CupertinoTheme.brightnessOf(
                                                context,
                                              ) ==
                                              Brightness.dark
                                          ? AppTheme.darkTextPrimary
                                          : AppTheme.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar / Logo
                            GestureDetector(
                              onTap: () => context.push('/search'),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: const Color(0xFF114402),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(
                                        0xFF114402,
                                      ).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Inline Search Bar ──
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                        child: GestureDetector(
                          onTap: () => context.push('/search'),
                          child: Container(
                            height: 44,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color:
                                  CupertinoTheme.brightnessOf(context) ==
                                      Brightness.dark
                                  ? AppTheme.darkElevated
                                  : const Color(0xFFF2F2F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.search,
                                  size: 18,
                                  color:
                                      CupertinoTheme.brightnessOf(context) ==
                                          Brightness.dark
                                      ? AppTheme.darkTextSecondary
                                      : AppTheme.textMuted,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Tìm kiếm sản phẩm...',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color:
                                        CupertinoTheme.brightnessOf(context) ==
                                            Brightness.dark
                                        ? AppTheme.darkTextSecondary
                                        : AppTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // ── Pull to Refresh ──
                    CupertinoSliverRefreshControl(onRefresh: _loadData),

                    // ── Parallax Hero Banner ──
                    if (slides.isNotEmpty)
                      SliverToBoxAdapter(child: _buildBanner()),

                    // ── Quick Category Access ──
                    SliverToBoxAdapter(child: _buildCategoryGrid()),

                    // ── Featured Products Carousel ──
                    if (productsAmTuSa.isNotEmpty || productsTra.isNotEmpty)
                      SliverToBoxAdapter(child: _buildFeaturedCarousel()),

                    // ── Daily Tea Wisdom ──
                    const SliverToBoxAdapter(child: DailyTeaWisdom()),

                    // ── Featured Ấm Tử Sa — Horizontal Showcase ──
                    if (productsAmTuSa.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: TeaCeremonyHeader(
                          title: 'Ấm Tử Sa Nghệ Thuật',
                          subtitle: 'Nghệ nhân hàng đầu Nghi Hưng',
                          onSeeAll: () => context.push('/products'),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: productsAmTuSa.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: AnimatedProductCard(
                                    product: productsAmTuSa[index],
                                    index: index,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    // ── Trà Section — Grid Layout ──
                    if (productsTra.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: TeaCeremonyHeader(
                          title: 'Bộ Sưu Tập Trà',
                          subtitle: 'Trà Thiết Quan Âm, Ô Long, Phổ Nhĩ...',
                          onSeeAll: () => context.push('/products'),
                        ),
                      ),
                      _buildProductGrid(
                        productsTra,
                        indexOffset: productsAmTuSa.length,
                      ),
                    ],

                    // ── Trà Cụ — Tea Tools ──
                    if (productsTraCu.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: TeaCeremonyHeader(
                          title: 'Trà Cụ & Phụ Kiện',
                          subtitle: 'Khay trà, chén, tống, thảm bàn trà',
                          onSeeAll: () => context.push('/products'),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 280,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: productsTraCu.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: 200,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: AnimatedProductCard(
                                    product: productsTraCu[index],
                                    index:
                                        productsAmTuSa.length +
                                        productsTra.length +
                                        index,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    // ── Testimonials (Cảm nhận) ──
                    if (testimonials.isNotEmpty)
                      SliverToBoxAdapter(child: _buildTestimonials()),

                    // ── News ──
                    if (newsItems.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: TeaCeremonyHeader(
                          title: 'Kiến Thức Trà Đạo',
                          subtitle: 'Câu chuyện về trà, ấm & sức khỏe',
                          onSeeAll: () => context.go('/news'),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: newsItems.length > 5
                                ? 5
                                : newsItems.length,
                            itemBuilder: (context, index) {
                              return SizedBox(
                                width: MediaQuery.of(context).size.width * 0.7,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                  ),
                                  child: _NewsCard(item: newsItems[index]),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],

                    // ── Certificates ──
                    if (certificates.isNotEmpty)
                      SliverToBoxAdapter(child: _buildCertificates()),

                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                  ],
                ),
                ScrollToTopFab(scrollController: _scrollController),
                // Floating Zalo/Phone CTA
                Positioned(
                  right: 16,
                  bottom: MediaQuery.of(context).padding.bottom + 80,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final settingsAsync = ref.watch(settingsProvider);
                      return settingsAsync.when(
                        data: (s) {
                          final opts =
                              s['optionsParsed'] as Map<String, dynamic>? ?? {};
                          final phone =
                              opts['hotline'] ?? opts['phone'] ?? '0827626962';
                          final zalo = opts['zalo'] ?? phone;
                          return FloatingContactCta(
                            phone: phone.toString(),
                            zalo: zalo.toString(),
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const FloatingContactCta(
                          phone: '0827626962',
                          zalo: '0827626962',
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildBanner() {
    // Parallax factor: banner moves slower than scroll
    final parallaxOffset = _scrollOffset * 0.3;

    return ClipRect(
      child: Transform.translate(
        offset: Offset(0, parallaxOffset.clamp(0, 60)),
        child: Column(
          children: [
            CarouselSlider(
              items: slides.map((slide) {
                final url = ApiService.getImageUrl(slide.photo, 'photo');
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, _a) => Shimmer.fromColors(
                        baseColor: AppTheme.separator,
                        highlightColor: AppTheme.groupedBg,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                      errorWidget: (_, _a, _b) =>
                          Container(color: AppTheme.primaryBg),
                    ),
                  ),
                );
              }).toList(),
              options: CarouselOptions(
                height: 200,
                viewportFraction: 0.92,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 4),
                autoPlayAnimationDuration: const Duration(milliseconds: 800),
                autoPlayCurve: Curves.easeInOutCubic,
                enlargeCenterPage: true,
                enlargeFactor: 0.15,
                onPageChanged: (index, _) =>
                    setState(() => _currentSlide = index),
              ),
            ),
            const SizedBox(height: 12),
            // Animated page indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(slides.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentSlide == index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _currentSlide == index
                        ? AppTheme.primaryDark
                        : AppTheme.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                    boxShadow: _currentSlide == index
                        ? [
                            BoxShadow(
                              color: AppTheme.primaryDark.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 6,
                              spreadRadius: 1,
                            ),
                          ]
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final categories = [
      {
        'icon': CupertinoIcons.flame,
        'label': 'Ấm Tử Sa',
        'gradient': [const Color(0xFFD4A574), const Color(0xFFB8860B)],
      },
      {
        'icon': CupertinoIcons.leaf_arrow_circlepath,
        'label': 'Trà',
        'gradient': [const Color(0xFF4CAF50), const Color(0xFF2E7D32)],
      },
      {
        'icon': CupertinoIcons.tray_2,
        'label': 'Phụ Kiện',
        'gradient': [const Color(0xFF8D6E63), const Color(0xFF5D4037)],
      },
      {
        'icon': CupertinoIcons.gift,
        'label': 'Quà Tặng',
        'gradient': [const Color(0xFFE57373), const Color(0xFFC62828)],
      },
      {
        'icon': CupertinoIcons.sparkles,
        'label': 'Yến Sào',
        'gradient': [const Color(0xFFFFD54F), const Color(0xFFF9A825)],
      },
      {
        'icon': CupertinoIcons.star_circle,
        'label': 'VIP',
        'gradient': [const Color(0xFFCE93D8), const Color(0xFF7B1FA2)],
      },
    ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final gradient = cat['gradient'] as List<Color>;
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/products');
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [
                              gradient[0].withValues(alpha: 0.4),
                              gradient[1].withValues(alpha: 0.4),
                            ]
                          : gradient,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 24,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['label'] as String,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final allProducts = [...productsAmTuSa, ...productsTra];
    final featured = allProducts.take(5).toList();
    if (featured.isEmpty) return const SizedBox.shrink();

    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppTheme.accentGold, AppTheme.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Sản Phẩm Nổi Bật',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
        CarouselSlider(
          items: featured.map((product) {
            final imgUrl = ApiService.getImageUrl(product.photo, 'product');
            return GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                context.push('/product/${product.id}');
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.12,
                      ),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Product image
                      Hero(
                        tag: 'product-${product.id}',
                        child: CachedNetworkImage(
                          imageUrl: imgUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _a, _b) => Container(
                            color: isDark
                                ? AppTheme.darkSurface
                                : AppTheme.groupedBg,
                            child: Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                size: 40,
                                color: isDark
                                    ? AppTheme.darkTextSecondary
                                    : AppTheme.textMuted,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Gradient overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 32, 16, 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.namevi ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  product.displayPrice > 0
                                      ? Text(
                                          formatter.format(
                                            product.displayPrice,
                                          ),
                                          style: const TextStyle(
                                            color: AppTheme.accentGold,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        )
                                      : const Text(
                                          'Liên hệ',
                                          style: TextStyle(
                                            color: AppTheme.accentGold,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentGold.withValues(
                                        alpha: 0.9,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Text(
                                      'Xem ngay',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          options: CarouselOptions(
            height: 220,
            viewportFraction: 0.85,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.easeInOutCubic,
            enlargeCenterPage: true,
            enlargeFactor: 0.12,
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(List<Product> products, {int indexOffset = 0}) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => AnimatedProductCard(
            product: products[index],
            index: index + indexOffset,
          ),
          childCount: products.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.62,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
      ),
    );
  }

  Widget _buildTestimonials() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryDark,
            AppTheme.primaryDark.withValues(alpha: 0.85),
          ],
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Cảm Nhận Khách Hàng',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.white,
              letterSpacing: -0.41,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tin tưởng & yêu thương từ khách hàng',
            style: TextStyle(
              fontSize: 14,
              color: CupertinoColors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          CarouselSlider(
            items: testimonials.map((item) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: CupertinoColors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: CupertinoColors.white.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Stars
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          CupertinoIcons.star_fill,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                        Icon(
                          CupertinoIcons.star_fill,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                        Icon(
                          CupertinoIcons.star_fill,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                        Icon(
                          CupertinoIcons.star_fill,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                        Icon(
                          CupertinoIcons.star_fill,
                          color: AppTheme.accentGold,
                          size: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '"${item.descvi ?? ""}"',
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: CupertinoColors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: CachedNetworkImageProvider(
                            ApiService.getImageUrl(item.photo, 'news'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          item.namevi ?? '',
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
            options: CarouselOptions(
              height: 220,
              autoPlay: true,
              enlargeCenterPage: true,
              enlargeFactor: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificates() {
    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Text(
            'Chứng Nhận Chất Lượng',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryDark,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: certificates.length,
              separatorBuilder: (_, _a) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: ApiService.getImageUrl(cert.photo, 'photo'),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return CustomScrollView(
      slivers: [
        const CupertinoSliverNavigationBar(
          largeTitle: Text('An Nhi Trà'),
          border: null,
        ),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: AppTheme.separator,
            highlightColor: AppTheme.groupedBg,
            child: Container(
              margin: const EdgeInsets.all(16),
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (_, _a) => const ShimmerProductCard(),
              childCount: 4,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _NewsCard extends StatelessWidget {
  final NewsArticle item;
  const _NewsCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/news/${item.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Full-bleed image ──
              CachedNetworkImage(
                imageUrl: ApiService.getImageUrl(item.photo, 'news'),
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.news,
                      color: AppTheme.accentGold,
                      size: 32,
                    ),
                  ),
                ),
              ),
              // ── Gradient overlay ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
              // ── Text overlay at bottom ──
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namevi ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: CupertinoColors.white,
                        height: 1.3,
                        shadows: [Shadow(blurRadius: 4, color: Colors.black54)],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.eye,
                          size: 12,
                          color: CupertinoColors.white.withValues(alpha: 0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.view ?? 0} lượt xem',
                          style: TextStyle(
                            fontSize: 11,
                            color: CupertinoColors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // ── Circular category badge ──
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.accentGold.withValues(alpha: 0.9),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withValues(alpha: 0.3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.doc_text,
                      size: 16,
                      color: CupertinoColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
