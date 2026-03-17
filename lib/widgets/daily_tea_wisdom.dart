import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// DAILY TEA WISDOM — Rotating insightful quotes
/// Changes each day, unique to An Nhi Trà.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class DailyTeaWisdom extends StatelessWidget {
  const DailyTeaWisdom({super.key});

  static const _wisdoms = [
    _TeaWisdom(
      quote: 'Trà ngon phải có bạn hiền, nước trong phải đợi trăng lên mới mời.',
      source: 'Ca dao Việt Nam',
      emoji: '🌙',
    ),
    _TeaWisdom(
      quote: 'Pha trà không phải rót nước — mà là rót cả tâm tình.',
      source: 'Nghệ nhân trà đạo',
      emoji: '🫖',
    ),
    _TeaWisdom(
      quote: 'Mỗi ấm tử sa mang một câu chuyện — từ lửa, từ đất, từ tay người.',
      source: 'Nghi Hưng, Giang Tô',
      emoji: '🏺',
    ),
    _TeaWisdom(
      quote: 'Nước sôi 100 độ, nhưng pha trà xanh chỉ cần 75 — như cuộc sống, không phải lúc nào cũng cần nóng vội.',
      source: 'Triết lý trà đạo',
      emoji: '🌿',
    ),
    _TeaWisdom(
      quote: 'Uống trà buổi sáng, thần sảng khoái; uống trà buổi tối, tâm an nhiên.',
      source: 'Truyền thống Đông phương',
      emoji: '☀️',
    ),
    _TeaWisdom(
      quote: 'Trà shan tuyết 300 tuổi chỉ cho lá mỗi năm một lần — vì thế mà quý.',
      source: 'Hà Giang, Việt Nam',
      emoji: '🏔️',
    ),
    _TeaWisdom(
      quote: 'Ấm tử sa càng dùng càng bóng — vì nó hấp thu tinh hoa từ mỗi ấm trà.',
      source: 'Bí ẩn tử sa',
      emoji: '✨',
    ),
    _TeaWisdom(
      quote: 'Trà không phân biệt sang hèn — chỉ phân biệt ai biết thưởng thức.',
      source: 'Tinh thần trà Việt',
      emoji: '🍃',
    ),
    _TeaWisdom(
      quote: 'Một chén trà, một cuốn sách, một buổi chiều — đó là xa xỉ thật sự.',
      source: 'Phong cách An Nhi',
      emoji: '📖',
    ),
    _TeaWisdom(
      quote: 'Khi đất tử sa gặp ngọn lửa, nó trở thành bất tử.',
      source: 'Nghệ nhân Đại sư',
      emoji: '🔥',
    ),
    _TeaWisdom(
      quote: 'Từng ngụm trà là từng khoảnh khắc chánh niệm — hít vào hương thơm, thở ra thanh thản.',
      source: 'Thiền trà',
      emoji: '🧘',
    ),
    _TeaWisdom(
      quote: 'Không gian thưởng trà không cần lớn, chỉ cần đủ tĩnh.',
      source: 'Nghệ thuật trà thất',
      emoji: '🏡',
    ),
    _TeaWisdom(
      quote: 'Trà phổ nhĩ như rượu vang — càng lâu năm càng đắt giá.',
      source: 'Vân Nam, Trung Quốc',
      emoji: '🟤',
    ),
    _TeaWisdom(
      quote: 'Rót trà từ cao xuống thấp để vỡ bọt — đó là lễ nghi, không phải mẹo.',
      source: 'Trà đạo Trung Hoa',
      emoji: '💧',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;
    // Pick wisdom based on day of year
    final dayIndex = DateTime.now().difference(DateTime(2025, 1, 1)).inDays;
    final wisdom = _wisdoms[dayIndex % _wisdoms.length];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  AppTheme.darkElevated,
                  AppTheme.darkSurface,
                ]
              : [
                  const Color(0xFFFAF6F0), // Warm parchment
                  const Color(0xFFF5EDE0),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: isDark ? 0.15 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentGold.withValues(alpha: isDark ? 0.05 : 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(wisdom.emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Text(
                'Trà Tuệ Hôm Nay',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.accentGold.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '"${wisdom.quote}"',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '— ${wisdom.source}',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.darkTextSecondary
                    : AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TeaWisdom {
  final String quote, source, emoji;
  const _TeaWisdom(
      {required this.quote, required this.source, required this.emoji});
}
