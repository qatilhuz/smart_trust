import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

/// Step 1 of the forgot-password flow: collect the account phone number and
/// request the reset code (POST /api/v1/auth/forgot-password/init).
class ForgotPasswordInitScreen extends ConsumerStatefulWidget {
  const ForgotPasswordInitScreen({super.key});

  @override
  ConsumerState<ForgotPasswordInitScreen> createState() =>
      _ForgotPasswordInitScreenState();
}

class _ForgotPasswordInitScreenState
    extends ConsumerState<ForgotPasswordInitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  /// True from tap until the BE response is fully handled — guarantees a
  /// single init call and keeps the button in its loading state meanwhile.
  bool _isSubmitting = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // Guard: a request is already in flight.
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _isSubmitting = true);
    try {
      final ok = await ref
          .read(authStateProvider.notifier)
          .forgotPasswordInit(phone: _phoneController.text.trim());
      if (!mounted) return;
      if (ok) {
        ref.read(forgotPasswordPhoneProvider.notifier).state =
            _phoneController.text.trim();
        context.push(RouteNames.resetPassword);
      }
      // Failures surface through authState.hasError as a localized banner.
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final showLoading = _isSubmitting || authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.forgotPasswordTitle),
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: showLoading ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.md,
              AppSpacing.xxl,
              AppSpacing.section,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      title: l10n.forgotPasswordTitle,
                      subtitle: l10n.forgotPasswordSubtitle,
                      icon: Icons.lock_reset_rounded,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    AppTextField(
                      controller: _phoneController,
                      label: l10n.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      enabled: !showLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (!RegExp(
                          r'^(?:03\d{9}|\+923\d{9})$',
                        ).hasMatch(value.trim())) {
                          return l10n.invalidPhone;
                        }
                        return null;
                      },
                    ),
                    if (authState.hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      _FlowMessage(
                        message: l10n.forgotPasswordError,
                        icon: Icons.error_outline_rounded,
                        color: AppColors.error,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: l10n.sendResetCode,
                      isEnabled: !showLoading,
                      isLoading: showLoading,
                      onPressed: _submit,
                    ),
                    SizedBox(height: AppSizes.buttonHeightSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Shared inline banner for flow-level (localized) messages.
class _FlowMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _FlowMessage({
    required this.message,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: color.withOpacity(.22)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: AppSizes.iconSm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}
