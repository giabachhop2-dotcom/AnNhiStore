import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../services/api_service.dart';
import '../config/theme.dart';

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
      if (mounted) setState(() { article = a; isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          article?.namevi ?? 'Chi tiết',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.share),
          onPressed: () {
            if (article != null) {
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
              ? const Center(child: Text('Không tìm thấy bài viết'))
              : SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CachedNetworkImage(
                        imageUrl: ApiService.getImageUrl(article!.photo, 'news'),
                        width: double.infinity,
                        height: 240,
                        fit: BoxFit.cover,
                        errorWidget: (_, _a, _b) =>
                            Container(height: 240, color: AppTheme.groupedBg),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              article!.namevi ?? '',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                letterSpacing: -0.5,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(CupertinoIcons.eye, size: 14, color: AppTheme.textMuted),
                                const SizedBox(width: 4),
                                Text('${article!.view ?? 0} lượt xem',
                                    style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            HtmlWidget(article!.contentvi ?? ''),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
