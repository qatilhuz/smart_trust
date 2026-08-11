import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/locale_provider.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isUrdu = locale.languageCode == 'ur';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.language,
              size: 80,
              color: AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              isUrdu ? 'اپنی زبان منتخب کریں' : 'Select Your Language',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LangButton(
                  label: 'English',
                  code: 'en',
                  active: locale.languageCode == 'en',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('en')),
                ),
                const SizedBox(width: 16),
                _LangButton(
                  label: 'Urdu',
                  code: 'ur',
                  active: locale.languageCode == 'ur',
                  onTap: () => ref.read(localeProvider.notifier).setLocale(const Locale('ur')),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final String code;
  final bool active;
  final VoidCallback onTap;
  const _LangButton({required this.label, required this.code, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: active ? AppColors.primary : AppColors.border),
          boxShadow: active ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 12, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w600, color: active ? Colors.white : AppColors.textPrimary, fontSize: 16),
        ),
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            const Text(
              'Verified Professionals',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'SmartTrust connects you with verified service providers. Request, compare, and track with confidence.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                Chip(avatar: Icon(Icons.handshake, color: AppColors.primary), label: Text('Trusted'), backgroundColor: AppColors.surface, side: BorderSide(color: AppColors.border)),
                Chip(avatar: Icon(Icons.location_on, color: AppColors.primary), label: Text('Nearby'), backgroundColor: AppColors.surface, side: BorderSide(color: AppColors.border)),
                Chip(avatar: Icon(Icons.chat_bubble_outline, color: AppColors.primary), label: Text('Transparent'), backgroundColor: AppColors.surface, side: BorderSide(color: AppColors.border)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RolePage extends ConsumerWidget {
  const RolePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isUrdu = locale.languageCode == 'ur';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt, size: 80, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              isUrdu ? 'اپنا کردار منتخب کریں' : 'Choose Your Role',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.secondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: _RoleCard(
                    title: isUrdu ? 'گاہک' : 'Customer',
                    subtitle: isUrdu ? 'قریب trustworthy professionals تلاش کریں۔' : 'Find trusted professionals near you.',
                    icon: Icons.search,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_role', 'customer');
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _RoleCard(
                    title: isUrdu ? 'خدمت فراہم کرنے والا' : 'Service Provider',
                    subtitle: isUrdu ? 'اپنا کام بڑھائیں اور دریافت ہوں۔' : 'Grow your work and get discovered.',
                    icon: Icons.engineering,
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('user_role', 'provider');
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  const _RoleCard({required this.title, required this.subtitle, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            CircleAvatar(radius: 28, backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(icon, color: AppColors.primary, size: 28)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondary)),
            const SizedBox(height: 6),
            Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.3)),
          ],
        ),
      ),
    );
  }
}
