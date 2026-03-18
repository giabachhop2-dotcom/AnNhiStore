import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../config/design_tokens.dart';

/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
/// PRICE BADGE — Unified price / contact display
/// Three variants: regular, sale, contact
/// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

class PriceBadge extends StatelessWidget {
  final double? regularPrice;
  final double? salePrice;
  final double? discount;
  final String Function(double) formatter;
  final bool isDark;
  final bool compact;

  const PriceBadge({
    super.key,
    this.regularPrice,
    this.salePrice,
    this.discount,
    required this.formatter,
    required this.isDark,
    this.compact = false,
  });

  bool get _isContact =>
      (regularPrice == null || regularPrice == 0) &&
      (salePrice == null || salePrice == 0);

  bool get _isOnSale =>
      salePrice != null &&
      salePrice! > 0 &&
      regularPrice != null &&
      regularPrice! > salePrice!;

  @override
  Widget build(BuildContext context) {
    if (_isContact) return _buildContactBadge();
    if (_isOnSale) return _buildSaleBadge();
    return _buildRegularBadge();
  }

  /// Regular price — gold bordered container
  Widget _buildRegularBadge() {
    final price = (salePrice != null && salePrice! > 0)
        ? salePrice!
        : (regularPrice ?? 0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: BrandColors.goldMid.withValues(alpha: 0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(Radii.xs),
        color: BrandColors.goldSubtle,
      ),
      child: Text(
        formatter(price),
        style: TextStyle(
          fontSize: compact ? 13 : 15,
          fontWeight: FontWeight.bold,
          color: BrandColors.goldMid,
          letterSpacing: -0.3,
        ),
      ),
    );
  }

  /// Sale price — gold glow + strikethrough original
  Widget _buildSaleBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: BrandColors.goldDark.withValues(alpha: 0.6),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(Radii.xs),
        color: BrandColors.goldSubtle,
        boxShadow: [
          BoxShadow(
            color: BrandColors.goldDark.withValues(alpha: 0.15),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatter(salePrice!),
            style: TextStyle(
              fontSize: compact ? 13 : 15,
              fontWeight: FontWeight.bold,
              color: BrandColors.goldDark,
              letterSpacing: -0.3,
            ),
          ),
          if (!compact) ...[
            const SizedBox(height: 1),
            Text(
              formatter(regularPrice!),
              style: TextStyle(
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.lineThrough,
                color: isDark
                    ? AppTheme.darkTextSecondary.withValues(alpha: 0.6)
                    : AppTheme.textMuted.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Contact — dashed border with envelope icon
  Widget _buildContactBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Radii.xs),
        border: Border.all(
          color: BrandColors.goldMid.withValues(alpha: 0.4),
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            CupertinoIcons.envelope,
            size: compact ? 12 : 14,
            color: BrandColors.goldMid,
          ),
          SizedBox(width: compact ? 4 : 6),
          Text(
            'Liên hệ',
            style: TextStyle(
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
              color: BrandColors.goldMid,
            ),
          ),
        ],
      ),
    );
  }
}

/// Standalone contact CTA row — for product detail bottom bar
class ContactCTARow extends StatelessWidget {
  final String phone;
  final String zalo;
  final String? productName;
  final VoidCallback? onZalo;
  final VoidCallback? onCall;

  const ContactCTARow({
    super.key,
    required this.phone,
    required this.zalo,
    this.productName,
    this.onZalo,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Zalo button
        Expanded(
          flex: 3,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: BrandColors.zalo,
            borderRadius: Radii.borderMd,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onZalo?.call();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.chat_bubble_fill,
                  size: 18,
                  color: CupertinoColors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Nhắn Zalo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Call button
        Expanded(
          flex: 2,
          child: CupertinoButton(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: BrandColors.success,
            borderRadius: Radii.borderMd,
            onPressed: () {
              HapticFeedback.mediumImpact();
              onCall?.call();
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  CupertinoIcons.phone_fill,
                  size: 18,
                  color: CupertinoColors.white,
                ),
                SizedBox(width: 6),
                Text(
                  'Gọi ngay',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: CupertinoColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
