import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../config/theme.dart';
import '../widgets/premium_widgets.dart';
import '../widgets/tea_leaf_celebration.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  int paymentMethod = 0;
  bool isSubmitting = false;
  bool orderSuccess = false;
  String? orderCode;
  double? orderTotal;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty || _addressCtrl.text.trim().isEmpty) {
      _showAlert('Thiếu thông tin', 'Vui lòng nhập đầy đủ họ tên, SĐT và địa chỉ.');
      return;
    }

    // Vietnamese phone validation
    final phone = _phoneCtrl.text.trim();
    if (!RegExp(r'^0[0-9]{9}$').hasMatch(phone)) {
      _showAlert('Số điện thoại không hợp lệ', 'Vui lòng nhập SĐT 10 số bắt đầu bằng 0.');
      return;
    }

    HapticFeedback.mediumImpact();
    final cartNotifier = ref.read(cartProvider.notifier);
    final cart = ref.read(cartProvider);
    final api = ref.read(apiServiceProvider);

    setState(() => isSubmitting = true);

    try {
      final total = cartNotifier.totalPrice;
      final order = Order(
        fullname: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        requirements: _noteCtrl.text.trim(),
        tempPrice: total,
        totalPrice: total,
        orderPayment: paymentMethod,
        items: cart.map((item) => OrderItem(
          idProduct: item.product.id,
          name: item.product.namevi ?? '',
          photo: item.product.photo,
          code: item.product.code,
          regularPrice: item.product.regularPrice ?? 0,
          salePrice: item.product.salePrice ?? 0,
          quantity: item.quantity,
        )).toList(),
      );

      final result = await api.createOrder(order);
      cartNotifier.clearCart();
      HapticFeedback.heavyImpact();

      // Save to order history
      await saveOrderToHistory(
        code: (result['code'] as String?) ?? '',
        total: total,
        itemCount: cart.length,
        customerName: _nameCtrl.text.trim(),
      );

      if (mounted) {
        setState(() {
          orderSuccess = true;
          orderCode = result['code'] as String?;
          orderTotal = total;
          isSubmitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isSubmitting = false);
        _showAlert('Lỗi đặt hàng', 'Không thể kết nối máy chủ. Vui lòng kiểm tra kết nối mạng và thử lại.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    if (orderSuccess) return PopScope(canPop: false, child: TeaLeafCelebration(showCelebration: true, child: _buildSuccess(formatter)));

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Thanh Toán')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Order summary (iOS grouped style)
            _buildSection('Đơn hàng', [
              ...cart.map((item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text('${item.product.namevi} ×${item.quantity}',
                          style: const TextStyle(fontSize: 14)),
                    ),
                    Text(formatter.format(item.lineTotal),
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  ],
                ),
              )),
              const Divider(),
              Row(
                children: [
                  const Expanded(child: Text('Tổng cộng:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                  Text(formatter.format(cartNotifier.totalPrice),
                      style: const TextStyle(color: AppTheme.priceRed, fontWeight: FontWeight.bold, fontSize: 18)),
                ],
              ),
            ]),

            const SizedBox(height: 16),

            // Customer info (iOS form style)
            _buildSection('Thông tin giao hàng', [
              _IosTextField(controller: _nameCtrl, placeholder: 'Họ và tên *', icon: CupertinoIcons.person),
              _IosTextField(controller: _phoneCtrl, placeholder: 'Số điện thoại *', icon: CupertinoIcons.phone, keyboardType: TextInputType.phone),
              _IosTextField(controller: _emailCtrl, placeholder: 'Email', icon: CupertinoIcons.mail, keyboardType: TextInputType.emailAddress),
              _IosTextField(controller: _addressCtrl, placeholder: 'Địa chỉ giao hàng *', icon: CupertinoIcons.location),
              _IosTextField(controller: _noteCtrl, placeholder: 'Ghi chú', icon: CupertinoIcons.text_badge_plus, maxLines: 3),
            ]),

            const SizedBox(height: 16),

            // Payment method
            _buildSection('Phương thức thanh toán', [
              _PaymentOption(
                value: 0,
                groupValue: paymentMethod,
                icon: CupertinoIcons.money_dollar_circle,
                title: 'Thanh toán khi nhận hàng (COD)',
                onChanged: (v) => setState(() => paymentMethod = v!),
              ),
              _PaymentOption(
                value: 1,
                groupValue: paymentMethod,
                icon: CupertinoIcons.qrcode,
                title: 'Chuyển khoản ngân hàng (QR)',
                onChanged: (v) => setState(() => paymentMethod = v!),
              ),
            ]),

            const SizedBox(height: 24),

            GoldCTAButton(
              label: 'Xác nhận đặt hàng',
              icon: CupertinoIcons.checkmark_seal,
              isLoading: isSubmitting,
              onPressed: isSubmitting ? null : _submit,
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(NumberFormat formatter) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Đặt hàng thành công')),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              // Animated check with pulse ring
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Pulse ring
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (_, value, __) => Container(
                        width: 90 + (value * 40),
                        height: 90 + (value * 40),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.primaryDark.withValues(alpha: 0.3 * (1 - value)),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    // Checkmark bounce
                    TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0.0, end: 1.0),
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.elasticOut,
                      builder: (_, value, __) => Transform.scale(
                        scale: value,
                        child: Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryDark,
                                AppTheme.primaryDark.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryDark.withValues(alpha: 0.3),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(CupertinoIcons.checkmark_alt,
                              size: 45, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text('Đặt hàng thành công!',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              Text('Mã đơn: ${orderCode ?? ""}',
                  style: const TextStyle(fontSize: 17, color: AppTheme.accentGold, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text('Chúng tôi sẽ liên hệ xác nhận sớm nhất.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textMuted)),

              // QR Code for bank transfer
              if (paymentMethod == 1 && orderTotal != null) ...[
                const SizedBox(height: 28),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: CupertinoColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 12),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Text('Quét mã QR để chuyển khoản',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 12),
                      QrImageView(
                        data: 'https://annhitra.com/pay?code=$orderCode&amount=${orderTotal!.toInt()}',
                        version: QrVersions.auto,
                        size: 200,
                        backgroundColor: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formatter.format(orderTotal),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.priceRed),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              CupertinoButton.filled(
                onPressed: () => context.go('/'),
                child: const Text('Về trang chủ'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(title.toUpperCase(),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted, letterSpacing: 0.5)),
        ),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  void _showAlert(String title, String content) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }
}

class _IosTextField extends StatelessWidget {
  final TextEditingController controller;
  final String placeholder;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  const _IosTextField({
    required this.controller,
    required this.placeholder,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: CupertinoTextField(
        controller: controller,
        placeholder: placeholder,
        prefix: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Icon(icon, size: 18, color: AppTheme.textMuted),
        ),
        keyboardType: keyboardType,
        maxLines: maxLines,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.groupedBg,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final int value;
  final int groupValue;
  final IconData icon;
  final String title;
  final ValueChanged<int?> onChanged;

  const _PaymentOption({
    required this.value,
    required this.groupValue,
    required this.icon,
    required this.title,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: () {
        HapticFeedback.selectionClick();
        onChanged(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 22, color: selected ? AppTheme.primaryDark : AppTheme.textMuted),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title,
                  style: TextStyle(
                    fontSize: 15,
                    color: selected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  )),
            ),
            Icon(
              selected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
              color: selected ? AppTheme.primaryDark : AppTheme.textMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
