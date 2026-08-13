import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';

class RoleSelectionScreen extends ConsumerWidget {
  const RoleSelectionScreen({super.key});

  Future<void> _selectRole(BuildContext context, String role, String route) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
    if (context.mounted) context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.section),
              Text(l10n.selectRoleShort, style: AppTextStyles.heading2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.section),
              _RoleButton(
                icon: Icons.search_rounded,
                label: l10n.customerRole,
                onPressed: () => _selectRole(context, 'customer', RouteNames.login),
              ),
              const SizedBox(height: AppSpacing.md),
              _RoleButton(
                icon: Icons.engineering_rounded,
                label: l10n.providerRole,
                onPressed: () => _selectRole(context, 'provider', RouteNames.providerRegistration),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _RoleButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeightLarge,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primaryDark),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.secondary,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusLg)),
        ),
      ),
    );
  }
}
