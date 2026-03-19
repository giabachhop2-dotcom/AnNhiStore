import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import '../widgets/shimmer_grid.dart';
import '../widgets/empty_state.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// NEWS LIST SCREEN — Storytelling Premium Layout
/// Hero featured card + editorial grid + golden accents
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class NewsListScreen extends ConsumerStatefulWidget {
  const NewsListScreen({super.key});

  @override
  ConsumerState<NewsListScreen> createState() => _NewsListScreenState();
}

class _NewsListScreenState extends ConsumerState<NewsListScreen> {
  List<NewsArticle> articles = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await ref.read(apiServiceProvider).getNews(limit: 20);
      if (mounted)
        setState(() {
          articles = result.items;
          isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  String _formatDate(int? timestamp) {
    if (timestamp == null || timestamp == 0) return '';
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    const months = [
      'Th01',
      'Th02',
      'Th03',
      'Th04',
      'Th05',
      'Th06',
      'Th07',
      'Th08',
      'Th09',
      'Th10',
      'Th11',
      'Th12',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Premium header ──
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 20,
                right: 20,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: isDark
                      ? [AppTheme.darkSurface, AppTheme.darkGroupedBg]
                      : [AppTheme.surfaceWhite, AppTheme.groupedBg],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        CupertinoIcons.doc_text_fill,
                        size: 15,
                        color: AppTheme.accentGold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'TIN TỨC & CÂU CHUYỆN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.accentGold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Khám Phá\nThế Giới Trà',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppTheme.accentGold
                          : AppTheme.primaryDark,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          CupertinoSliverRefreshControl(onRefresh: _load),

          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.builder(
                itemCount: 5,
                itemBuilder: (_, __) => const ShimmerListItem(),
              ),
            )
          else if (articles.isEmpty)
            SliverFillRemaining(
              child: EmptyState(
                icon: CupertinoIcons.news,
                title: 'Chưa có tin tức',
                description: 'Nội dung sẽ được cập nhật sớm',
              ),
            )
          else ...[
            // ── Hero featured article (first one) ──
            if (articles.isNotEmpty)
              SliverToBoxAdapter(child: _buildHeroCard(articles.first, isDark)),

            // ── Section label ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Row(
                  children: [
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Bài Viết Mới Nhất',
                      style: TextStyle(
                        fontSize: 16,
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
            ),

            // ── Article list (remaining) ──
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: articles.length > 1 ? articles.length - 1 : 0,
                itemBuilder: (context, index) {
                  final item = articles[index + 1];
                  return _buildStoryCard(item, isDark, index);
                },
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),
          ],
        ],
      ),
    );
  }

  /// Hero featured card — large image with overlay text
  Widget _buildHeroCard(NewsArticle item, bool isDark) {
    final imageUrl = ApiService.getImageUrl(item.photo, 'news');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/news/${item.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background image
              CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  color: isDark ? AppTheme.darkElevated : AppTheme.primaryDark,
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.news,
                      color: AppTheme.accentGold,
                      size: 48,
                    ),
                  ),
                ),
              ),
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                    stops: const [0.0, 0.4, 1.0],
                  ),
                ),
              ),
              // "Featured" badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentGold.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.star_fill,
                        size: 10,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'NỔI BẬT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Title + desc overlay
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.namevi ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                        height: 1.3,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.dateCreated),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          CupertinoIcons.eye,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.view ?? 0} lượt xem',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
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
      ),
    );
  }

  /// Story card — horizontal layout with image left, content right
  Widget _buildStoryCard(NewsArticle item, bool isDark, int index) {
    final imageUrl = ApiService.getImageUrl(item.photo, 'news');

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        context.push('/news/${item.id}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? AppTheme.darkSeparator.withValues(alpha: 0.2)
                : AppTheme.separator.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100,
                height: 90,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  width: 100,
                  height: 90,
                  color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                  child: const Icon(
                    CupertinoIcons.news,
                    color: AppTheme.accentGold,
                    size: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: SizedBox(
                height: 90,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title — golden accent
                    Text(
                      item.namevi ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: isDark
                            ? AppTheme.accentGold
                            : AppTheme.primaryDark,
                        height: 1.3,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    if (item.descvi != null && item.descvi!.isNotEmpty)
                      Expanded(
                        child: Text(
                          item.descvi!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textMuted,
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ),
                    const Spacer(),
                    // Meta row
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.clock,
                          size: 11,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          _formatDate(item.dateCreated),
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textMuted,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Đọc ›',
                          style: TextStyle(
                            color: AppTheme.accentGold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
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
    );
  }
}
