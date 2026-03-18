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
  String _sortBy = 'default'; // default, price_asc, price_desc, name
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

  List<Product> get _sortedProducts {
    if (_sortBy == 'default') return products;
    final sorted = [...products];
    switch (_sortBy) {
      case 'price_asc':
        sorted.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
      case 'price_desc':
        sorted.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
      case 'name':
        sorted.sort((a, b) => (a.namevi ?? '').compareTo(b.namevi ?? ''));
    }
    return sorted;
  }

  void _showSortOptions() {
    HapticFeedback.selectionClick();
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Sắp xếp theo'),
        actions: [
          _sortAction('Mặc định', 'default'),
          _sortAction('Giá tăng dần', 'price_asc'),
          _sortAction('Giá giảm dần', 'price_desc'),
          _sortAction('Tên A → Z', 'name'),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
      ),
    );
  }

  CupertinoActionSheetAction _sortAction(String label, String value) {
    return CupertinoActionSheetAction(
      onPressed: () {
        setState(() => _sortBy = value);
        Navigator.pop(context);
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label),
          if (_sortBy == value) ...[
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.checkmark, size: 16, color: AppTheme.primaryDark),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Sản Phẩm'),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showSortOptions,
              child: const Icon(CupertinoIcons.sort_down, size: 24),
            ),
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
                height: 46,
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
                    product: _sortedProducts[index],
                    index: index,
                  ),
                  childCount: _sortedProducts.length,
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

class _CatChip extends StatefulWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip({required this.label, required this.selected, required this.onTap});

  @override
  State<_CatChip> createState() => _CatChipState();
}

class _CatChipState extends State<_CatChip> with SingleTickerProviderStateMixin {
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut, reverseCurve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: GestureDetector(
        onTapDown: (_) => _scaleCtrl.forward(),
        onTapUp: (_) => _scaleCtrl.reverse(),
        onTapCancel: () => _scaleCtrl.reverse(),
        onTap: widget.onTap,
        child: ScaleTransition(
          scale: _scaleAnim,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              gradient: widget.selected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppTheme.primaryDark, Color(0xFF2D5E3E)],
                    )
                  : null,
              color: widget.selected
                  ? null
                  : (isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.selected
                    ? AppTheme.accentGold.withValues(alpha: 0.5)
                    : (isDark ? AppTheme.darkSeparator : AppTheme.separator),
                width: widget.selected ? 1.5 : 1,
              ),
              boxShadow: widget.selected ? [
                BoxShadow(
                  color: AppTheme.primaryDark.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                fontWeight: widget.selected ? FontWeight.w700 : FontWeight.w500,
                color: widget.selected
                    ? AppTheme.accentGold
                    : (isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary),
                letterSpacing: widget.selected ? 0.3 : 0,
              ),
              child: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
