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

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// PRODUCT LIST — 3-Layer Premium Browsing
/// Layer 1: Type tabs (Ấm Tử Sa / Trà / Trà Cụ)
/// Layer 2: Sub-category pills (filtered by type)
/// Layer 3: Product grid with differentiated cards
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  // ── Product type definitions ──
  static const _productTypes = [
    _ProductType(
      'am-tu-sa',
      'Ấm Tử Sa',
      CupertinoIcons.flame,
      Color(0xFFC8A96E),
    ),
    _ProductType(
      'tra',
      'Trà',
      CupertinoIcons.leaf_arrow_circlepath,
      Color(0xFF4A7C5C),
    ),
    _ProductType(
      'tra-cu',
      'Trà Cụ',
      CupertinoIcons.tray_full,
      Color(0xFF8B6914),
    ),
  ];

  // ── State ──
  String? _selectedType; // null = all products
  int? _selectedListId; // sub-category filter
  int _currentPage = 1;
  List<Product> _products = [];
  List<ProductCategory> _allLists = [];
  bool _isLoading = true;
  int _totalPages = 1;
  int _totalProducts = 0;
  String _searchQuery = '';
  String _sortBy = 'default';
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  // Filtered sub-categories for current type
  List<ProductCategory> get _filteredLists {
    if (_selectedType == null) return _allLists;
    return _allLists.where((c) => c.type == _selectedType).toList();
  }

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
          _allLists = (data['lists'] as List)
              .map((e) => ProductCategory.fromJson(e))
              .where(
                (c) => c.type != 'san-pham',
              ) // Exclude legacy shoe categories
              .toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(apiServiceProvider)
          .getProducts(
            page: _currentPage,
            listId: _selectedListId,
            limit: 12,
            search: _buildSearchQuery(),
          );
      if (mounted) {
        setState(() {
          _products = result.items;
          _totalPages = result.totalPages;
          _totalProducts = result.total;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Build search query — combine user search with type filter
  String? _buildSearchQuery() {
    final parts = <String>[];
    if (_searchQuery.isNotEmpty) parts.add(_searchQuery);
    // If type selected but no specific listId, we filter client-side
    if (parts.isEmpty) return null;
    return parts.join(' ');
  }

  /// Get products filtered by type (client-side if needed)
  List<Product> get _displayProducts {
    var list = [..._products];

    // Filter by type client-side when no listId is selected
    if (_selectedType != null && _selectedListId == null) {
      list = list.where((p) => p.type == _selectedType).toList();
    }

    // Sort
    switch (_sortBy) {
      case 'price_asc':
        list.sort((a, b) => a.displayPrice.compareTo(b.displayPrice));
      case 'price_desc':
        list.sort((a, b) => b.displayPrice.compareTo(a.displayPrice));
      case 'name':
        list.sort((a, b) => (a.namevi ?? '').compareTo(b.namevi ?? ''));
    }
    return list;
  }

  void _selectType(String? type) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedType = type;
      _selectedListId = null;
      _currentPage = 1;
    });
    _loadProducts();
  }

  void _selectSubCategory(int? listId) {
    HapticFeedback.selectionClick();
    setState(() {
      _selectedListId = listId;
      _currentPage = 1;
    });
    _loadProducts();
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
            const Icon(
              CupertinoIcons.checkmark,
              size: 16,
              color: AppTheme.primaryDark,
            ),
          ],
        ],
      ),
    );
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
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Sản Phẩm'),
            border: null,
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _showSortOptions,
              child: const Icon(CupertinoIcons.sort_down, size: 24),
            ),
          ),

          // ── Search bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: CupertinoSearchTextField(
                controller: _searchCtrl,
                placeholder: 'Tìm kiếm ấm, trà, phụ kiện...',
                onChanged: (value) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 500), () {
                    _searchQuery = value;
                    _currentPage = 1;
                    _loadProducts();
                  });
                },
                onSubmitted: (value) {
                  _debounce?.cancel();
                  _searchQuery = value;
                  _currentPage = 1;
                  _loadProducts();
                },
                onSuffixTap: () {
                  _debounce?.cancel();
                  _searchCtrl.clear();
                  _searchQuery = '';
                  _currentPage = 1;
                  _loadProducts();
                },
              ),
            ),
          ),

          // ── LAYER 1: Type Segmentation Tabs ──
          SliverToBoxAdapter(child: _buildTypeTabs(isDark)),

          // ── LAYER 2: Sub-Category Pills ──
          if (_filteredLists.isNotEmpty && _selectedType != null)
            SliverToBoxAdapter(child: _buildSubCategoryPills(isDark)),

          // ── Filter Status Bar ──
          SliverToBoxAdapter(child: _buildFilterBar(isDark)),

          // Pull to refresh
          CupertinoSliverRefreshControl(onRefresh: _loadProducts),

          // ── LAYER 3: Product Grid ──
          if (_isLoading)
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
          else if (_displayProducts.isEmpty)
            SliverFillRemaining(child: EmptyState.noResults())
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => AnimatedProductCard(
                    product: _displayProducts[index],
                    index: index,
                  ),
                  childCount: _displayProducts.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.62,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
              ),
            ),

          // ── Pagination ──
          if (_totalPages > 1 && !_isLoading)
            SliverToBoxAdapter(child: _buildPagination(isDark)),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LAYER 1: Type Segmentation Tabs
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildTypeTabs(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _TypeTab(
              label: 'Tất cả',
              icon: CupertinoIcons.square_grid_2x2,
              accentColor: AppTheme.accentGold,
              isSelected: _selectedType == null,
              isDark: isDark,
              onTap: () => _selectType(null),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TypeTab(
              label: _productTypes[0].label,
              icon: _productTypes[0].icon,
              accentColor: _productTypes[0].color,
              isSelected: _selectedType == _productTypes[0].key,
              isDark: isDark,
              onTap: () => _selectType(_productTypes[0].key),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TypeTab(
              label: _productTypes[1].label,
              icon: _productTypes[1].icon,
              accentColor: _productTypes[1].color,
              isSelected: _selectedType == _productTypes[1].key,
              isDark: isDark,
              onTap: () => _selectType(_productTypes[1].key),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _TypeTab(
              label: _productTypes[2].label,
              icon: _productTypes[2].icon,
              accentColor: _productTypes[2].color,
              isSelected: _selectedType == _productTypes[2].key,
              isDark: isDark,
              onTap: () => _selectType(_productTypes[2].key),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // LAYER 2: Sub-Category Pills
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildSubCategoryPills(bool isDark) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          _SubCatPill(
            label: 'Tất cả',
            selected: _selectedListId == null,
            isDark: isDark,
            accentColor: _productTypes
                .firstWhere(
                  (t) => t.key == _selectedType,
                  orElse: () => _productTypes.first,
                )
                .color,
            onTap: () => _selectSubCategory(null),
          ),
          ..._filteredLists.map(
            (cat) => _SubCatPill(
              label: cat.namevi ?? '',
              selected: _selectedListId == cat.id,
              isDark: isDark,
              accentColor: _productTypes
                  .firstWhere(
                    (t) => t.key == _selectedType,
                    orElse: () => _productTypes.first,
                  )
                  .color,
              onTap: () => _selectSubCategory(cat.id),
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Filter Status Bar
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildFilterBar(bool isDark) {
    final hasActiveFilter = _selectedType != null || _selectedListId != null;
    final count = _isLoading ? '...' : '$_totalProducts';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
      child: Row(
        children: [
          // Product count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count sản phẩm',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
          if (hasActiveFilter) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() {
                  _selectedType = null;
                  _selectedListId = null;
                  _currentPage = 1;
                });
                _loadProducts();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.xmark_circle_fill,
                      size: 12,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Xóa lọc',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.accentGold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const Spacer(),
          // Sort indicator
          if (_sortBy != 'default')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primaryDark.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _sortBy == 'price_asc'
                    ? '↑ Giá'
                    : _sortBy == 'price_desc'
                    ? '↓ Giá'
                    : 'A→Z',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // Pagination
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildPagination(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: _currentPage > 1
                ? () {
                    setState(() => _currentPage--);
                    _loadProducts();
                  }
                : null,
            child: const Icon(CupertinoIcons.chevron_left),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.darkElevated
                  : AppTheme.primaryDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$_currentPage / $_totalPages',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
              ),
            ),
          ),
          CupertinoButton(
            padding: const EdgeInsets.all(8),
            onPressed: _currentPage < _totalPages
                ? () {
                    setState(() => _currentPage++);
                    _loadProducts();
                  }
                : null,
            child: const Icon(CupertinoIcons.chevron_right),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Product Type Definition
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _ProductType {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  const _ProductType(this.key, this.label, this.icon, this.color);
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TYPE TAB — Premium animated tab button
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.15),
                    accentColor.withValues(alpha: 0.05),
                  ],
                )
              : null,
          color: isSelected
              ? null
              : (isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.6)
                : (isDark
                      ? AppTheme.darkSeparator.withValues(alpha: 0.3)
                      : AppTheme.separator.withValues(alpha: 0.3)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? accentColor
                  : (isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? accentColor
                    : (isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textMuted),
                letterSpacing: isSelected ? 0.3 : 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUB-CATEGORY PILL — Smaller, accent-tinted
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class _SubCatPill extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _SubCatPill({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected
                ? accentColor.withValues(alpha: 0.15)
                : (isDark
                      ? AppTheme.darkElevated.withValues(alpha: 0.6)
                      : AppTheme.surfaceWhite),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? accentColor.withValues(alpha: 0.6)
                  : (isDark
                        ? AppTheme.darkSeparator.withValues(alpha: 0.2)
                        : AppTheme.separator.withValues(alpha: 0.3)),
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? accentColor
                  : (isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
