import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ══════════════════════════════════════════════════
// APP LOCALIZATIONS — Simple map-based VI/EN i18n
// ══════════════════════════════════════════════════

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  String get(String key) {
    final map = locale.languageCode == 'vi' ? _vi : _en;
    return map[key] ?? _vi[key] ?? key;
  }

  // ── Vietnamese (default) ──
  static const Map<String, String> _vi = {
    // Navigation
    'nav_home': 'Trang chủ',
    'nav_products': 'Sản phẩm',
    'nav_news': 'Bài viết',
    'nav_cart': 'Giỏ hàng',
    'nav_more': 'Khác',

    // Auth
    'login': 'Đăng nhập',
    'register': 'Đăng ký',
    'logout': 'Đăng xuất',
    'username': 'Tên đăng nhập',
    'password': 'Mật khẩu',
    'fullname': 'Họ và tên',
    'phone': 'Số điện thoại',
    'email': 'Email',
    'login_success': 'Đăng nhập thành công!',
    'register_success': 'Đăng ký thành công!',

    // Checkout
    'checkout': 'Thanh Toán',
    'order_summary': 'Đơn hàng',
    'total': 'Tổng cộng',
    'delivery_info': 'Thông tin giao hàng',
    'address': 'Địa chỉ giao hàng',
    'note': 'Ghi chú',
    'salesperson_section': 'Nhân viên tư vấn',
    'salesperson_code': 'Mã nhân viên (nếu có)',
    'payment_method': 'Phương thức thanh toán',
    'cod': 'Thanh toán khi nhận hàng (COD)',
    'bank_transfer': 'Chuyển khoản ngân hàng (QR)',
    'confirm_order': 'Xác nhận đặt hàng',
    'order_success': 'Đặt hàng thành công!',
    'order_code': 'Mã đơn',
    'order_confirm_msg': 'Chúng tôi sẽ liên hệ xác nhận sớm nhất.',
    'scan_qr': 'Quét mã QR để chuyển khoản',
    'back_home': 'Về trang chủ',

    // Product
    'add_to_cart': 'Thêm vào giỏ',
    'buy_now': 'Mua ngay',
    'description': 'Mô tả',
    'reviews': 'Đánh giá',
    'related_products': 'Sản phẩm liên quan',
    'search': 'Tìm kiếm',
    'no_products': 'Không có sản phẩm nào',

    // More screen
    'about': 'Giới thiệu',
    'contact': 'Liên hệ',
    'favorites': 'Yêu thích',
    'order_history': 'Lịch sử đơn hàng',
    'tea_timer': 'Hẹn giờ pha trà',
    'tea_compare': 'So sánh trà',
    'tea_table': 'Bàn trà',
    'events': 'Sự kiện',
    'settings': 'Cài đặt',
    'language': 'Ngôn ngữ',
    'notifications': 'Thông báo',
    'share_app': 'Chia sẻ ứng dụng',

    // Common
    'loading': 'Đang tải...',
    'retry': 'Thử lại',
    'error': 'Có lỗi xảy ra',
    'empty': 'Chưa có dữ liệu',
    'cancel': 'Hủy',
    'ok': 'OK',
    'save': 'Lưu',
    'delete': 'Xóa',
    'edit': 'Sửa',
    'close': 'Đóng',

    // Sales
    'sales_dashboard': 'Doanh số',
    'today': 'Hôm nay',
    'this_week': 'Tuần này',
    'this_month': 'Tháng này',
    'total_all': 'Tổng cộng',
    'orders': 'đơn hàng',
    'commission': 'Hoa hồng',
    'pending': 'Chờ duyệt',
    'staff_ranking': 'Bảng xếp hạng nhân viên',
    'recent_orders': 'Đơn hàng gần đây',
    'recent_commissions': 'Hoa hồng gần đây',
  };

  // ── English ──
  static const Map<String, String> _en = {
    'nav_home': 'Home',
    'nav_products': 'Products',
    'nav_news': 'News',
    'nav_cart': 'Cart',
    'nav_more': 'More',

    'login': 'Login',
    'register': 'Register',
    'logout': 'Logout',
    'username': 'Username',
    'password': 'Password',
    'fullname': 'Full name',
    'phone': 'Phone number',
    'email': 'Email',
    'login_success': 'Login successful!',
    'register_success': 'Registration successful!',

    'checkout': 'Checkout',
    'order_summary': 'Order Summary',
    'total': 'Total',
    'delivery_info': 'Delivery Information',
    'address': 'Delivery address',
    'note': 'Note',
    'salesperson_section': 'Sales Consultant',
    'salesperson_code': 'Staff code (if any)',
    'payment_method': 'Payment Method',
    'cod': 'Cash on Delivery (COD)',
    'bank_transfer': 'Bank Transfer (QR)',
    'confirm_order': 'Confirm Order',
    'order_success': 'Order Placed Successfully!',
    'order_code': 'Order Code',
    'order_confirm_msg': 'We will contact you shortly to confirm.',
    'scan_qr': 'Scan QR code to transfer',
    'back_home': 'Back to Home',

    'add_to_cart': 'Add to Cart',
    'buy_now': 'Buy Now',
    'description': 'Description',
    'reviews': 'Reviews',
    'related_products': 'Related Products',
    'search': 'Search',
    'no_products': 'No products found',

    'about': 'About Us',
    'contact': 'Contact',
    'favorites': 'Favorites',
    'order_history': 'Order History',
    'tea_timer': 'Tea Timer',
    'tea_compare': 'Tea Comparison',
    'tea_table': 'Tea Table',
    'events': 'Events',
    'settings': 'Settings',
    'language': 'Language',
    'notifications': 'Notifications',
    'share_app': 'Share App',

    'loading': 'Loading...',
    'retry': 'Retry',
    'error': 'An error occurred',
    'empty': 'No data yet',
    'cancel': 'Cancel',
    'ok': 'OK',
    'save': 'Save',
    'delete': 'Delete',
    'edit': 'Edit',
    'close': 'Close',

    'sales_dashboard': 'Sales Dashboard',
    'today': 'Today',
    'this_week': 'This Week',
    'this_month': 'This Month',
    'total_all': 'Total',
    'orders': 'orders',
    'commission': 'Commission',
    'pending': 'Pending',
    'staff_ranking': 'Staff Ranking',
    'recent_orders': 'Recent Orders',
    'recent_commissions': 'Recent Commissions',
  };
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['vi', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// ── Locale Provider ──

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('vi')) {
    _load();
  }

  void setLocale(Locale locale) {
    state = locale;
    _save();
  }

  void toggleLocale() {
    state = state.languageCode == 'vi'
        ? const Locale('en')
        : const Locale('vi');
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_locale', state.languageCode);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('app_locale') ?? 'vi';
    state = Locale(code);
  }
}
