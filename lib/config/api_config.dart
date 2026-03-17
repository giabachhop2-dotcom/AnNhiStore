/// API configuration — points to the existing An Nhi Trà backend
class ApiConfig {
  static const String baseUrl = 'https://annhitra.com';
  static const String apiBase = '$baseUrl/api';

  // ── Public endpoints ──
  static const String products = '$apiBase/products';
  static const String productCategories = '$apiBase/products/categories';
  static String productBySlug(String slug) => '$apiBase/products/slug/$slug';
  static String productById(int id) => '$apiBase/products/$id';

  static const String news = '$apiBase/news';
  static String newsById(int id) => '$apiBase/news/$id';

  static const String photos = '$apiBase/photos';
  static String photosByType(String type) => '$apiBase/photos?type=$type';

  static const String settings = '$apiBase/settings';
  static String pageBySlug(String slug) => '$apiBase/pages/$slug';
  static String resolve(String slug) => '$apiBase/resolve/$slug';

  static const String orders = '$apiBase/orders';
  static const String contacts = '$apiBase/contacts';

  // ── Auth ──
  static const String login = '$apiBase/auth/login';
  static const String register = '$apiBase/auth/register';

  // ── Upload base URLs ──
  static String uploadUrl(String folder, String filename) =>
      '$baseUrl/upload/$folder/$filename';
  static String productImage(String filename) => uploadUrl('product', filename);
  static String newsImage(String filename) => uploadUrl('news', filename);
  static String photoImage(String filename) => uploadUrl('photo', filename);
}
