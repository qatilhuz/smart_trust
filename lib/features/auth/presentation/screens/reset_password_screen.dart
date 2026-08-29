import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/otp_digits_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

/// Step 2 of the forgot-password flow: collect the OTP and the new password,
/// then POST /api/v1/auth/forgot-password/reset. On success plays a smooth
/// animated confirmation and returns the user to the Login screen.
class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  String _code = '';
  bool _hasInvalidCode = false;

  /// True from tap until the BE response is fully handled.
  bool _isSubmitting = false;
  bool _success = false;

  String? _phone;

  @override
  void initState() {
    super.initState();
    // The phone travels from the init step via forgotPasswordPhoneProvider;
    // if this screen was reached without it, bounce back gracefully.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final phone = ref.read(forgotPasswordPhoneProvider);
      if (phone == null || phone.isEmpty) {
        context.go(RouteNames.forgotPassword);
      } else {
        setState(() => _phone = phone);
      }
    });
  }

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // Guard: a request is already in flight.
    if (_code.length != 6) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() => _hasInvalidCode = true);
      _showMessage(AppLocalizations.of(context)!.otpRequired);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSubmitting = true;
      _hasInvalidCode = false;
    });
    try {
      final ok = await ref.read(authStateProvider.notifier).forgotPasswordReset(
            phone: _phone!,
            otp: _code,
            newPassword: _passwordController.text,
          );
      if (!mounted) return;
      if (ok) {
        ref.read(forgotPasswordPhoneProvider.notifier).state = null;
        setState(() {
          _isSubmitting = false;
          _success = true;
        });
        // Let the success animation breathe, then land on Login.
        await Future<void>.delayed(const Duration(milliseconds: 1100));
        if (mounted) context.go(RouteNames.login);
      }
      // Failures surface through authState.hasError as a localized banner.
    } finally {
      if (mounted && !_success) setState(() => _isSubmitting = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final showLoading = _isSubmitting || authState.isLoading;

    if (_success) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: _ResetSuccess(message: l10n.passwordResetSuccess),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.resetPasswordTitle),
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
                      title: l10n.resetPasswordTitle,
                      subtitle: l10n.resetPasswordSubtitle,
                      icon: Icons.password_rounded,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    OtpDigitsField(
                      onChanged: (code) {
                        if (_hasInvalidCode) {
                          setState(() => _hasInvalidCode = false);
                        }
                        _code = code;
                      },
                      enabled: !showLoading,
                      hasError: _hasInvalidCode || authState.hasError,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _passwordController,
                      label: l10n.newPassword,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.key_rounded),
                      enabled: !showLoading,
                      suffixIcon: IconButton(
                        tooltip: l10n.password,
                        onPressed: showLoading
                            ? null
                            : () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                        ),
                      ),
                      validator: (value) {
                        final password = value ?? '';
                        if (password.isEmpty) return l10n.requiredField;
                        if (password.length < 8 ||
                            password.length > 100 ||
                            !RegExp(
                              r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$',
                            ).hasMatch(password)) {
                          return l10n.invalidPassword;
                        }
                        return null;
                      },
                    ),
                    if (authState.hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      _ResetMessage(
                        message: l10n.invalidCode,
                        icon: Icons.error_outline_rounded,
                        color: AppColors.error,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: l10n.resetPassword,
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

class _ResetMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _ResetMessage({
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

/// Smooth animated confirmation shown after a successful reset.
class _ResetSuccess extends StatelessWidget {
  final String message;

  const _ResetSuccess({required this.message});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .4, end: 1),
      duration: const Duration(milliseconds: 480),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(
        scale: scale,
        child: Opacity(opacity: scale.clamp(0, 1), child: child),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.success,
            size: 96,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(message, style: AppTextStyles.heading2, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
