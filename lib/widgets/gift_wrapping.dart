import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// GIFT WRAPPING — Premium gift option for checkout
/// Select wrapping style, add message, enter recipient.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class GiftWrappingSection extends StatefulWidget {
  final ValueChanged<GiftOptions?> onChanged;

  const GiftWrappingSection({super.key, required this.onChanged});

  @override
  State<GiftWrappingSection> createState() => _GiftWrappingSectionState();
}

class _GiftWrappingSectionState extends State<GiftWrappingSection> {
  bool _isGift = false;
  int _wrapStyleIndex = 0;
  final _messageCtrl = TextEditingController();
  final _recipientCtrl = TextEditingController();
  final _recipientPhoneCtrl = TextEditingController();

  static const _wrapStyles = [
    _WrapStyle('Hộp gỗ trà đạo', '🎁', 0, 'Hộp gỗ thông khắc chữ, lót lụa đỏ'),
    _WrapStyle('Túi vải thổ cẩm', '🧧', 50000, 'Túi vải dệt tay H\'Mông, thắt nơ'),
    _WrapStyle('Hộp quà VIP', '👑', 120000, 'Hộp sơn mài, lót nhung, kèm thiệp'),
  ];

  void _notifyChange() {
    if (!_isGift) {
      widget.onChanged(null);
      return;
    }
    widget.onChanged(GiftOptions(
      wrapStyle: _wrapStyles[_wrapStyleIndex],
      message: _messageCtrl.text,
      recipientName: _recipientCtrl.text,
      recipientPhone: _recipientPhoneCtrl.text,
    ));
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _recipientCtrl.dispose();
    _recipientPhoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: _isGift
            ? Border.all(
                color: AppTheme.accentGold.withValues(alpha: 0.3), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Toggle
          CupertinoListTile(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            leading: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A830), Color(0xFFB8860B)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(CupertinoIcons.gift, size: 18, color: Colors.white),
            ),
            title: const Text('Gói quà & Gửi tặng',
                style: TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(
              _isGift ? 'Đang bật — chọn kiểu gói bên dưới' : 'Tặng người thân, bạn bè',
              style: TextStyle(fontSize: 12, color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted),
            ),
            trailing: CupertinoSwitch(
              value: _isGift,
              activeTrackColor: AppTheme.accentGold,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _isGift = v);
                _notifyChange();
              },
            ),
          ),

          // Gift options
          if (_isGift) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Wrap style selection
                  Text('Kiểu gói',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 10),
                  ...List.generate(_wrapStyles.length, (i) {
                    final ws = _wrapStyles[i];
                    final selected = i == _wrapStyleIndex;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _wrapStyleIndex = i);
                        _notifyChange();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? (isDark
                                  ? AppTheme.accentGold.withValues(alpha: 0.1)
                                  : const Color(0xFFFFF8E8))
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppTheme.accentGold.withValues(alpha: 0.5)
                                : (isDark
                                    ? AppTheme.darkSeparator
                                    : AppTheme.separator
                                        .withValues(alpha: 0.15)),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(ws.emoji, style: const TextStyle(fontSize: 24)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(ws.name,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: isDark
                                            ? AppTheme.darkTextPrimary
                                            : AppTheme.textPrimary,
                                      )),
                                  Text(ws.description,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark
                                            ? AppTheme.darkTextSecondary
                                            : AppTheme.textMuted,
                                      )),
                                ],
                              ),
                            ),
                            Text(
                              ws.price == 0 ? 'Miễn phí' : '+${_formatPrice(ws.price)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ws.price == 0
                                    ? const Color(0xFF4A7C5C)
                                    : AppTheme.accentGold,
                              ),
                            ),
                            if (selected) ...[
                              const SizedBox(width: 8),
                              const Icon(CupertinoIcons.checkmark_circle_fill,
                                  size: 18, color: AppTheme.accentGold),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 16),

                  // Recipient info
                  Text('Người nhận quà',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _recipientCtrl,
                    placeholder: 'Tên người nhận',
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onChanged: (_) => _notifyChange(),
                  ),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _recipientPhoneCtrl,
                    placeholder: 'SĐT người nhận',
                    keyboardType: TextInputType.phone,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onChanged: (_) => _notifyChange(),
                  ),

                  const SizedBox(height: 16),

                  // Gift message
                  Text('Lời nhắn tặng',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 8),
                  CupertinoTextField(
                    controller: _messageCtrl,
                    placeholder: 'VD: Chúc anh/chị thưởng trà vui vẻ! 🍵',
                    maxLines: 3,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppTheme.darkSurface : AppTheme.groupedBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    onChanged: (_) => _notifyChange(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatPrice(int price) {
    return '${(price / 1000).toStringAsFixed(0)}.000₫';
  }
}

// ── Models ──
class _WrapStyle {
  final String name, emoji, description;
  final int price;
  const _WrapStyle(this.name, this.emoji, this.price, this.description);
}

class GiftOptions {
  final _WrapStyle wrapStyle;
  final String message, recipientName, recipientPhone;
  const GiftOptions({
    required this.wrapStyle,
    required this.message,
    required this.recipientName,
    required this.recipientPhone,
  });
  int get wrapPrice => wrapStyle.price;
}
