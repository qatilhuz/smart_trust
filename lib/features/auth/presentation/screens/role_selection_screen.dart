import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/role_selector.dart';

class AuthRoleSelectionScreen extends ConsumerWidget {
  const AuthRoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final selectedRole = ref.watch(signupRoleProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.selectRoleShort)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.chooseAccountRole,
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.signupSubtitle,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  RoleSelector(
                    selectedRole: selectedRole,
                    onRoleChanged: (role) => ref
                        .read(signupRoleProvider.notifier)
                        .state = role,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  PrimaryButton(
                    label: l10n.continueButton,
                    isEnabled: selectedRole != null,
                    onPressed: () => context.push(RouteNames.signup),
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
