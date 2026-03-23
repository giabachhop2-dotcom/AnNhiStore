import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// SALES DASHBOARD — For sale staff & admin
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class SalesDashboardScreen extends ConsumerStatefulWidget {
  const SalesDashboardScreen({super.key});

  @override
  ConsumerState<SalesDashboardScreen> createState() =>
      _SalesDashboardScreenState();
}

class _SalesDashboardScreenState extends ConsumerState<SalesDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final auth = ref.read(authProvider);
      final endpoint = auth.isAdmin ? '/sales/dashboard' : '/sales/my-stats';
      final res = await http.get(
        Uri.parse('${ApiConfig.apiBase}$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          if (auth.token != null) 'Authorization': 'Bearer ${auth.token}',
        },
      );
      final body = jsonDecode(res.body);
      if (body['success'] == true) {
        setState(() {
          _data = body['data'];
          _loading = false;
        });
      } else {
        setState(() {
          _error = body['message'] ?? 'Lỗi';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Không thể kết nối máy chủ';
        _loading = false;
      });
    }
  }

  String _fmtMoney(dynamic v) {
    if (v == null || v == 0) return '0đ';
    final n = v is int ? v.toDouble() : (v as double);
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(n);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(auth.isAdmin ? 'Quản lý doanh số' : 'Doanh số cá nhân'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.square_arrow_right, size: 22),
          onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (mounted) context.go('/');
          },
        ),
      ),
      child: SafeArea(
        child: _loading
            ? const Center(child: CupertinoActivityIndicator(radius: 16))
            : _error != null
            ? _buildError()
            : RefreshIndicator(
                onRefresh: _loadStats,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    _buildGreeting(auth),
                    const SizedBox(height: 20),
                    _buildStatCards(),
                    const SizedBox(height: 20),
                    if (auth.isAdmin) _buildStaffBreakdown(),
                    _buildRecentOrders(),
                    const SizedBox(height: 16),
                    _buildCommissionSummary(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildGreeting(AuthState auth) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryDark,
            AppTheme.primaryDark.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Xin chào, ${auth.userName ?? "Nhân viên"}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            auth.isAdmin ? '👑 Quản trị viên' : '📊 Nhân viên tư vấn',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    final overview = _data?['overview'] as Map<String, dynamic>? ?? {};
    final isAdmin = ref.read(authProvider).isAdmin;

    // Admin: today/week/month/total | Sale: totalOrders/monthOrders/totalRevenue/monthRevenue
    final List<_StatInfo> stats;
    if (isAdmin) {
      final today = overview['today'] as Map<String, dynamic>? ?? {};
      final week = overview['week'] as Map<String, dynamic>? ?? {};
      final month = overview['month'] as Map<String, dynamic>? ?? {};
      final total = overview['total'] as Map<String, dynamic>? ?? {};
      stats = [
        _StatInfo(
          'Hôm nay',
          _fmtMoney(today['revenue']),
          '${today['orders'] ?? 0} đơn',
          CupertinoIcons.calendar_today,
          const Color(0xFF2E7D32),
        ),
        _StatInfo(
          'Tuần này',
          _fmtMoney(week['revenue']),
          '${week['orders'] ?? 0} đơn',
          CupertinoIcons.calendar,
          const Color(0xFF1565C0),
        ),
        _StatInfo(
          'Tháng này',
          _fmtMoney(month['revenue']),
          '${month['orders'] ?? 0} đơn',
          CupertinoIcons.chart_bar_alt_fill,
          const Color(0xFFE65100),
        ),
        _StatInfo(
          'Tổng cộng',
          _fmtMoney(total['revenue']),
          '${total['orders'] ?? 0} đơn',
          CupertinoIcons.chart_pie,
          const Color(0xFF7B1FA2),
        ),
      ];
    } else {
      stats = [
        _StatInfo(
          'Tổng đơn',
          '${overview['totalOrders'] ?? 0}',
          'đơn hàng',
          CupertinoIcons.cart,
          const Color(0xFF2E7D32),
        ),
        _StatInfo(
          'Tháng này',
          '${overview['monthOrders'] ?? 0}',
          'đơn hàng',
          CupertinoIcons.calendar,
          const Color(0xFF1565C0),
        ),
        _StatInfo(
          'Doanh thu',
          _fmtMoney(overview['totalRevenue']),
          'tổng',
          CupertinoIcons.money_dollar_circle,
          const Color(0xFFE65100),
        ),
        _StatInfo(
          'Hoa hồng',
          _fmtMoney(overview['totalCommission']),
          '${_fmtMoney(overview['pendingCommission'])} chờ',
          CupertinoIcons.star_fill,
          const Color(0xFFC8A96E),
        ),
      ];
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: stats.map((s) => _buildStatCard(s)).toList(),
    );
  }

  Widget _buildStatCard(_StatInfo info) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(info.icon, size: 16, color: info.color),
              const SizedBox(width: 6),
              Text(
                info.label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          Text(
            info.value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            info.sub,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaffBreakdown() {
    final breakdown = (_data?['staffBreakdown'] as List?) ?? [];
    if (breakdown.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            '🏆 Bảng xếp hạng nhân viên',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        ...breakdown.map<Widget>((s) {
          final maxTotal = breakdown.fold<num>(
            0,
            (m, e) => (e['total'] as num) > m ? e['total'] as num : m,
          );
          final pct = maxTotal > 0 ? ((s['total'] as num) / maxTotal) : 0.0;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Text(
                      '${s['count']} đơn',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fmtMoney(s['total']),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFC8A96E),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct.toDouble(),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFC8A96E)),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildRecentOrders() {
    final orders = (_data?['recentOrders'] as List?) ?? [];
    if (orders.isEmpty) {
      return _buildEmptySection('Chưa có đơn hàng nào');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            '📋 Đơn hàng gần đây',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        ...orders.take(10).map<Widget>((o) {
          final status = o['order_status'] as int? ?? 0;
          final statusLabels = [
            'Mới',
            'Xác nhận',
            'Giao hàng',
            'Hoàn thành',
            'Hủy',
          ];
          final statusColors = [
            Colors.orange,
            Colors.blue,
            Colors.purple,
            Colors.green,
            Colors.red,
          ];
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${o['code'] ?? o['id']}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        o['fullname'] ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColors[status.clamp(0, 4)].withValues(
                      alpha: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabels[status.clamp(0, 4)],
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: statusColors[status.clamp(0, 4)],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmtMoney(o['total_price']),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFC8A96E),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildCommissionSummary() {
    final commissions = (_data?['recentCommissions'] as List?) ?? [];
    if (commissions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: Text(
            '💰 Hoa hồng gần đây',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        ...commissions.take(10).map<Widget>((c) {
          final status = c['status'] as String? ?? 'pending';
          final statusMap = {
            'pending': ('Chờ', Colors.orange),
            'approved': ('Duyệt', Colors.blue),
            'paid': ('Đã chi', Colors.green),
            'rejected': ('Từ chối', Colors.red),
          };
          final (label, color) = statusMap[status] ?? ('?', Colors.grey);
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.darkSurface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c['product_name'] ?? 'Đơn #${c['id_order']}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${c['commission_rate']}% × ${_fmtMoney(c['order_total'])}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _fmtMoney(c['commission_amount']),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFC8A96E),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildEmptySection(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.4),
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.exclamationmark_triangle,
            size: 48,
            color: Colors.white.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            _error ?? 'Lỗi',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 16),
          CupertinoButton.filled(
            onPressed: _loadStats,
            child: const Text('Thử lại'),
          ),
        ],
      ),
    );
  }
}

class _StatInfo {
  final String label;
  final String value;
  final String sub;
  final IconData icon;
  final Color color;
  const _StatInfo(this.label, this.value, this.sub, this.icon, this.color);
}
