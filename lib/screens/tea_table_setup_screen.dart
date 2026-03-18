import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// TEA TABLE SETUP — Guide to arranging a tea table
/// Step-by-step, visual, premium tea ceremony guide.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeaTableSetupScreen extends StatelessWidget {
  const TeaTableSetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Thiết Lập Bàn Trà'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppTheme.darkElevated, AppTheme.darkSurface]
                        : [const Color(0xFFF8F4EC), const Color(0xFFF0E8D8)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.emoji_food_beverage_rounded,
                      size: 40,
                      color: AppTheme.accentGold,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nghệ Thuật Bày Bàn Trà',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hướng dẫn từ cơ bản đến nâng cao\ntheo phong cách trà đạo Việt',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── ESSENTIAL TOOLS ──
              _SectionTitle(title: 'Dụng Cụ Cần Thiết', isDark: isDark),
              const SizedBox(height: 12),
              _ToolGrid(
                isDark: isDark,
                tools: const [
                  _TeaTool(
                    Icons.emoji_food_beverage,
                    'Ấm tử sa',
                    'Chọn theo loại trà',
                  ),
                  _TeaTool(
                    CupertinoIcons.drop,
                    'Chén tống',
                    'Chia đều nước trà',
                  ),
                  _TeaTool(Icons.coffee_rounded, 'Chén quân', '4-6 chén nhỏ'),
                  _TeaTool(
                    Icons.water_damage_outlined,
                    'Thuyền trà',
                    'Hứng nước thừa',
                  ),
                  _TeaTool(
                    Icons.restaurant_rounded,
                    'Trà trúc',
                    'Múc trà vào ấm',
                  ),
                  _TeaTool(
                    CupertinoIcons.flame,
                    'Ấm đun nước',
                    'Kiểm soát nhiệt',
                  ),
                  _TeaTool(
                    Icons.dry_cleaning_rounded,
                    'Khăn trà',
                    'Lau ấm, lau bàn',
                  ),
                  _TeaTool(
                    Icons.inventory_2_rounded,
                    'Hũ đựng trà',
                    'Bảo quản kín',
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // ── SETUP STEPS ──
              _SectionTitle(title: 'Các Bước Bày Bàn', isDark: isDark),
              const SizedBox(height: 12),
              ..._steps.asMap().entries.map(
                (e) =>
                    _StepCard(index: e.key + 1, step: e.value, isDark: isDark),
              ),

              const SizedBox(height: 28),

              // ── TEA CEREMONY ETIQUETTE ──
              _SectionTitle(title: 'Lễ Nghi Trà Đạo', isDark: isDark),
              const SizedBox(height: 12),
              ..._etiquettes.map(
                (e) => _EtiquetteCard(etiquette: e, isDark: isDark),
              ),

              const SizedBox(height: 28),

              // ── PRO TIPS ──
              _SectionTitle(title: 'Mẹo Nâng Cao', isDark: isDark),
              const SizedBox(height: 12),
              ..._proTips.map((t) => _ProTipCard(tip: t, isDark: isDark)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  static const _steps = [
    _SetupStep(
      title: 'Chuẩn bị không gian',
      detail:
          'Chọn nơi yên tĩnh, thoáng. Bàn trà nên hướng ra sáng hoặc cửa sổ. '
          'Trải khăn trà sạch lên mặt bàn.',
      icon: CupertinoIcons.house_fill,
    ),
    _SetupStep(
      title: 'Sắp xếp dụng cụ',
      detail:
          'Ấm tử sa đặt giữa thuyền trà. Chén tống bên phải. '
          'Chén quân xếp thành hàng phía trước. Trà trúc + trà hồ bên trái.',
      icon: CupertinoIcons.square_grid_2x2_fill,
    ),
    _SetupStep(
      title: 'Ôn ấm, ôn chén',
      detail:
          'Đổ nước sôi qua ấm và chén để làm nóng, khử tạp chất. '
          'Nước này đổ bỏ qua thuyền trà.',
      icon: CupertinoIcons.flame_fill,
    ),
    _SetupStep(
      title: 'Cho trà vào ấm',
      detail:
          'Dùng trà trúc múc trà. Lượng trà: 1/3 thể tích ấm cho trà Ô Long, '
          '1/5 cho trà xanh. Ngửi hương trà khô trước khi pha.',
      icon: CupertinoIcons.leaf_arrow_circlepath,
    ),
    _SetupStep(
      title: 'Pha nước đầu tiên',
      detail:
          'Rót nước từ cao xuống (cao sơn lưu thuỷ). '
          'Nước đầu gọi là "rửa trà" — rót bỏ sau 5 giây để kích hoạt lá trà.',
      icon: CupertinoIcons.drop_fill,
    ),
    _SetupStep(
      title: 'Pha và thưởng thức',
      detail:
          'Nước thứ 2 mới là nước uống chính. Hãm đúng thời gian theo loại trà. '
          'Rót qua chén tống trước, rồi chia đều vào chén quân.',
      icon: Icons.emoji_food_beverage_rounded,
    ),
  ];

  static const _etiquettes = [
    _Etiquette(
      CupertinoIcons.hand_raised_fill,
      'Mời trà bằng hai tay',
      'Đưa chén trà bằng cả hai tay thể hiện sự tôn trọng. Người lớn tuổi được mời trước.',
    ),
    _Etiquette(
      CupertinoIcons.wind,
      'Ngửi trước, uống sau',
      'Nâng chén lên mũi, hít nhẹ hương trà. Nhấp ngụm nhỏ đầu tiên, cảm nhận vị trà.',
    ),
    _Etiquette(
      CupertinoIcons.moon_fill,
      'Giữ không gian tĩnh lặng',
      'Trà đạo là thiền. Hạn chế nói chuyện ồn ào, không sử dụng điện thoại.',
    ),
    _Etiquette(
      CupertinoIcons.arrow_2_circlepath,
      'Pha nhiều lần',
      'Trà ngon pha được 3-8 nước. Mỗi nước có hương vị khác nhau. Tăng thời gian hãm mỗi nước.',
    ),
  ];

  static const _proTips = [
    _ProTip(
      CupertinoIcons.thermometer,
      'Nhiệt độ nước',
      'Dùng nhiệt kế hoặc đợi 2 phút sau sôi cho trà xanh (75°C), '
          '30 giây cho trà ô long (90°C). Nước quá nóng sẽ chát.',
    ),
    _ProTip(
      CupertinoIcons.sparkles,
      'Nuôi ấm tử sa',
      'Sau mỗi lần dùng, rửa ấm bằng nước nóng (không dùng xà phòng). '
          'Lau khô bằng khăn mềm. Ấm càng dùng càng bóng.',
    ),
    _ProTip(
      CupertinoIcons.snow,
      'Trà lạnh cao cấp',
      'Hãm trà đặc gấp 3 bình thường, đổ qua đá viên. '
          'Hương trà được giữ nguyên mà không bị phai.',
    ),
  ];
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  const _SectionTitle({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppTheme.accentGold, Color(0xFF8B6914)],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _TeaTool {
  final IconData icon;
  final String name, desc;
  const _TeaTool(this.icon, this.name, this.desc);
}

class _ToolGrid extends StatelessWidget {
  final bool isDark;
  final List<_TeaTool> tools;
  const _ToolGrid({required this.isDark, required this.tools});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.85,
      children: tools
          .map(
            (t) => Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(t.icon, size: 24, color: AppTheme.accentGold),
                  const SizedBox(height: 4),
                  Text(
                    t.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.darkTextPrimary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    t.desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark
                          ? AppTheme.darkTextSecondary
                          : AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SetupStep {
  final String title, detail;
  final IconData icon;
  const _SetupStep({
    required this.title,
    required this.detail,
    required this.icon,
  });
}

class _StepCard extends StatelessWidget {
  final int index;
  final _SetupStep step;
  final bool isDark;
  const _StepCard({
    required this.index,
    required this.step,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppTheme.accentGold.withValues(alpha: isDark ? 0.1 : 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A3C28), Color(0xFF2D5E3E)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$index',
                style: const TextStyle(
                  color: AppTheme.accentGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(step.icon, size: 16, color: AppTheme.accentGold),
                    const SizedBox(width: 6),
                    Text(
                      step.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  step.detail,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Etiquette {
  final IconData icon;
  final String title, detail;
  const _Etiquette(this.icon, this.title, this.detail);
}

class _EtiquetteCard extends StatelessWidget {
  final _Etiquette etiquette;
  final bool isDark;
  const _EtiquetteCard({required this.etiquette, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.accentGold.withValues(alpha: 0.06)
            : const Color(0xFFFFF8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(etiquette.icon, size: 22, color: AppTheme.accentGold),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etiquette.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  etiquette.detail,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: isDark
                        ? AppTheme.darkTextSecondary
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProTip {
  final IconData icon;
  final String title, detail;
  const _ProTip(this.icon, this.title, this.detail);
}

class _ProTipCard extends StatelessWidget {
  final _ProTip tip;
  final bool isDark;
  const _ProTipCard({required this.tip, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(tip.icon, size: 16, color: AppTheme.accentGold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  tip.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: isDark
                        ? AppTheme.darkTextPrimary
                        : AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            tip.detail,
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: isDark
                  ? AppTheme.darkTextSecondary
                  : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
