import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

/// Floating speed-dial CTA for Zalo/Phone.
/// Shows a main button that expands into 2 actions on tap.
class FloatingContactCta extends StatefulWidget {
  final String phone;
  final String zalo;

  const FloatingContactCta({
    super.key,
    required this.phone,
    required this.zalo,
  });

  @override
  State<FloatingContactCta> createState() => _FloatingContactCtaState();
}

class _FloatingContactCtaState extends State<FloatingContactCta>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _controller;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    HapticFeedback.selectionClick();
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zalo button (slides up)
        ScaleTransition(
          scale: _expandAnim,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MiniAction(
              icon: CupertinoIcons.chat_bubble_2_fill,
              label: 'Zalo',
              color: const Color(0xFF0068FF),
              onTap: () {
                _toggle();
                launchUrl(Uri.parse('https://zalo.me/${widget.zalo}'),
                    mode: LaunchMode.externalApplication);
              },
            ),
          ),
        ),
        // Phone button
        ScaleTransition(
          scale: _expandAnim,
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MiniAction(
              icon: CupertinoIcons.phone_fill,
              label: 'Gọi',
              color: CupertinoColors.activeGreen,
              onTap: () {
                _toggle();
                launchUrl(Uri.parse('tel:${widget.phone}'));
              },
            ),
          ),
        ),
        // Main FAB
        GestureDetector(
          onTap: _toggle,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: _expanded
                    ? [Colors.grey.shade600, Colors.grey.shade500]
                    : [AppTheme.primaryDark, const Color(0xFF2A5C3F)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: (_expanded ? Colors.grey : AppTheme.primaryDark)
                      .withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: AnimatedRotation(
              turns: _expanded ? 0.125 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                _expanded ? CupertinoIcons.xmark : CupertinoIcons.phone_fill,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MiniAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBackground.resolveFrom(context),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(label,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          ),
          const SizedBox(width: 8),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }
}
