import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../l10n/app_localizations.dart';

class RoleSelector extends StatelessWidget {
  final String? selectedRole;
  final ValueChanged<String> onRoleChanged;

  const RoleSelector({
    super.key,
    required this.selectedRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.chooseAccountRole, style: AppTextStyles.heading3),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _RoleOption(
                title: l10n.customerRole,
                subtitle: l10n.customerRoleDescription,
                icon: Icons.search_rounded,
                selected: selectedRole == 'customer',
                onTap: () => onRoleChanged('customer'),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _RoleOption(
                title: l10n.providerRole,
                subtitle: l10n.providerRoleDescription,
                icon: Icons.engineering_rounded,
                selected: selectedRole == 'provider',
                onTap: () => onRoleChanged('provider'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _RoleOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleOption({
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
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withOpacity(.10) : AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? AppSizes.borderWidthFocused : AppSizes.borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppColors.primary.withOpacity(.15)
                      : AppColors.secondary.withOpacity(.04),
                  blurRadius: selected ? AppSpacing.md : AppSpacing.sm,
                  offset: const Offset(0, AppSpacing.xs),
                ),
              ],
            ),
            child: Column(
              children: [
                AnimatedScale(
                  scale: selected ? 1.08 : 1,
                  duration: const Duration(milliseconds: 240),
                  child: CircleAvatar(
                    radius: AppSpacing.xl,
                    backgroundColor: selected
                        ? AppColors.primary
                        : AppColors.primary.withOpacity(.10),
                    child: Icon(
                      icon,
                      size: AppSizes.iconMd,
                      color: selected ? AppColors.white : AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(subtitle, textAlign: TextAlign.center, style: AppTextStyles.caption),
                const SizedBox(height: AppSpacing.xs),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: selected
                      ? const Icon(
                          Icons.check_circle_rounded,
                          key: ValueKey('selected'),
                          size: AppSizes.iconSm,
                          color: AppColors.primaryDark,
                        )
                      : const SizedBox(key: ValueKey('unselected'), height: AppSizes.iconSm),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
