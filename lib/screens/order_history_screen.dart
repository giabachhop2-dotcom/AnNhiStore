import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/theme.dart';
import '../widgets/empty_state.dart';

/// Order history screen — reads saved orders from SharedPreferences.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('order_history');
    if (raw != null) {
      try {
        final List<dynamic> data = jsonDecode(raw);
        setState(() {
          _orders = data.cast<Map<String, dynamic>>().reversed.toList();
          _isLoading = false;
        });
      } catch (_) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  /// Call this statically to save an order from checkout_screen
  static Future<void> saveOrder({
    required String code,
    required double total,
    required int itemCount,
    required String customerName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('order_history');
    List<dynamic> orders = [];
    if (raw != null) {
      try {
        orders = jsonDecode(raw);
      } catch (_) {}
    }
    orders.add({
      'code': code,
      'total': total,
      'itemCount': itemCount,
      'customerName': customerName,
      'date': DateTime.now().toIso8601String(),
      'status': 'Đang xử lý',
    });
    await prefs.setString('order_history', jsonEncode(orders));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Lịch sử đơn hàng'),
      ),
      child: _isLoading
          ? const Center(child: CupertinoActivityIndicator(radius: 14))
          : _orders.isEmpty
              ? const EmptyState(
                  icon: CupertinoIcons.cube_box,
                  title: 'Chưa có đơn hàng',
                  description: 'Đơn hàng của bạn sẽ hiển thị tại đây sau khi đặt',
                )
              : ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final date = DateTime.tryParse(order['date'] ?? '');
                    final total = (order['total'] as num?)?.toDouble() ?? 0;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: CupertinoColors.systemBackground.resolveFrom(context),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.separator.withValues(alpha: 0.15),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '#${order['code'] ?? 'N/A'}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentGold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  order['status'] ?? 'Đang xử lý',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.accentGold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          // Details
                          Row(
                            children: [
                              const Icon(CupertinoIcons.calendar,
                                  size: 14, color: AppTheme.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                date != null
                                    ? DateFormat('dd/MM/yyyy HH:mm').format(date)
                                    : 'N/A',
                                style: const TextStyle(
                                    fontSize: 13, color: AppTheme.textMuted),
                              ),
                              const Spacer(),
                              Text(
                                '${order['itemCount'] ?? 0} sản phẩm',
                                style: const TextStyle(
                                    fontSize: 13, color: AppTheme.textMuted),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Total
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                order['customerName'] ?? '',
                                style: const TextStyle(
                                    fontSize: 14, color: AppTheme.textPrimary),
                              ),
                              total > 0
                                  ? Text(
                                      formatter.format(total),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.priceRed,
                                      ),
                                    )
                                  : const Text('Liên hệ',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: AppTheme.accentGold,
                                        fontStyle: FontStyle.italic,
                                      )),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
