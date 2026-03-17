import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_grid.dart';
import '../widgets/empty_state.dart';
import '../config/theme.dart';

/// Favorites screen — shows all products user has hearted.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  List<Product> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    final favoriteIds = ref.read(favoritesProvider);
    if (favoriteIds.isEmpty) {
      setState(() {
        _products = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final api = ref.read(apiServiceProvider);
      // Batch-load all favorites in parallel (not N+1)
      final futures = favoriteIds.map((id) async {
        try {
          return await api.getProductById(id);
        } catch (_) {
          return null;
        }
      });
      final results = await Future.wait(futures);
      final loaded = results.whereType<Product>().toList();
      if (mounted) {
        setState(() {
          _products = loaded;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch favorites to auto-reload when changed
    final favoriteIds = ref.watch(favoritesProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Yêu Thích (${favoriteIds.length})'),
        trailing: favoriteIds.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Text('Xóa tất cả',
                    style: TextStyle(color: AppTheme.priceRed, fontSize: 14)),
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showCupertinoDialog(
                    context: context,
                    builder: (ctx) => CupertinoAlertDialog(
                      title: const Text('Xóa tất cả yêu thích?'),
                      actions: [
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            for (final id in {...favoriteIds}) {
                              ref.read(favoritesProvider.notifier).toggle(id);
                            }
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
      child: _isLoading
          ? Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: 4,
                itemBuilder: (_, __) => const ShimmerProductCard(),
              ),
            )
          : favoriteIds.isEmpty
              ? EmptyState(
                  icon: CupertinoIcons.heart,
                  title: 'Chưa có sản phẩm yêu thích',
                  description: 'Nhấn vào biểu tượng ♡ trên sản phẩm để lưu vào danh sách',
                  actionLabel: 'Khám phá sản phẩm',
                  onAction: () => context.go('/products'),
                )
              : RefreshIndicator(
                  onRefresh: _loadFavorites,
                  color: AppTheme.primaryDark,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Filter out products no longer in favorites
                              final visibleProducts = _products
                                  .where((p) => favoriteIds.contains(p.id))
                                  .toList();
                              if (index >= visibleProducts.length) return null;
                              return AnimatedProductCard(
                                product: visibleProducts[index],
                                index: index,
                              );
                            },
                            childCount: _products
                                .where((p) => favoriteIds.contains(p.id))
                                .length,
                          ),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.62,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    ],
                  ),
                ),
    );
  }
}
