import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// NEWS DETAIL — Premium Storytelling Layout
/// Immersive hero image + editorial typography
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class NewsDetailScreen extends ConsumerStatefulWidget {
  final int newsId;
  const NewsDetailScreen({super.key, required this.newsId});

  @override
  ConsumerState<NewsDetailScreen> createState() => _NewsDetailScreenState();
}

class _NewsDetailScreenState extends ConsumerState<NewsDetailScreen> {
  NewsArticle? article;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final a = await ref.read(apiServiceProvider).getNewsById(widget.newsId);
      if (mounted)
        setState(() {
          article = a;
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
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${d.day} ${months[d.month - 1]}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          article?.namevi ?? 'Bài Viết',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.share),
          onPressed: () {
            if (article != null) {
              HapticFeedback.selectionClick();
              Share.share(
                '${article!.namevi} - An Nhi Trà\nhttps://annhitra.com/${article!.slugvi ?? ""}',
              );
            }
          },
        ),
      ),
      child: isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : article == null
          ? const Center(
              child: Text(
                'Không tìm thấy bài viết',
                style: TextStyle(fontSize: 16),
              ),
            )
          : _buildContent(isDark),
    );
  }

  Widget _buildContent(bool isDark) {
    final imageUrl = ApiService.getImageUrl(article!.photo, 'news');
    final hasContent =
        article!.contentvi != null && article!.contentvi!.trim().isNotEmpty;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Hero Image with gradient overlay ──
          Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorWidget: (_, __, ___) => Container(
                  height: 280,
                  color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                  child: const Center(
                    child: Icon(
                      CupertinoIcons.news,
                      size: 48,
                      color: AppTheme.accentGold,
                    ),
                  ),
                ),
              ),
              // Bottom gradient for smooth transition into content
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        isDark ? AppTheme.darkGroupedBg : AppTheme.surfaceWhite,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // ── Article Header ──
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title — Golden, premium
                Text(
                  article!.namevi ?? '',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGold,
                    letterSpacing: -0.5,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 14),

                // Meta bar: date + views
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark
                          ? AppTheme.darkSeparator.withValues(alpha: 0.2)
                          : AppTheme.separator.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Date
                      Icon(
                        CupertinoIcons.calendar,
                        size: 14,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formatDate(article!.dateCreated),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Container(
                        width: 1,
                        height: 14,
                        color: isDark
                            ? AppTheme.darkSeparator
                            : AppTheme.separator,
                      ),
                      const SizedBox(width: 16),
                      // Views
                      Icon(
                        CupertinoIcons.eye,
                        size: 14,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${article!.view ?? 0} lượt xem',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
              ],
            ),
          ),

          // ── Description (if any) ──
          if (article!.descvi != null && article!.descvi!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(
                    alpha: isDark ? 0.08 : 0.05,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border(
                    left: BorderSide(color: AppTheme.accentGold, width: 3),
                  ),
                ),
                child: Text(
                  article!.descvi!,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                    fontStyle: FontStyle.italic,
                    height: 1.6,
                  ),
                ),
              ),
            ),

          // ── Divider ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: isDark ? AppTheme.darkSeparator : AppTheme.separator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    CupertinoIcons.leaf_arrow_circlepath,
                    size: 16,
                    color: AppTheme.accentGold,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 0.5,
                    color: isDark ? AppTheme.darkSeparator : AppTheme.separator,
                  ),
                ),
              ],
            ),
          ),

          // ── Content ──
          if (hasContent)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: HtmlWidget(
                article!.contentvi!,
                textStyle: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                  letterSpacing: 0.2,
                ),
                customStylesBuilder: (element) {
                  if (element.localName == 'img') {
                    return {
                      'max-width': '100%',
                      'border-radius': '12px',
                      'margin': '16px 0',
                    };
                  }
                  if (element.localName == 'p') {
                    return {'margin-bottom': '16px', 'line-height': '1.8'};
                  }
                  if (element.localName == 'h1' ||
                      element.localName == 'h2' ||
                      element.localName == 'h3') {
                    final gold = AppTheme.accentGold;
                    return {
                      'color':
                          'rgb(${gold.r.toInt()},${gold.g.toInt()},${gold.b.toInt()})',
                      'font-weight': 'bold',
                      'margin-top': '24px',
                      'margin-bottom': '12px',
                    };
                  }
                  return null;
                },
              ),
            )
          else
            // No content fallback
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      CupertinoIcons.doc_text,
                      size: 40,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textMuted,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nội dung đang được cập nhật',
                      style: TextStyle(
                        fontSize: 15,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Vui lòng quay lại sau',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom padding
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
