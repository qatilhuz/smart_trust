import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LanguageSelectionScreen extends ConsumerWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.language_rounded, size: AppSizes.iconXl, color: AppColors.primary),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.onboardingSelectLanguage, style: AppTextStyles.heading2, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.section),
                Row(
                  children: [
                    Expanded(
                      child: _LanguageButton(
                        label: l10n.languageEnglish,
                        onPressed: () {
                          ref.read(localeProvider.notifier).setLocale(const Locale('en'));
                          context.pop();
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _LanguageButton(
                        label: l10n.languageUrdu,
                        onPressed: () {
                          ref.read(localeProvider.notifier).setLocale(const Locale('ur'));
                          context.pop();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _LanguageButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd)),
        ),
        child: Text(label),
      ),
    );
  }
}
