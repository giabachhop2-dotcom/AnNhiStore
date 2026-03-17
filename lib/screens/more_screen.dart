import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../config/theme.dart';
import '../main.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);

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

          // Menu sections
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

          // Dynamic connections from API
          SliverToBoxAdapter(
            child: settingsAsync.when(
              data: (settings) {
                final opts = settings['optionsParsed'] as Map<String, dynamic>? ?? {};
                final phone = opts['hotline'] ?? opts['phone'] ?? '0827626962';
                final zalo = opts['zalo'] ?? phone;
                final website = opts['website'] ?? 'https://annhitra.com';
                final fanpage = opts['fanpage'] ?? 'https://facebook.com/annhitra';

                return CupertinoListSection.insetGrouped(
                  header: const Text('KẾT NỐI'),
                  children: [
                    CupertinoListTile(
                      leading: _MenuIcon(CupertinoIcons.phone_fill, CupertinoColors.activeGreen),
                      title: const Text('Gọi điện'),
                      subtitle: Text(_formatPhone(phone)),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => launchUrl(Uri.parse('tel:$phone')),
                    ),
                    CupertinoListTile(
                      leading: _MenuIcon(CupertinoIcons.chat_bubble_2_fill, CupertinoColors.activeBlue),
                      title: const Text('Chat Zalo'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => launchUrl(Uri.parse('https://zalo.me/$zalo')),
                    ),
                    CupertinoListTile(
                      leading: _MenuIcon(CupertinoIcons.globe, CupertinoColors.systemPurple),
                      title: const Text('Website'),
                      subtitle: Text(website.replaceAll('https://', '')),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => launchUrl(Uri.parse(website)),
                    ),
                    CupertinoListTile(
                      leading: _MenuIcon(CupertinoIcons.person_2, CupertinoColors.activeBlue),
                      title: const Text('Facebook'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => launchUrl(Uri.parse(fanpage)),
                    ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CupertinoActivityIndicator()),
              ),
              error: (_, __) => CupertinoListSection.insetGrouped(
                header: const Text('KẾT NỐI'),
                children: [
                  CupertinoListTile(
                    leading: _MenuIcon(CupertinoIcons.phone_fill, CupertinoColors.activeGreen),
                    title: const Text('Gọi điện'),
                    subtitle: const Text('082 762 6962'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => launchUrl(Uri.parse('tel:0827626962')),
                  ),
                ],
              ),
            ),
          ),

          // Settings section
          SliverToBoxAdapter(
            child: CupertinoListSection.insetGrouped(
              header: const Text('CÀI ĐẶT'),
              children: [
                CupertinoListTile(
                  leading: _MenuIcon(CupertinoIcons.moon_fill, CupertinoColors.systemIndigo),
                  title: const Text('Giao diện'),
                  trailing: _ThemeModeSelector(),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Text('Phiên bản 1.1.0',
                    style: TextStyle(color: AppTheme.textMuted.withValues(alpha: 0.6), fontSize: 13)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPhone(String phone) {
    if (phone.length == 10) {
      return '${phone.substring(0, 3)} ${phone.substring(3, 6)} ${phone.substring(6)}';
    }
    return phone;
  }
}

class _ThemeModeSelector extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    return CupertinoSlidingSegmentedControl<ThemeMode>(
      groupValue: mode,
      children: const {
        ThemeMode.system: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Tự động', style: TextStyle(fontSize: 12)),
        ),
        ThemeMode.light: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Sáng', style: TextStyle(fontSize: 12)),
        ),
        ThemeMode.dark: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text('Tối', style: TextStyle(fontSize: 12)),
        ),
      },
      onValueChanged: (value) {
        if (value != null) {
          ref.read(themeModeProvider.notifier).setMode(value);
        }
      },
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
