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
      if (mounted) setState(() { articles = result.items; isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Tin Tức'),
            border: null,
          ),
          CupertinoSliverRefreshControl(onRefresh: _load),

          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList.builder(
                itemCount: 5,
                itemBuilder: (_, _a) => const ShimmerListItem(),
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
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final item = articles[index];
                  final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
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
                          blurRadius: 10,
                          offset: const Offset(0, 3),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CachedNetworkImage(
                              imageUrl: ApiService.getImageUrl(item.photo, 'news'),
                              height: 180,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorWidget: (_, _a, _b) => Container(
                                height: 180,
                                color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                                child: const Center(
                                  child: Icon(CupertinoIcons.news,
                                      color: AppTheme.accentGold, size: 32),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.namevi ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isDark
                                          ? AppTheme.darkTextPrimary
                                          : AppTheme.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.descvi ?? '',
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isDark
                                          ? AppTheme.darkTextSecondary
                                          : AppTheme.textMuted,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(CupertinoIcons.eye, size: 14,
                                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted),
                                      const SizedBox(width: 4),
                                      Text('${item.view ?? 0}',
                                          style: TextStyle(
                                            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                                            fontSize: 12,
                                          )),
                                      const Spacer(),
                                      Text('Đọc tiếp ›',
                                          style: TextStyle(
                                            color: isDark ? AppTheme.accentGold : AppTheme.primaryDark,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          )),
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
                },
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}
