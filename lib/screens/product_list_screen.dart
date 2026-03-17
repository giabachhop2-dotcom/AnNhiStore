import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/shimmer_grid.dart';
import '../widgets/empty_state.dart';
import '../config/theme.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  int? selectedListId;
  int currentPage = 1;
  List<Product> products = [];
  List<ProductCategory> lists = [];
  bool isLoading = true;
  int totalPages = 1;
  String searchQuery = '';
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final data = await ref.read(apiServiceProvider).getProductCategories();
      if (mounted) {
        setState(() {
          lists = (data['lists'] as List).map((e) => ProductCategory.fromJson(e)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    try {
      final result = await ref.read(apiServiceProvider).getProducts(
        page: currentPage,
        listId: selectedListId,
        limit: 12,
        search: searchQuery.isNotEmpty ? searchQuery : null,
      );
      if (mounted) {
        setState(() {
          products = result.items;
          totalPages = result.totalPages;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          // iOS Large Title + Search
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Sản Phẩm'),
            border: null,
          ),

          // Search bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchCtrl,
                placeholder: 'Tìm kiếm sản phẩm...',
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    searchQuery = value;
                    currentPage = 1;
                    _loadProducts();
                  });
                },
                onSubmitted: (value) {
                  _debounce?.cancel();
                  searchQuery = value;
                  currentPage = 1;
                  _loadProducts();
                },
                onSuffixTap: () {
                  _debounce?.cancel();
                  _searchCtrl.clear();
                  searchQuery = '';
                  currentPage = 1;
                  _loadProducts();
                },
              ),
            ),
          ),

          // Category filter (horizontal scroll)
          if (lists.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    _CatChip(
                      label: 'Tất cả',
                      selected: selectedListId == null,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() { selectedListId = null; currentPage = 1; });
                        _loadProducts();
                      },
                    ),
                    ...lists.map((cat) => _CatChip(
                      label: cat.namevi ?? '',
                      selected: selectedListId == cat.id,
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() { selectedListId = cat.id; currentPage = 1; });
                        _loadProducts();
                      },
                    )),
                  ],
                ),
              ),
            ),

          // Pull to refresh
          CupertinoSliverRefreshControl(onRefresh: _loadProducts),

          // Product grid or shimmer
          if (isLoading)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, _a) => const ShimmerProductCard(),
                  childCount: 6,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            )
          else if (products.isEmpty)
            SliverFillRemaining(
              child: EmptyState.noResults(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AnimatedProductCard(
                    product: products[index],
                    index: index,
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
            ),

          // Pagination
          if (totalPages > 1 && !isLoading)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: currentPage > 1
                          ? () { setState(() => currentPage--); _loadProducts(); }
                          : null,
                      child: const Icon(CupertinoIcons.chevron_left),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('$currentPage / $totalPages',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: currentPage < totalPages
                          ? () { setState(() => currentPage++); _loadProducts(); }
                          : null,
                      child: const Icon(CupertinoIcons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryDark : CupertinoColors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppTheme.primaryDark : AppTheme.separator,
              width: 1,
            ),
            boxShadow: selected ? [
              BoxShadow(
                color: AppTheme.primaryDark.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? CupertinoColors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
