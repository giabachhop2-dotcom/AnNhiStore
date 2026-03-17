import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// TEA COMPARISON — Compare two teas side by side
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeaComparisonScreen extends StatefulWidget {
  const TeaComparisonScreen({super.key});

  @override
  State<TeaComparisonScreen> createState() => _TeaComparisonScreenState();
}

class _TeaComparisonScreenState extends State<TeaComparisonScreen> {
  int _leftIndex = 0;
  int _rightIndex = 1;

  static const _teas = [
    _TeaProfile(
      name: 'Trà Shan Tuyết',
      emoji: '🏔️',
      origin: 'Hà Giang',
      taste: 4, aroma: 5, body: 4, sweetAfter: 5, caffeine: 3,
      temp: '85-90°C', brewTime: '3 phút',
      notes: 'Ngọt hậu, hương rừng, vị đậm đà',
      priceRange: '350.000 - 800.000₫',
    ),
    _TeaProfile(
      name: 'Hồng Trà',
      emoji: '🔴',
      origin: 'Yên Bái',
      taste: 3, aroma: 4, body: 5, sweetAfter: 3, caffeine: 4,
      temp: '90-95°C', brewTime: '3:30 phút',
      notes: 'Chát ngọt, mùi mật ong, nước đỏ hổ phách',
      priceRange: '280.000 - 600.000₫',
    ),
    _TeaProfile(
      name: 'Trà Ô Long',
      emoji: '🫖',
      origin: 'Sơn La',
      taste: 3, aroma: 5, body: 3, sweetAfter: 4, caffeine: 3,
      temp: '90-95°C', brewTime: '4 phút',
      notes: 'Hương hoa lan, nhiều lần hãm, biến đổi hương vị',
      priceRange: '400.000 - 1.200.000₫',
    ),
    _TeaProfile(
      name: 'Phổ Nhĩ Chín',
      emoji: '🟤',
      origin: 'Hà Giang',
      taste: 5, aroma: 3, body: 5, sweetAfter: 3, caffeine: 5,
      temp: '95-100°C', brewTime: '5 phút',
      notes: 'Vị đất, mùn, ngọt nhẹ. Càng lâu năm càng quý',
      priceRange: '500.000 - 2.000.000₫',
    ),
    _TeaProfile(
      name: 'Bạch Trà',
      emoji: '⚪',
      origin: 'Hà Giang',
      taste: 2, aroma: 4, body: 2, sweetAfter: 5, caffeine: 2,
      temp: '65-75°C', brewTime: '1:30 phút',
      notes: 'Nhẹ nhàng, thanh tao, ngọt tinh tế',
      priceRange: '450.000 - 1.500.000₫',
    ),
    _TeaProfile(
      name: 'Trà Xanh',
      emoji: '🍃',
      origin: 'Thái Nguyên',
      taste: 3, aroma: 3, body: 3, sweetAfter: 3, caffeine: 3,
      temp: '70-80°C', brewTime: '2 phút',
      notes: 'Thanh mát, chát nhẹ, quen thuộc hàng ngày',
      priceRange: '150.000 - 400.000₫',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    final left = _teas[_leftIndex];
    final right = _teas[_rightIndex];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('So Sánh Trà'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Selectors
              Row(
                children: [
                  Expanded(child: _TeaSelector(
                    teas: _teas,
                    selectedIndex: _leftIndex,
                    onChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _leftIndex = i);
                    },
                    isDark: isDark,
                    color: const Color(0xFF4A7C5C),
                  )),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('VS', style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppTheme.accentGold,
                    )),
                  ),
                  Expanded(child: _TeaSelector(
                    teas: _teas,
                    selectedIndex: _rightIndex,
                    onChanged: (i) {
                      HapticFeedback.selectionClick();
                      setState(() => _rightIndex = i);
                    },
                    isDark: isDark,
                    color: const Color(0xFFB8860B),
                  )),
                ],
              ),

              const SizedBox(height: 20),

              // Radar comparison bars
              _CompareRow('Vị đậm', left.taste, right.taste, isDark),
              _CompareRow('Hương', left.aroma, right.aroma, isDark),
              _CompareRow('Body', left.body, right.body, isDark),
              _CompareRow('Ngọt hậu', left.sweetAfter, right.sweetAfter, isDark),
              _CompareRow('Caffeine', left.caffeine, right.caffeine, isDark),

              const SizedBox(height: 20),

              // Details
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _DetailColumn(tea: left, isDark: isDark)),
                  const SizedBox(width: 12),
                  Expanded(child: _DetailColumn(tea: right, isDark: isDark)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeaProfile {
  final String name, emoji, origin, notes, priceRange, temp, brewTime;
  final int taste, aroma, body, sweetAfter, caffeine;
  const _TeaProfile({
    required this.name, required this.emoji, required this.origin,
    required this.taste, required this.aroma, required this.body,
    required this.sweetAfter, required this.caffeine,
    required this.temp, required this.brewTime,
    required this.notes, required this.priceRange,
  });
}

class _TeaSelector extends StatelessWidget {
  final List<_TeaProfile> teas;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool isDark;
  final Color color;

  const _TeaSelector({
    required this.teas, required this.selectedIndex,
    required this.onChanged, required this.isDark, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tea = teas[selectedIndex];
    return GestureDetector(
      onTap: () {
        showCupertinoModalPopup(
          context: context,
          builder: (_) => CupertinoActionSheet(
            title: const Text('Chọn loại trà'),
            actions: List.generate(teas.length, (i) =>
              CupertinoActionSheetAction(
                onPressed: () { onChanged(i); Navigator.pop(context); },
                child: Text('${teas[i].emoji} ${teas[i].name}'),
              ),
            ),
            cancelButton: CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
              blurRadius: 8, offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(tea.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 6),
            Text(tea.name, style: TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            )),
            Text(tea.origin, style: TextStyle(
              fontSize: 12,
              color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
            )),
            const SizedBox(height: 4),
            Icon(CupertinoIcons.chevron_down, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}

class _CompareRow extends StatelessWidget {
  final String label;
  final int leftVal, rightVal;
  final bool isDark;
  const _CompareRow(this.label, this.leftVal, this.rightVal, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Left bar
          Expanded(
            child: Row(
              children: [
                const Spacer(),
                ...List.generate(5, (i) => Container(
                  width: 20, height: 10,
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  decoration: BoxDecoration(
                    color: i < leftVal
                        ? const Color(0xFF4A7C5C)
                        : (isDark ? AppTheme.darkSeparator : AppTheme.separator.withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(3),
                  ),
                )),
              ],
            ),
          ),
          // Label
          SizedBox(
            width: 70,
            child: Text(label, textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w500,
                  color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
                )),
          ),
          // Right bar
          Expanded(
            child: Row(
              children: List.generate(5, (i) => Container(
                width: 20, height: 10,
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: i < rightVal
                      ? const Color(0xFFB8860B)
                      : (isDark ? AppTheme.darkSeparator : AppTheme.separator.withValues(alpha: 0.2)),
                  borderRadius: BorderRadius.circular(3),
                ),
              )),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final _TeaProfile tea;
  final bool isDark;
  const _DetailColumn({required this.tea, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DetailRow(CupertinoIcons.thermometer, tea.temp, isDark),
          _DetailRow(CupertinoIcons.timer, tea.brewTime, isDark),
          _DetailRow(CupertinoIcons.tag, tea.priceRange, isDark),
          const SizedBox(height: 6),
          Text(tea.notes, style: TextStyle(
            fontSize: 12, fontStyle: FontStyle.italic,
            color: isDark ? AppTheme.darkTextSecondary : AppTheme.textMuted,
          )),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _DetailRow(this.icon, this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(icon, size: 13, color: AppTheme.accentGold),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(
            fontSize: 13,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ))),
        ],
      ),
    );
  }
}
