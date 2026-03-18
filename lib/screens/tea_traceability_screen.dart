import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../config/theme.dart';
import '../widgets/premium_widgets.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// TEA TRACEABILITY — Trace origin by batch code
/// Lookup: batch, origin, altitude, aging, farmer.
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class TeaTraceabilityScreen extends StatefulWidget {
  const TeaTraceabilityScreen({super.key});

  @override
  State<TeaTraceabilityScreen> createState() => _TeaTraceabilityScreenState();
}

class _TeaTraceabilityScreenState extends State<TeaTraceabilityScreen>
    with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  _TeaBatch? _result;
  bool _isSearching = false;
  bool _notFound = false;
  late AnimationController _revealController;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  Future<void> _lookup() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _isSearching = true;
      _notFound = false;
      _result = null;
    });

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final batch = _mockDatabase[code];
    if (mounted) {
      setState(() {
        _isSearching = false;
        _result = batch;
        _notFound = batch == null;
      });
      if (batch != null) {
        _revealController.forward(from: 0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = CupertinoTheme.brightnessOf(context) == Brightness.dark;

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Truy Xuất Nguồn Gốc'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Header illustration ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark
                        ? [AppTheme.darkElevated, AppTheme.darkSurface]
                        : [const Color(0xFFF8F4EC), const Color(0xFFF0E8D8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A3C28), Color(0xFF2D5E3E)],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryDark.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.qrcode_viewfinder,
                        size: 32,
                        color: AppTheme.accentGold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nhập mã lô trà',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppTheme.darkTextPrimary
                            : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Tra cứu nguồn gốc, vùng trồng và quy trình sản xuất',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? AppTheme.darkTextSecondary
                            : AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── Code input ──
              CupertinoTextField(
                controller: _codeController,
                placeholder: 'VD: ANT-2025-001',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                  color: isDark
                      ? AppTheme.darkTextPrimary
                      : AppTheme.textPrimary,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (_) => _lookup(),
              ),

              const SizedBox(height: 16),

              GoldCTAButton(
                label: 'Tra cứu nguồn gốc',
                icon: CupertinoIcons.search,
                isLoading: _isSearching,
                onPressed: _isSearching ? null : _lookup,
              ),

              const SizedBox(height: 12),

              // Demo hint
              Center(
                child: GestureDetector(
                  onTap: () {
                    _codeController.text = 'ANT-2025-001';
                    _lookup();
                  },
                  child: Text(
                    'Thử mã demo: ANT-2025-001',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.accentGold.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ── Not found ──
              if (_notFound)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        CupertinoIcons.xmark_circle,
                        size: 40,
                        color: AppTheme.priceRed,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Không tìm thấy mã lô trà',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppTheme.darkTextPrimary
                              : AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vui lòng kiểm tra lại mã trên bao bì sản phẩm',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppTheme.darkTextSecondary
                              : AppTheme.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Result ──
              if (_result != null) _buildResult(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResult(bool isDark) {
    final batch = _result!;

    return AnimatedBuilder(
      animation: _revealController,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verification badge
            _buildRevealItem(
              0,
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A3C28), Color(0xFF2D5E3E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.accentGold.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        CupertinoIcons.checkmark_seal_fill,
                        color: AppTheme.accentGold,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sản phẩm chính hãng',
                            style: TextStyle(
                              color: AppTheme.accentGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Xác minh bởi An Nhi Trà',
                            style: TextStyle(
                              color: CupertinoColors.white.withValues(
                                alpha: 0.7,
                              ),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Product name
            _buildRevealItem(
              1,
              _InfoCard(
                isDark: isDark,
                icon: CupertinoIcons.leaf_arrow_circlepath,
                iconColor: const Color(0xFF4A7C5C),
                label: 'Tên sản phẩm',
                value: batch.productName,
              ),
            ),

            const SizedBox(height: 10),

            // Origin + Region
            _buildRevealItem(
              2,
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      isDark: isDark,
                      icon: CupertinoIcons.map_pin_ellipse,
                      iconColor: const Color(0xFFE57373),
                      label: 'Vùng trồng',
                      value: batch.region,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      isDark: isDark,
                      icon: CupertinoIcons.arrow_up_right_diamond,
                      iconColor: const Color(0xFF64B5F6),
                      label: 'Độ cao',
                      value: batch.altitude,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Batch + Harvest
            _buildRevealItem(
              3,
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      isDark: isDark,
                      icon: CupertinoIcons.barcode,
                      iconColor: AppTheme.accentGold,
                      label: 'Mã lô',
                      value: batch.batchCode,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      isDark: isDark,
                      icon: CupertinoIcons.calendar,
                      iconColor: const Color(0xFF81C784),
                      label: 'Thu hoạch',
                      value: batch.harvestDate,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Type + Aging
            _buildRevealItem(
              4,
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      isDark: isDark,
                      icon: CupertinoIcons.cube_box,
                      iconColor: const Color(0xFFBA68C8),
                      label: 'Loại trà',
                      value: batch.teaType,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      isDark: isDark,
                      icon: CupertinoIcons.timer,
                      iconColor: const Color(0xFFFFB74D),
                      label: 'Thời gian ủ',
                      value: batch.agingTime,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Process
            _buildRevealItem(
              5,
              _InfoCard(
                isDark: isDark,
                icon: CupertinoIcons.lab_flask,
                iconColor: const Color(0xFF4DB6AC),
                label: 'Quy trình sản xuất',
                value: batch.process,
              ),
            ),

            const SizedBox(height: 10),

            // Farmer
            _buildRevealItem(
              6,
              _InfoCard(
                isDark: isDark,
                icon: CupertinoIcons.person_crop_circle,
                iconColor: const Color(0xFF7986CB),
                label: 'Nông hộ / Đối tác',
                value: batch.farmer,
              ),
            ),

            const SizedBox(height: 10),

            // Certificate
            if (batch.certificate != null)
              _buildRevealItem(
                7,
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.darkElevated : AppTheme.groupedBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppTheme.accentGold.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.rosette,
                        color: AppTheme.accentGold,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          batch.certificate!,
                          style: TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: isDark
                                ? AppTheme.darkTextSecondary
                                : AppTheme.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }

  Widget _buildRevealItem(int index, Widget child) {
    final stagger = (index * 0.08).clamp(0.0, 0.5);
    final t = ((_revealController.value - stagger) / (1 - stagger)).clamp(
      0.0,
      1.0,
    );
    final curve = Curves.easeOutCubic.transform(t);

    return Opacity(
      opacity: curve,
      child: Transform.translate(
        offset: Offset(0, 20 * (1 - curve)),
        child: child,
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final bool isDark;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoCard({
    required this.isDark,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkElevated : AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppTheme.darkTextSecondary
                      : AppTheme.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppTheme.darkTextPrimary : AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data model ──
class _TeaBatch {
  final String productName;
  final String batchCode;
  final String teaType;
  final String region;
  final String altitude;
  final String harvestDate;
  final String agingTime;
  final String process;
  final String farmer;
  final String? certificate;

  const _TeaBatch({
    required this.productName,
    required this.batchCode,
    required this.teaType,
    required this.region,
    required this.altitude,
    required this.harvestDate,
    required this.agingTime,
    required this.process,
    required this.farmer,
    this.certificate,
  });
}

// ── Mock database (replace with real API later) ──
final Map<String, _TeaBatch> _mockDatabase = {
  'ANT-2025-001': const _TeaBatch(
    productName: 'Trà Shan Tuyết Cổ Thụ - Hà Giang',
    batchCode: 'ANT-2025-001',
    teaType: 'Trà Shan Tuyết (Camellia sinensis var. Shan)',
    region: 'Hoàng Su Phì, Hà Giang',
    altitude: '1.400 - 1.600m',
    harvestDate: 'Tháng 3/2025 (Xuân)',
    agingTime: '6 tháng ủ tự nhiên',
    process:
        'Hái thủ công → Héo nắng → Sao chảo gang → Vò → Phơi âm can → Ủ kho lạnh',
    farmer: 'HTX Trà Shan Tuyết Hoàng Su Phì',
    certificate: 'Chứng nhận VietGAP · Truy xuất TXNG Bộ NN&PTNT',
  ),
  'ANT-2025-002': const _TeaBatch(
    productName: 'Hồng Trà Shan Tuyết - Yên Bái',
    batchCode: 'ANT-2025-002',
    teaType: 'Hồng Trà (Black Tea)',
    region: 'Suối Giàng, Văn Chấn, Yên Bái',
    altitude: '1.200 - 1.400m',
    harvestDate: 'Tháng 4/2025 (Xuân muộn)',
    agingTime: '3 tháng lên men tự nhiên',
    process:
        'Hái thủ công → Héo tự nhiên → Vò nén → Lên men 8h → Sấy than hoa → Ủ 3 tháng',
    farmer: 'Nông hộ Giàng A Chải - bản Suối Giàng',
    certificate: 'Chứng nhận hữu cơ USDA Organic',
  ),
  'ANT-2025-003': const _TeaBatch(
    productName: 'Trà Ô Long Shan Tuyết Đặc Biệt',
    batchCode: 'ANT-2025-003',
    teaType: 'Ô Long (Oolong, bán lên men 30-40%)',
    region: 'Tà Xùa, Bắc Yên, Sơn La',
    altitude: '1.600 - 1.800m',
    harvestDate: 'Tháng 5/2025 (Hè sớm)',
    agingTime: '2 tháng ủ ổn định hương',
    process:
        'Hái búp 1 tôm 2 lá → Héo nắng → Rung lắc oxy hóa → Sao cố định → Vò → Sấy nhẹ → Ủ',
    farmer: 'Đối tác ANNSHAN - Vùng nguyên liệu Tà Xùa',
    certificate: 'Sản phẩm OCOP 4 sao · Bảo hộ chỉ dẫn địa lý',
  ),
  'ANT-2025-004': const _TeaBatch(
    productName: 'Phổ Nhĩ Chín Shan Tuyết 2023',
    batchCode: 'ANT-2025-004',
    teaType: 'Phổ Nhĩ Chín (Shou Pu-erh)',
    region: 'Lũng Phìn, Đồng Văn, Hà Giang',
    altitude: '1.500 - 1.700m',
    harvestDate: 'Tháng 9/2023 (Thu)',
    agingTime: '18 tháng (ủ ướt + ủ khô)',
    process:
        'Sao mao trà → Phơi dương → Ủ ướt 45 ngày → Lật giở → Sấy → Nén bánh → Ủ khô 12 tháng',
    farmer: 'HTX Lũng Phìn - Cao nguyên đá Đồng Văn',
    certificate: 'Di sản Công viên Địa chất Toàn cầu UNESCO',
  ),
  'ANT-2025-005': const _TeaBatch(
    productName: 'Bạch Trà Shan Tuyết Tuyển Chọn',
    batchCode: 'ANT-2025-005',
    teaType: 'Bạch Trà (White Tea, oxy hóa <5%)',
    region: 'Phìn Hồ, Hoàng Su Phì, Hà Giang',
    altitude: '1.500m',
    harvestDate: 'Tháng 3/2025 (Xuân sớm)',
    agingTime: '1 tháng phơi âm can tự nhiên',
    process:
        'Hái búp non sáng sớm → Héo mát 48h → Phơi âm can 72h → Đóng gói chân không',
    farmer: 'Gia đình bà Vàng Thị Mỷ - bản Phìn Hồ',
    certificate: 'Chứng nhận An toàn thực phẩm · Sản phẩm OCOP 3 sao',
  ),
};
