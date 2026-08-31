import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/provider/onboarding/presentation/providers/provider_onboarding_providers.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_sizes.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import '../providers/locale_provider.dart';
import '../router/route_names.dart';
import '../l10n/app_localizations.dart';
import 'morphing_spinner.dart';

/// Which home screen opened the sidebar. Drives the header title and the
/// item set so the same component renders correctly everywhere.
enum AppDrawerVariant { guest, customer, provider }

/// Custom two-bar hamburger trigger. Place it at the top-left of any screen
/// whose Scaffold has an [AppDrawer]; it opens the drawer via the enclosing
/// Scaffold, so it never affects the host layout.
class HamburgerMenuButton extends StatelessWidget {
  final Color color;

  /// Localized semantics/tooltip label, e.g. [AppLocalizations.menu].
  final String tooltip;

  const HamburgerMenuButton({
    super.key,
    this.color = AppColors.secondary,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: tooltip,
      child: Builder(
        builder: (context) => InkWell(
          onTap: () => Scaffold.of(context).openDrawer(),
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
            child: SizedBox(
              width: 22,
              height: 14,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: 2.4,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                  Container(
                    height: 2.4,
                    margin: const EdgeInsets.only(left: 9),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Unified slide-in sidebar for the Customer, Provider, and Guest home
/// screens (structure mirrors the Karsaaz reference: profile header,
/// English/اردو toggle, icon menu list, professional links, social footer).
///
/// Uses the Scaffold's built-in drawer mechanics, so the slide-in/out and
/// scrim (backdrop) fade are handled by the framework's drawer animation and
/// the panel overlays the body without touching host layouts.
class AppDrawer extends ConsumerStatefulWidget {
  final AppDrawerVariant variant;

  const AppDrawer({super.key, required this.variant});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _isLoggingOut = false;

  bool get _isAuthenticated => widget.variant != AppDrawerVariant.guest;

  String _title(AppLocalizations l10n) => switch (widget.variant) {
        AppDrawerVariant.guest => l10n.guestTitle,
        AppDrawerVariant.customer => l10n.customerRole,
        AppDrawerVariant.provider => l10n.providerRole,
      };

  void _showComingSoon(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  /// Closes the panel first, then runs the route action from a context that
  /// is still valid within the same frame.
  void _navigateTo(String route) {
    Navigator.of(context).pop();
    context.push(route);
  }

  Future<void> _logout() async {
    if (_isLoggingOut) return;
    setState(() => _isLoggingOut = true);
    try {
      // POST /api/v1/auth/logout {refreshToken} via the auth chain, then
      // tokens + cached user profile are cleared inside the repository.
      await ref.read(authStateProvider.notifier).logout();
      ref.read(pendingRegistrationProvider.notifier).state = null;
      ref.invalidate(providerVerificationStatusProvider);
    } finally {
      if (mounted) setState(() => _isLoggingOut = false);
    }
    if (mounted) context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      width: MediaQuery.sizeOf(context).width * .82 > 320
          ? 320
          : MediaQuery.sizeOf(context).width * .82,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.xl,
                AppSpacing.xxl,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: AppSizes.avatarMedium / 2,
                    backgroundColor: AppColors.primary.withOpacity(.10),
                    child: const Icon(
                      Icons.person_rounded,
                      color: AppColors.primaryDark,
                      size: AppSizes.iconMd,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _title(l10n),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.heading3,
                    ),
                  ),
                ],
              ),
            ),
            _LanguageToggle(
              selected: locale.languageCode,
              englishLabel: l10n.languageEnglish,
              urduLabel: l10n.languageUrdu,
            ),
            const Divider(height: 1, color: AppColors.border),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                children: _buildItems(l10n),
              ),
            ),
            const Divider(height: 1, color: AppColors.border),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.md,
                AppSpacing.xxl,
                AppSpacing.lg,
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _SocialBubble(
                        icon: Icons.facebook_rounded,
                        background: AppColors.primary,
                      ),
                      SizedBox(width: AppSpacing.lg),
                      _SocialBubble(
                        icon: Icons.chat_bubble_rounded,
                        background: AppColors.success,
                      ),
                      SizedBox(width: AppSpacing.lg),
                      _SocialBubble(
                        icon: Icons.play_circle_fill_rounded,
                        background: AppColors.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    l10n.appVersionLabel(AppConstants.appVersion),
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildItems(AppLocalizations l10n) {
    final items = <Widget>[];
    if (!_isAuthenticated) {
      items
        ..add(_DrawerItem(
          icon: Icons.login_rounded,
          label: l10n.login,
          onTap: () => _navigateTo(RouteNames.login),
        ))
        ..add(_DrawerItem(
          icon: Icons.person_add_alt_1_rounded,
          label: l10n.register,
          onTap: () => _navigateTo(RouteNames.signup),
        ));
    } else {
      items.add(_DrawerItem(
        icon: widget.variant == AppDrawerVariant.provider
            ? Icons.engineering_rounded
            : Icons.person_outline_rounded,
        label: l10n.profile,
        onTap: () => _navigateTo(
          widget.variant == AppDrawerVariant.provider
              ? RouteNames.providerProfile
              : RouteNames.customerProfile,
        ),
      ));
    }
    items
      ..add(_DrawerItem(
        icon: Icons.support_agent_rounded,
        label: l10n.customerSupport,
        onTap: () => _showComingSoon(l10n.comingSoon),
      ))
      ..add(_DrawerItem(
        icon: Icons.receipt_long_rounded,
        label: l10n.termsAndConditions,
        onTap: () => _showComingSoon(l10n.comingSoon),
      ))
      ..add(_DrawerItem(
        icon: Icons.share_rounded,
        label: l10n.inviteFriendsEarnCash,
        onTap: () => _showComingSoon(l10n.comingSoon),
      ))
      ..add(const _DrawerSeparator());
    if (_isAuthenticated) {
      items.add(_DrawerItem(
        icon: Icons.logout_rounded,
        label: l10n.logout,
        busy: _isLoggingOut,
        onTap: _isLoggingOut ? null : _logout,
      ));
    } else {
      items
        ..add(_DrawerItem(
          icon: Icons.badge_rounded,
          label: l10n.joinAsProfessionalFree,
          onTap: () => _navigateTo(RouteNames.signup),
        ))
        ..add(_DrawerItem(
          icon: Icons.login_rounded,
          label: l10n.loginAsProfessional,
          onTap: () => _navigateTo(RouteNames.login),
        ));
    }
    return items;
  }

}

class _LanguageToggle extends ConsumerWidget {
  final String selected;
  final String englishLabel;
  final String urduLabel;

  const _LanguageToggle({
    required this.selected,
    required this.englishLabel,
    required this.urduLabel,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        0,
        AppSpacing.xxl,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _LanguageOption(
              label: englishLabel,
              code: 'en',
              selected: selected == 'en',
              onTap: () => ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('en')),
            ),
          ),
          Expanded(
            child: _LanguageOption(
              label: urduLabel,
              code: 'ur',
              selected: selected == 'ur',
              onTap: () => ref
                  .read(localeProvider.notifier)
                  .setLocale(const Locale('ur')),
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String label;
  final String code;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.label,
    required this.code,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? AppColors.primary : AppColors.transparent,
              width: AppSizes.borderWidthFocused,
            ),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerSeparator extends StatelessWidget {
  const _DrawerSeparator();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.sm,
      ),
      child: Divider(height: 1, color: AppColors.border),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  /// Shows the morphing spinner instead of the icon while a request (e.g.
  /// logout) is in flight.
  final bool busy;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.busy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xxl,
            vertical: AppSpacing.lg - 2,
          ),
          child: Row(
            children: [
              SizedBox.square(
                dimension: AppSizes.iconMd,
                child: busy
                    ? const MorphingSpinner(size: AppSizes.iconMd, strokeWidth: 2.2)
                    : Icon(icon, color: AppColors.primary, size: AppSizes.iconMd),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyRegular.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialBubble extends StatelessWidget {
  final IconData icon;
  final Color background;

  const _SocialBubble({required this.icon, required this.background});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppSizes.avatarSmall / 2 + 2,
      backgroundColor: background,
      child: Icon(icon, color: AppColors.white, size: AppSizes.iconSm + 2),
    );
  }
}
