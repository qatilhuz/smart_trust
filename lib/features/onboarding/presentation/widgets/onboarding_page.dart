import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../l10n/app_localizations.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingReveal(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _OnboardingIconBadge(icon: Icons.language_rounded),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.onboardingSelectLanguage,
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.language,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Row(
                    children: [
                      Expanded(
                        child: _LanguageCard(
                          label: l10n.languageEnglish,
                          code: 'EN',
                          active: locale.languageCode == 'en',
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('en')),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _LanguageCard(
                          label: l10n.languageUrdu,
                          code: 'اُردو',
                          active: locale.languageCode == 'ur',
                          onTap: () => ref
                              .read(localeProvider.notifier)
                              .setLocale(const Locale('ur')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingReveal(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _TrustIllustration(),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.verifiedProfessionals,
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.introDescription,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _TrustPill(icon: Icons.handshake_rounded, label: l10n.trusted),
                      _TrustPill(icon: Icons.location_on_rounded, label: l10n.nearby),
                      _TrustPill(icon: Icons.visibility_rounded, label: l10n.transparent),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class RolePage extends ConsumerStatefulWidget {
  const RolePage({super.key});

  @override
  ConsumerState<RolePage> createState() => _RolePageState();
}

class _RolePageState extends ConsumerState<RolePage> {
  String? _selectedRole;

  Future<void> _selectRole(String role) async {
    // Preserve the existing role identifiers and persistence behavior.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    if (mounted) setState(() => _selectedRole = role);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _OnboardingReveal(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _OnboardingIconBadge(icon: Icons.people_alt_rounded),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.onboardingChooseRole,
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      _RoleCard(
                        title: l10n.customerRole,
                        subtitle: l10n.customerRoleDescription,
                        icon: Icons.search_rounded,
                        selected: _selectedRole == 'customer',
                        onTap: () => _selectRole('customer'),
                      ),
                      _RoleCard(
                        title: l10n.providerRole,
                        subtitle: l10n.providerRoleDescription,
                        icon: Icons.engineering_rounded,
                        selected: _selectedRole == 'provider',
                        onTap: () => _selectRole('provider'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingReveal extends StatefulWidget {
  final Widget child;

  const _OnboardingReveal({required this.child});

  @override
  State<_OnboardingReveal> createState() => _OnboardingRevealState();
}

class _OnboardingRevealState extends State<_OnboardingReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  )..forward();

  late final Animation<double> _fade = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, .045),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

class _OnboardingIconBadge extends StatelessWidget {
  final IconData icon;

  const _OnboardingIconBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.avatarLarge + AppSpacing.xxl,
      height: AppSizes.avatarLarge + AppSpacing.xxl,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.24),
            blurRadius: AppSpacing.xxl,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Icon(icon, color: AppColors.white, size: AppSizes.iconXl),
    );
  }
}

class _TrustIllustration extends StatelessWidget {
  const _TrustIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 148,
      height: 148,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surface,
        border: Border.all(color: AppColors.primaryLight, width: AppSizes.borderWidth),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(.08),
            blurRadius: AppSpacing.xxl,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(.10),
            ),
          ),
          const Icon(
            Icons.verified_user_rounded,
            size: 64,
            color: AppColors.primaryDark,
          ),
          Positioned(
            right: 22,
            top: 25,
            child: Container(
              width: AppSizes.iconSm,
              height: AppSizes.iconSm,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary,
              ),
              child: const Icon(Icons.check, size: 13, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  final String label;
  final String code;
  final bool active;
  final VoidCallback onTap;

  const _LanguageCard({
    required this.label,
    required this.code,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: active,
      label: label,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: active ? AppColors.primary : AppColors.border,
                width: active ? AppSizes.borderWidthFocused : AppSizes.borderWidth,
              ),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.22),
                        blurRadius: AppSpacing.lg,
                        offset: const Offset(0, AppSpacing.sm),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  code,
                  style: AppTextStyles.heading3.copyWith(
                    color: active ? AppColors.white : AppColors.secondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: active ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSizes.iconSm, color: AppColors.primaryDark),
          const SizedBox(width: AppSpacing.xs),
          Text(label, style: AppTextStyles.label.copyWith(color: AppColors.secondary)),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: title,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            width: 148,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withOpacity(.10) : AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? AppSizes.borderWidthFocused : AppSizes.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppColors.primary.withOpacity(.16)
                      : AppColors.secondary.withOpacity(.05),
                  blurRadius: selected ? AppSpacing.lg : AppSpacing.sm,
                  offset: const Offset(0, AppSpacing.xs),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutBack,
                  child: CircleAvatar(
                    radius: AppSpacing.xxl,
                    backgroundColor: selected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(.10),
                    child: Icon(
                      icon,
                      color: selected ? AppColors.white : AppColors.primaryDark,
                      size: AppSizes.iconLg,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading3.copyWith(fontSize: AppFonts.lg),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.sm),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: selected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          key: ValueKey('selected'),
                          color: AppColors.primaryDark,
                          size: AppSizes.iconMd,
                        )
                      : const SizedBox(
                          key: ValueKey('unselected'),
                          height: AppSizes.iconMd,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
