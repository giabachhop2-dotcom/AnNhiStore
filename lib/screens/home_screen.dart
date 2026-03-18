import 'package:flutter/cupertino.dart';
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

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    final api = ref.read(apiServiceProvider);
    try {
      final results = await Future.wait([
        api.getPhotos(type: 'slide'),
        api.getProducts(limit: 6, listId: 1),
        api.getProducts(limit: 6, listId: 2),
        api.getNews(limit: 6),
        api.getPhotos(type: 'chung-nhan'),
        api.getNews(limit: 6, type: 'camnhan'),
      ]);

      if (mounted) {
        setState(() {
          slides = results[0] as List<PhotoItem>;
          productsAmTuSa =
              (results[1] as ({List<Product> items, int total, int totalPages}))
                  .items;
          productsTra =
              (results[2] as ({List<Product> items, int total, int totalPages}))
                  .items;
          newsItems =
              (results[3] as ({List<NewsArticle> items, int total})).items;
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
                    // ── iOS Large Title Navigation Bar ──
                    CupertinoSliverNavigationBar(
                      largeTitle: Row(
                        children: [
                          Image.asset('assets/images/logo.png', height: 28),
                          const SizedBox(width: 8),
                          const Text('An Nhi Trà'),
                        ],
                      ),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.search),
                        onPressed: () => context.push('/search'),
                      ),
                      backgroundColor: CupertinoColors.systemBackground,
                      border: null,
                    ),

                    // ── Pull to Refresh ──
                    CupertinoSliverRefreshControl(onRefresh: _loadData),

                    // ── Parallax Hero Banner ──
                    if (slides.isNotEmpty)
                      SliverToBoxAdapter(child: _buildBanner()),

                    // ── Quick Category Access ──
                    SliverToBoxAdapter(child: _buildCategoryGrid()),

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

                    // ── Trà Shan Tuyết — Grid Layout ──
                    if (productsTra.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: TeaCeremonyHeader(
                          title: 'Trà Shan Tuyết Cổ Thụ',
                          subtitle: 'Hương vị đỉnh núi 1500m',
                          onSeeAll: () => context.push('/products'),
                        ),
                      ),
                      _buildProductGrid(
                        productsTra,
                        indexOffset: productsAmTuSa.length,
                      ),
                    ],

                    // ── Testimonials (Cảm nhận) ──
                    if (testimonials.isNotEmpty)
                      SliverToBoxAdapter(child: _buildTestimonials()),

                    // ── News ──
                    if (newsItems.isNotEmpty) ...[
                      SliverToBoxAdapter(
                        child: TeaCeremonyHeader(
                          title: 'Tin Tức & Sự Kiện',
                          subtitle: 'Cập nhật từ An Nhi Trà',
                          onSeeAll: () => context.go('/news'),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        sliver: SliverList.builder(
                          itemCount: newsItems.length > 3
                              ? 3
                              : newsItems.length,
                          itemBuilder: (context, index) =>
                              _NewsCard(item: newsItems[index]),
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

    return Transform.translate(
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
                            color: AppTheme.primaryDark.withValues(alpha: 0.4),
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
    );
  }

  Widget _buildCategoryGrid() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    const categories = [
      {'icon': '🫖', 'label': 'Ấm Tử Sa'},
      {'icon': '🍵', 'label': 'Trà Shan'},
      {'icon': '🏺', 'label': 'Phụ Kiện'},
      {'icon': '🎁', 'label': 'Quà Tặng'},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: categories.map((cat) {
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              context.push('/products');
            },
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark
                        ? AppTheme.darkElevated
                        : AppTheme.surfaceWhite,
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withValues(
                          alpha: isDark ? 0.1 : 0.15,
                        ),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      cat['icon']!,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  cat['label']!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppTheme.darkSeparator.withValues(alpha: 0.2)
              : AppTheme.separator.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CupertinoButton(
        padding: EdgeInsets.zero,
        onPressed: () {
          HapticFeedback.selectionClick();
          context.push('/news/${item.id}');
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(14),
                ),
                child: CachedNetworkImage(
                  imageUrl: ApiService.getImageUrl(item.photo, 'news'),
                  width: 100,
                  height: 85,
                  fit: BoxFit.cover,
                  errorWidget: (_, _a, _b) => Container(
                    width: 100,
                    height: 85,
                    color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                    child: const Icon(
                      CupertinoIcons.news,
                      color: AppTheme.accentGold,
                      size: 24,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.namevi ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.eye,
                            size: 12,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textMuted,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${item.view ?? 0}',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppTheme.darkTextSecondary
                                  : AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
