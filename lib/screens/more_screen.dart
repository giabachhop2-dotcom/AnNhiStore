import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          const CupertinoSliverNavigationBar(
            largeTitle: Text('Thêm'),
            border: null,
          ),

          // Profile / Brand header
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryDark,
                    AppTheme.primaryDark.withValues(alpha: 0.85),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryDark.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.asset('assets/images/logo.png', height: 50, width: 50, fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('An Nhi Trà',
                            style: TextStyle(color: CupertinoColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        Text('Trà Ngon & Ấm Tử Sa Chính Hãng',
                            style: TextStyle(color: CupertinoColors.white.withValues(alpha: 0.7), fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Menu sections (iOS grouped list)
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              header: const Text('THÔNG TIN'),
              children: [
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.info, CupertinoColors.activeBlue),
                  title: const Text('Giới thiệu'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => context.push('/about'),
                ),
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.mail, CupertinoColors.activeGreen),
                  title: const Text('Liên hệ'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => context.push('/contact'),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              header: const Text('KẾT NỐI'),
              children: [
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.phone_fill, CupertinoColors.activeGreen),
                  title: const Text('Gọi điện'),
                  subtitle: const Text('082 762 6962'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => launchUrl(Uri.parse('tel:0827626962')),
                ),
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.chat_bubble_2_fill, CupertinoColors.activeBlue),
                  title: const Text('Chat Zalo'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => launchUrl(Uri.parse('https://zalo.me/0827626962')),
                ),
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.globe, CupertinoColors.systemPurple),
                  title: const Text('Website'),
                  subtitle: const Text('annhitra.com'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => launchUrl(Uri.parse('https://annhitra.com')),
                ),
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.person_2, CupertinoColors.activeBlue),
                  title: const Text('Facebook'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => launchUrl(Uri.parse('https://facebook.com/annhitra')),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('Phiên bản 1.0.0',
                    style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.6), fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _MenuIcon(this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
      ),
      child: Icon(icon, size: 18, color: CupertinoColors.white),
    );
  }
}
