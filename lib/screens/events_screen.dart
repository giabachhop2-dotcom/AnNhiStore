import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/shimmer_grid.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// EVENTS SCREEN — Real data from News API (type=event)
/// Shows workshops, tea tastings, promotions, etc.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  List<NewsArticle> events = [];
  bool isLoading = true;
  bool hasError = false;
  int currentPage = 1;
  int totalPages = 1;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final result = await ref.read(apiServiceProvider).getNews(
        page: currentPage,
        limit: 10,
        type: 'event',
      );
      if (mounted) {
        setState(() {
          events = result.items;
          totalPages = ((result.total + 9) / 10).ceil();
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() { isLoading = false; hasError = true; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Sự Kiện & Workshop'),
      ),
      child: SafeArea(
        child: isLoading
            ? Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(4, (_) => const ShimmerListItem()),
              ))
            : hasError
                ? EmptyState.networkError(onRetry: _loadEvents)
                : events.isEmpty
                    ? _buildEmpty(isDark)
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics(),
                        ),
                        slivers: [
                          CupertinoSliverRefreshControl(onRefresh: _loadEvents),

                          // Header
                          SliverToBoxAdapter(
                            child: Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: isDark
                                      ? [AppTheme.darkElevated, AppTheme.darkSurface]
                                      : [const Color(0xFFF8F4EC), const Color(0xFFF0E8D8)],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: AppTheme.accentGold.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(CupertinoIcons.calendar, size: 36, color: AppTheme.accentGold),
                                  const SizedBox(height: 8),
                                  Text('Sự Kiện An Nhi Trà',
                                      style: TextStyle(
                                        fontSize: 20, fontWeight: FontWeight.bold,
                                        color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                                      )),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Workshop, trải nghiệm trà đạo, khuyến mãi',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Event list
                          SliverPadding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final event = events[index];
                                  return _EventCard(
                                    event: event,
                                    isDark: isDark,
                                    imageUrl: ApiService.getImageUrl(event.photo, 'news'),
                                  );
                                },
                                childCount: events.length,
                              ),
                            ),
                          ),

                          // Pagination
                          if (totalPages > 1)
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(
                                    totalPages,
                                    (i) => GestureDetector(
                                      onTap: () {
                                        setState(() => currentPage = i + 1);
                                        _loadEvents();
                                      },
                                      child: Container(
                                        width: 32, height: 32,
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(
                                          color: currentPage == i + 1
                                              ? AppTheme.accentGold
                                              : (isDark ? AppTheme.darkElevated : AppTheme.groupedBg),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Center(
                                          child: Text('${i + 1}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                                color: currentPage == i + 1
                                                    ? Colors.white
                                                    : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                                              )),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }

  Widget _buildEmpty(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(CupertinoIcons.calendar_badge_plus,
                  size: 36, color: AppTheme.accentGold),
            ),
            const SizedBox(height: 16),
            Text('Chưa có sự kiện',
                style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w600,
                  color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                )),
            const SizedBox(height: 8),
            Text('Các sự kiện workshop trà đạo, tasting,\nkhuyến mãi sẽ hiển thị tại đây.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14, height: 1.4,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                )),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final NewsArticle event;
  final bool isDark;
  final String imageUrl;

  const _EventCard({
    required this.event,
    required this.isDark,
    required this.imageUrl,
  });

  String _formatDate(int timestamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return '${d.day}/${d.month}/${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
            blurRadius: 10, offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          if (imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 160, color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 160,
                  color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                  child: const Icon(CupertinoIcons.calendar, size: 40, color: AppTheme.accentGold),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.accentGold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _formatDate(event.dateCreated ?? 0),
                    style: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(event.namevi ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
                    )),
                if (event.descvi != null && event.descvi!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(event.descvi!,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13, height: 1.4,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textSecondary,
                      )),
                ],
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(CupertinoIcons.eye, size: 13,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted),
                    const SizedBox(width: 4),
                    Text('${event.view} lượt xem',
                        style: TextStyle(fontSize: 12,
                          color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
