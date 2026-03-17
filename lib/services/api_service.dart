import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/models.dart';

/// Central API service — wraps all calls to the An Nhi Trà backend
class ApiService {
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.apiBase,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ));
  }

  /// Set auth token for admin/member requests
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ── Products ──

  Future<({List<Product> items, int total, int totalPages})> getProducts({
    int page = 1,
    int limit = 12,
    int? listId,
    int? catId,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (listId != null) params['list'] = listId;
    if (catId != null) params['cat'] = catId;
    if (search != null && search.isNotEmpty) params['search'] = search;

    final res = await _dio.get('/products', queryParameters: params);
    final data = res.data['data'];
    return (
      items: (data['items'] as List).map((e) => Product.fromJson(e)).toList(),
      total: data['total'] as int,
      totalPages: data['totalPages'] as int,
    );
  }

  Future<Product> getProductById(int id) async {
    final res = await _dio.get('/products/$id');
    return Product.fromJson(res.data['data']);
  }

  Future<Product> getProductBySlug(String slug) async {
    final res = await _dio.get('/products/slug/$slug');
    return Product.fromJson(res.data['data']);
  }

  Future<Map<String, dynamic>> getProductCategories() async {
    final res = await _dio.get('/products/categories');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── News ──

  Future<({List<NewsArticle> items, int total})> getNews({
    int page = 1,
    int limit = 10,
    String? type,
  }) async {
    final params = <String, dynamic>{'page': page, 'limit': limit};
    if (type != null) params['type'] = type;

    final res = await _dio.get('/news', queryParameters: params);
    final data = res.data['data'];
    return (
      items: (data['items'] as List).map((e) => NewsArticle.fromJson(e)).toList(),
      total: data['total'] as int,
    );
  }

  Future<NewsArticle> getNewsById(int id) async {
    final res = await _dio.get('/news/$id');
    return NewsArticle.fromJson(res.data['data']);
  }

  // ── Photos ──

  Future<List<PhotoItem>> getPhotos({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;

    final res = await _dio.get('/photos', queryParameters: params);
    final data = res.data['data'] as List;
    return data.map((e) => PhotoItem.fromJson(e)).toList();
  }

  // ── Pages ──

  Future<Map<String, dynamic>> getPageBySlug(String slug) async {
    final res = await _dio.get('/pages/$slug');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Slug resolver ──

  Future<Map<String, dynamic>> resolveSlug(String slug) async {
    final res = await _dio.get('/resolve/$slug');
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Orders ──

  Future<Map<String, dynamic>> createOrder(Order order) async {
    final res = await _dio.post('/orders', data: order.toJson());
    return res.data['data'] as Map<String, dynamic>;
  }

  // ── Contacts ──

  Future<void> sendContact({
    required String fullname,
    required String phone,
    String? email,
    String? content,
  }) async {
    await _dio.post('/contacts', data: {
      'fullname': fullname,
      'phone': phone,
      'email': email ?? '',
      'content': content ?? '',
    });
  }

  // ── Settings ──

  Future<Map<String, dynamic>> getSettings() async {
    final res = await _dio.get('/settings');
    return res.data['data'] as Map<String, dynamic>;
  }

  /// Helper: get image URL from filename
  static String getImageUrl(String? photo, String folder) {
    if (photo == null || photo.isEmpty) return '';
    if (photo.startsWith('http')) return photo;
    return '${ApiConfig.baseUrl}/upload/$folder/$photo';
  }
}
