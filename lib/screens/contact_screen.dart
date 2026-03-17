import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/providers.dart';
import '../config/theme.dart';

class ContactScreen extends ConsumerStatefulWidget {
  const ContactScreen({super.key});

  @override
  ConsumerState<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends ConsumerState<ContactScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Thiếu thông tin'),
          content: const Text('Vui lòng nhập họ tên và số điện thoại.'),
          actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
        ),
      );
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => isSubmitting = true);
    try {
      await ref.read(apiServiceProvider).sendContact(
        fullname: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        content: _contentCtrl.text.trim(),
      );
      if (mounted) {
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _emailCtrl.clear();
        _contentCtrl.clear();
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Gửi thành công!'),
            content: const Text('Chúng tôi sẽ phản hồi sớm nhất.'),
            actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        showCupertinoDialog(
          context: context,
          builder: (ctx) => CupertinoAlertDialog(
            title: const Text('Lỗi'),
            content: const Text('Không thể gửi liên hệ. Vui lòng kiểm tra kết nối mạng và thử lại.'),
            actions: [CupertinoDialogAction(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
          ),
        );
      }
    }
    if (mounted) setState(() => isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Liên Hệ')),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Quick actions from API
            settingsAsync.when(
              data: (settings) {
                final opts = settings['optionsParsed'] as Map<String, dynamic>? ?? {};
                final phone = opts['hotline'] ?? opts['phone'] ?? '0827626962';
                final zalo = opts['zalo'] ?? phone;
                final address = settings['addressvi'] ?? opts['address'] ?? '';

                return CupertinoListSection.insetGrouped(
                  header: const Text('LIÊN HỆ NHANH'),
                  children: [
                    CupertinoListTile(
                      leading: const Icon(CupertinoIcons.phone_fill, color: AppTheme.primaryDark),
                      title: const Text('Hotline'),
                      subtitle: Text(_formatPhone(phone)),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => launchUrl(Uri.parse('tel:$phone')),
                    ),
                    CupertinoListTile(
                      leading: Icon(CupertinoIcons.chat_bubble_2_fill, color: Colors.blue),
                      title: const Text('Zalo'),
                      subtitle: const Text('Chat trực tiếp'),
                      trailing: const CupertinoListTileChevron(),
                      onTap: () => launchUrl(Uri.parse('https://zalo.me/$zalo')),
                    ),
                    if (address.isNotEmpty)
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.location_fill, color: AppTheme.priceRed),
                        title: const Text('Địa chỉ'),
                        subtitle: Text(address, maxLines: 2, overflow: TextOverflow.ellipsis),
                        trailing: const CupertinoListTileChevron(),
                        onTap: () => launchUrl(Uri.parse('https://maps.google.com/?q=${Uri.encodeComponent(address)}')),
                      ),
                  ],
                );
              },
              loading: () => const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CupertinoActivityIndicator()),
              ),
              error: (_, __) => CupertinoListSection.insetGrouped(
                header: const Text('LIÊN HỆ NHANH'),
                children: [
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.phone_fill, color: AppTheme.primaryDark),
                    title: const Text('Hotline'),
                    subtitle: const Text('082 762 6962'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () => launchUrl(Uri.parse('tel:0827626962')),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contact form
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text('GỬI LIÊN HỆ',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted, letterSpacing: 0.5)),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: CupertinoColors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  CupertinoTextField(
                    controller: _nameCtrl,
                    placeholder: 'Họ và tên *',
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(CupertinoIcons.person, size: 18, color: AppTheme.textMuted),
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.groupedBg, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _phoneCtrl,
                    placeholder: 'Số điện thoại *',
                    keyboardType: TextInputType.phone,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(CupertinoIcons.phone, size: 18, color: AppTheme.textMuted),
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.groupedBg, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _emailCtrl,
                    placeholder: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    prefix: const Padding(
                      padding: EdgeInsets.only(left: 8),
                      child: Icon(CupertinoIcons.mail, size: 18, color: AppTheme.textMuted),
                    ),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.groupedBg, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 10),
                  CupertinoTextField(
                    controller: _contentCtrl,
                    placeholder: 'Nội dung',
                    maxLines: 4,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppTheme.groupedBg, borderRadius: BorderRadius.circular(10)),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: CupertinoButton.filled(
                      onPressed: isSubmitting ? null : _submit,
                      borderRadius: BorderRadius.circular(12),
                      child: isSubmitting
                          ? const CupertinoActivityIndicator(color: CupertinoColors.white)
                          : const Text('Gửi liên hệ'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
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
