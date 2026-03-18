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

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// PRODUCT LIST — 2-Step Category-First Browsing
/// Step 1: Beautiful category grid (shown first)
/// Step 2: Product grid with compact category bar on top
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

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
      'Nghệ nhân Nghi Hưng',
    ),
    _ProductType(
      'tra',
      'Trà',
      CupertinoIcons.leaf_arrow_circlepath,
      Color(0xFF5A8F6B),
      'Trà thượng hạng Trung Quốc',
    ),
    _ProductType(
      'tra-cu',
      'Trà Cụ',
      CupertinoIcons.tray_full,
      Color(0xFF8B6914),
      'Dụng cụ trà đạo',
    ),
  ];

  // ── State ──
  bool _showingCategoryBrowse = true; // Start with category selection
  String? _selectedType;
  int? _selectedListId;
  int _currentPage = 1;
  List<Product> _products = [];
  List<ProductCategory> _allLists = [];
  bool _isLoading = true;
  bool _categoriesLoading = true;
  int _totalPages = 1;
  int _totalProducts = 0;
  String _searchQuery = '';
  String _sortBy = 'default';
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  List<ProductCategory> get _filteredLists {
    if (_selectedType == null) return _allLists;
    return _allLists.where((c) => c.type == _selectedType).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadCategories();
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
              .where((c) => c.type != 'san-pham')
              .toList();
          _categoriesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _categoriesLoading = false);
    }
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final result = await ref
          .read(apiServiceProvider)
          .getProducts(
            page: _currentPage,
            listId: _selectedListId,
            limit: 20,
            search: _searchQuery.isNotEmpty ? _searchQuery : null,
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

  List<Product> get _displayProducts {
    var list = [..._products];
    if (_selectedType != null && _selectedListId == null) {
      list = list.where((p) => p.type == _selectedType).toList();
    }
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

  /// Enter a category type from the browse screen
  void _enterType(String typeKey) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedType = typeKey;
      _selectedListId = null;
      _currentPage = 1;
      _showingCategoryBrowse = false;
    });
    _loadProducts();
  }

  /// Enter a specific sub-category
  void _enterSubCategory(String typeKey, int listId) {
    HapticFeedback.mediumImpact();
    setState(() {
      _selectedType = typeKey;
      _selectedListId = listId;
      _currentPage = 1;
      _showingCategoryBrowse = false;
    });
    _loadProducts();
  }

  /// Go back to category browse
  void _backToCategories() {
    HapticFeedback.selectionClick();
    setState(() {
      _showingCategoryBrowse = true;
      _selectedType = null;
      _selectedListId = null;
      _products = [];
    });
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
    if (_showingCategoryBrowse) {
      return _buildCategoryBrowse();
    }
    return _buildProductGrid();
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STEP 1: Category Browse — Beautiful, immersive grid
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildCategoryBrowse() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Bộ Sưu Tập'),
            border: null,
          ),

          // ── Hero Type Cards ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      'Chọn dòng sản phẩm',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  // 3 type cards
                  ..._productTypes.map((type) => _buildTypeCard(type, isDark)),
                ],
              ),
            ),
          ),

          // ── Sub-category Grid ──
          if (!_categoriesLoading && _allLists.isNotEmpty)
            ..._productTypes.map((type) => _buildCategorySection(type, isDark)),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildTypeCard(_ProductType type, bool isDark) {
    final subCats = _allLists.where((c) => c.type == type.key).toList();
    final count = subCats.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _enterType(type.key),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                type.color.withValues(alpha: isDark ? 0.20 : 0.12),
                type.color.withValues(alpha: isDark ? 0.08 : 0.04),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: type.color.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: type.color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: type.color.withValues(alpha: isDark ? 0.25 : 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: type.color.withValues(alpha: 0.3),
                      width: 0.5,
                    ),
                  ),
                  child: Icon(type.icon, size: 24, color: type.color),
                ),
                const SizedBox(width: 16),
                // Info
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        type.subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$count danh mục',
                        style: TextStyle(
                          fontSize: 11,
                          color: type.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Arrow
                Icon(
                  CupertinoIcons.chevron_right,
                  size: 18,
                  color: type.color.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Build a section of sub-categories for a given product type
  SliverToBoxAdapter _buildCategorySection(_ProductType type, bool isDark) {
    final subCats = _allLists.where((c) => c.type == type.key).toList();
    if (subCats.isEmpty)
      return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 18,
                  decoration: BoxDecoration(
                    color: type.color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  type.label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => _enterType(type.key),
                  child: Text(
                    'Xem tất cả →',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: type.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Horizontal scrollable chips
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: subCats.length,
              itemBuilder: (_, i) {
                final cat = subCats[i];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: GestureDetector(
                    onTap: () => _enterSubCategory(type.key, cat.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? type.color.withValues(alpha: 0.10)
                            : type.color.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: type.color.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        cat.namevi ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // STEP 2: Product Grid with compact category bar
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Widget _buildProductGrid() {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final currentType = _productTypes.firstWhere(
      (t) => t.key == _selectedType,
      orElse: () => _productTypes.first,
    );

    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: Text(currentType.label),
            border: null,
            leading: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _backToCategories,
              child: const Icon(CupertinoIcons.chevron_left, size: 22),
            ),
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
                placeholder: 'Tìm kiếm ${currentType.label.toLowerCase()}...',
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

          // ── Compact Type Switcher ──
          SliverToBoxAdapter(
            child: SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: _productTypes
                    .map(
                      (type) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() {
                              _selectedType = type.key;
                              _selectedListId = null;
                              _currentPage = 1;
                            });
                            _loadProducts();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              gradient: _selectedType == type.key
                                  ? LinearGradient(
                                      colors: [
                                        type.color.withValues(alpha: 0.20),
                                        type.color.withValues(alpha: 0.08),
                                      ],
                                    )
                                  : null,
                              color: _selectedType == type.key
                                  ? null
                                  : (isDark
                                        ? AppTheme.darkElevated
                                        : AppTheme.surfaceWhite),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _selectedType == type.key
                                    ? type.color.withValues(alpha: 0.6)
                                    : (isDark
                                          ? AppTheme.darkSeparator.withValues(
                                              alpha: 0.2,
                                            )
                                          : AppTheme.separator.withValues(
                                              alpha: 0.3,
                                            )),
                                width: _selectedType == type.key ? 1.5 : 0.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  type.icon,
                                  size: 14,
                                  color: _selectedType == type.key
                                      ? type.color
                                      : (isDark
                                            ? AppTheme.darkTextSecondary
                                            : AppTheme.textMuted),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  type.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: _selectedType == type.key
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _selectedType == type.key
                                        ? type.color
                                        : (isDark
                                              ? AppTheme.darkTextSecondary
                                              : AppTheme.textMuted),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),

          // ── Sub-Category Pills ──
          if (_filteredLists.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: SizedBox(
                  height: 34,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      _buildCompactPill(
                        'Tất cả',
                        _selectedListId == null,
                        currentType.color,
                        isDark,
                        () => _selectSubCategory(null),
                      ),
                      ..._filteredLists.map(
                        (cat) => _buildCompactPill(
                          cat.namevi ?? '',
                          _selectedListId == cat.id,
                          currentType.color,
                          isDark,
                          () => _selectSubCategory(cat.id),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Filter Status Bar ──
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  Text(
                    _isLoading ? '...' : '$_totalProducts sản phẩm',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  if (_sortBy != 'default')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: currentType.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _sortBy == 'price_asc'
                            ? '↑ Giá'
                            : _sortBy == 'price_desc'
                            ? '↓ Giá'
                            : 'A→Z',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: currentType.color,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // Pull to refresh
          CupertinoSliverRefreshControl(onRefresh: _loadProducts),

          // ── Product Grid ──
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
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            )
          else if (_displayProducts.isEmpty)
            SliverFillRemaining(child: EmptyState.noResults())
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
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
                  childAspectRatio: 0.72,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
              ),
            ),

          // ── Pagination ──
          if (_totalPages > 1 && !_isLoading)
            SliverToBoxAdapter(
              child: Padding(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
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
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
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
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }

  Widget _buildCompactPill(
    String label,
    bool selected,
    Color accent,
    bool isDark,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: selected
                ? accent.withValues(alpha: 0.15)
                : (isDark
                      ? AppTheme.darkElevated.withValues(alpha: 0.5)
                      : AppTheme.surfaceWhite),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? accent.withValues(alpha: 0.5)
                  : (isDark
                        ? AppTheme.darkSeparator.withValues(alpha: 0.15)
                        : AppTheme.separator.withValues(alpha: 0.2)),
              width: selected ? 1.2 : 0.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? accent
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

// ━━━━ Data Model ━━━━
class _ProductType {
  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final String subtitle;
  const _ProductType(
    this.key,
    this.label,
    this.icon,
    this.color,
    this.subtitle,
  );
}
