import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/animated_product_card.dart';
import '../widgets/empty_state.dart';
import '../config/theme.dart';

/// Full-screen search experience with animated expansion, debounce, and recent searches
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;
  List<Product> _results = [];
  List<String> _recentSearches = [];
  bool _isLoading = false;
  bool _hasSearched = false;

  // Entry animation
  late AnimationController _entryController;
  late Animation<double> _entryFade;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _entryFade = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );
    _entryController.forward();
    _loadRecentSearches();

    // Auto-focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    _entryController.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _saveRecentSearch(String query) async {
    if (query.trim().isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    _recentSearches.remove(query);
    _recentSearches.insert(0, query);
    if (_recentSearches.length > 8) {
      _recentSearches = _recentSearches.sublist(0, 8);
    }
    await prefs.setStringList('recent_searches', _recentSearches);
  }

  Future<void> _clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('recent_searches');
    setState(() => _recentSearches = []);
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _hasSearched = false;
        _isLoading = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isLoading = true);

    try {
      final api = ref.read(apiServiceProvider);
      final result = await api.getProducts(search: query, limit: 20);
      if (mounted) {
        setState(() {
          _results = result.items;
          _isLoading = false;
          _hasSearched = true;
        });
        _saveRecentSearch(query.trim());
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasSearched = true;
        });
      }
    }
  }

  void _searchFromRecent(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _performSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: AppTheme.groupedBg,
      child: FadeTransition(
        opacity: _entryFade,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Search bar
              _buildSearchBar(),
              // Content
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        border: Border(
          bottom: BorderSide(color: AppTheme.separator.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CupertinoSearchTextField(
              controller: _searchController,
              focusNode: _focusNode,
              placeholder: 'Tìm kiếm trà, ấm tử sa...',
              onChanged: _onSearchChanged,
              onSubmitted: _performSearch,
              style: const TextStyle(fontSize: 16),
              prefixInsets: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                color: AppTheme.groupedBg,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: Size.zero,
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Hủy',
              style: TextStyle(fontSize: 16, color: AppTheme.primaryDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CupertinoActivityIndicator(radius: 14));
    }

    // Show search results
    if (_hasSearched) {
      if (_results.isEmpty) {
        return EmptyState.noResults();
      }
      return _buildResultsGrid();
    }

    // Show recent searches
    return _buildRecentSearches();
  }

  Widget _buildResultsGrid() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${_results.length} sản phẩm được tìm thấy',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  AnimatedProductCard(product: _results[index], index: index),
              childCount: _results.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.62,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }

  Widget _buildRecentSearches() {
    const popularTags = [
      'Trà Shan Tuyết',
      'Ấm Tử Sa',
      'Trà Ô Long',
      'Ấm Đất',
      'Bạch Trà',
      'Trà Cụ',
      'Hồng Trà',
      'Chén Kiến Thủy',
      'Trà Phổ Nhĩ',
      'Trà Xanh',
    ];

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Popular tags
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.flame_fill,
                size: 16,
                color: Color(0xFFFF6B35),
              ),
              const SizedBox(width: 6),
              const Text(
                'Tìm kiếm phổ biến',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  _searchFromRecent(tag);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryDark.withValues(alpha: 0.08),
                        AppTheme.accentGold.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.primaryDark.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryDark,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),

        // Recent searches
        if (_recentSearches.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tìm kiếm gần đây',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  onPressed: _clearRecentSearches,
                  child: const Text(
                    'Xóa tất cả',
                    style: TextStyle(fontSize: 13, color: AppTheme.priceRed),
                  ),
                ),
              ],
            ),
          ),
          ..._recentSearches.map((query) {
            return CupertinoListTile(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: const Icon(
                CupertinoIcons.clock,
                size: 18,
                color: AppTheme.textMuted,
              ),
              title: Text(query, style: const TextStyle(fontSize: 15)),
              trailing: CupertinoButton(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                onPressed: () {
                  setState(() => _recentSearches.remove(query));
                  SharedPreferences.getInstance().then(
                    (prefs) =>
                        prefs.setStringList('recent_searches', _recentSearches),
                  );
                },
                child: const Icon(
                  CupertinoIcons.xmark,
                  size: 14,
                  color: AppTheme.textMuted,
                ),
              ),
              onTap: () => _searchFromRecent(query),
            );
          }),
        ],
      ],
    );
  }
}
