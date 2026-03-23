import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/api_service.dart';
export 'auth_provider.dart';

// ── API Service singleton ──
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// ── Products ──
final productsProvider =
    FutureProvider.family<
      ({List<Product> items, int total, int totalPages}),
      ({int page, int? listId, int? catId, String? search})
    >((ref, params) {
      final api = ref.read(apiServiceProvider);
      return api.getProducts(
        page: params.page,
        listId: params.listId,
        catId: params.catId,
        search: params.search,
      );
    });

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) {
  return ref.read(apiServiceProvider).getProductById(id);
});

final productCategoriesProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(apiServiceProvider).getProductCategories();
});

// ── News ──
final newsProvider =
    FutureProvider.family<
      ({List<NewsArticle> items, int total}),
      ({int page, String? type})
    >((ref, params) {
      final api = ref.read(apiServiceProvider);
      return api.getNews(page: params.page, type: params.type);
    });

final newsDetailProvider = FutureProvider.family<NewsArticle, int>((ref, id) {
  return ref.read(apiServiceProvider).getNewsById(id);
});

// ── Photos by type ──
final photosProvider = FutureProvider.family<List<PhotoItem>, String?>((
  ref,
  type,
) {
  return ref.read(apiServiceProvider).getPhotos(type: type);
});

// ── Settings ──
final settingsProvider = FutureProvider<Map<String, dynamic>>((ref) {
  return ref.read(apiServiceProvider).getSettings();
});

// ── Cart ──
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]) {
    _loadFromStorage();
  }

  double get totalPrice => state.fold(0.0, (sum, item) => sum + item.lineTotal);

  int get totalItems => state.fold(0, (sum, item) => sum + item.quantity);

  void addItem(Product product, {int quantity = 1}) {
    final index = state.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      state[index].quantity += quantity;
      state = [...state];
    } else {
      state = [...state, CartItem(product: product, quantity: quantity)];
    }
    _saveToStorage();
  }

  void removeItem(int productId) {
    state = state.where((e) => e.product.id != productId).toList();
    _saveToStorage();
  }

  void updateQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final index = state.indexWhere((e) => e.product.id == productId);
    if (index >= 0) {
      state[index].quantity = quantity;
      state = [...state];
      _saveToStorage();
    }
  }

  void clearCart() {
    state = [];
    _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final data = state.map((item) {
      return <String, dynamic>{
        'productId': item.product.id,
        'quantity': item.quantity,
        'namevi': item.product.namevi,
        'photo': item.product.photo,
        'regular_price': item.product.regularPrice,
        'sale_price': item.product.salePrice,
        'slugvi': item.product.slugvi,
        'code': item.product.code,
      };
    }).toList();
    await prefs.setString('cart', jsonEncode(data));
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final cartJson = prefs.getString('cart');
    if (cartJson == null) return;

    try {
      final List<dynamic> data = jsonDecode(cartJson);
      state = data.map((item) {
        final product = Product(
          id: item['productId'] as int,
          namevi: item['namevi'] as String?,
          photo: item['photo'] as String?,
          regularPrice: (item['regular_price'] as num?)?.toDouble(),
          salePrice: (item['sale_price'] as num?)?.toDouble(),
          slugvi: item['slugvi'] as String?,
          code: item['code'] as String?,
        );
        return CartItem(product: product, quantity: item['quantity'] as int);
      }).toList();
    } catch (_) {
      // Corrupted cart data, reset
      state = [];
    }
  }
}

// ── Favorites ──
final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((
  ref,
) {
  return FavoritesNotifier();
});

class FavoritesNotifier extends StateNotifier<Set<int>> {
  FavoritesNotifier() : super({}) {
    _load();
  }

  bool isFavorite(int productId) => state.contains(productId);

  void toggle(int productId) {
    if (state.contains(productId)) {
      state = {...state}..remove(productId);
    } else {
      state = {...state, productId};
    }
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      state.map((e) => e.toString()).toList(),
    );
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favorites') ?? [];
    state = ids.map((e) => int.tryParse(e) ?? 0).where((e) => e > 0).toSet();
  }
}
