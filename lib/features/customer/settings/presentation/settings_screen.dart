import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/route_names.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isUrdu = locale.languageCode == 'ur';
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: Text(isUrdu ? 'سیٹنگز' : 'Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle(title: isUrdu ? 'زبان' : 'Language'),
          ListTile(
            leading: const Icon(Icons.language, color: AppColors.primary),
            title: Text(isUrdu ? 'English' : 'Urdu'),
            subtitle: Text(isUrdu ? 'تبدیلی کے لیے یہاں دبائیں' : 'Tap to switch'),
            trailing: Switch(
              value: locale.languageCode == 'ur',
              onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v ? const Locale('ur') : const Locale('en')),
            ),
          ),
          const Divider(),
          _SectionTitle(title: isUrdu ? 'اکاؤنٹ' : 'Account'),
          ListTile(
            leading: const Icon(Icons.person, color: AppColors.primary),
            title: Text(isUrdu ? 'پروفائل' : 'Profile'),
            onTap: () => context.push(RouteNames.customerProfile),
          ),
          if (auth.value != null)
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(isUrdu ? 'لاگ آؤٹ' : 'Logout'),
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('user_role');
                if (mounted) context.go(RouteNames.login);
              },
            ),
          if (auth.value == null)
            ListTile(
              leading: const Icon(Icons.login, color: AppColors.primary),
              title: Text(isUrdu ? 'سائن ان' : 'Sign In'),
              onTap: () => context.push(RouteNames.login),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
    );
  }
}
