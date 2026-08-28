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
import '../../domain/entities/auth_entities.dart';
import '../widgets/auth_header.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final init = await ref.read(authStateProvider.notifier).registerInit(
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          fullName: _nameController.text.trim(),
        );

    if (!mounted || init == null) return;
    ref.read(pendingRegistrationProvider.notifier).state = PendingRegistration(
      phone: init.phone,
    );
    context.push(RouteNames.otp);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.signupTitle),
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: () => context.pop(),
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
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      title: l10n.signupTitle,
                      subtitle: l10n.signupSubtitle,
                      icon: Icons.person_add_alt_1_rounded,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    AppTextField(
                      controller: _nameController,
                      label: l10n.name,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (value) {
                        final name = value?.trim() ?? '';
                        if (name.isEmpty) return l10n.requiredField;
                        if (name.length < 2 || name.length > 120) return l10n.requiredField;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _phoneController,
                      label: l10n.phone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return l10n.requiredField;
                        }
                        if (!RegExp(r'^(?:03\d{9}|\+923\d{9})$').hasMatch(value.trim())) return l10n.invalidPhone;
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _emailController,
                      label: l10n.email,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      textInputAction: TextInputAction.next,
                      enabled: !isLoading,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
                        return email.length > 190 || !valid ? l10n.invalidEmail : null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _passwordController,
                      label: l10n.password,
                      obscureText: _obscurePassword,
                      prefixIcon: const Icon(Icons.key_rounded),
                      textInputAction: TextInputAction.done,
                      enabled: !isLoading,
                      suffixIcon: IconButton(
                        tooltip: l10n.password,
                        onPressed: isLoading
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
                        if (value == null || value.isEmpty) return l10n.requiredField;
                        if (value.length < 8 || value.length > 100 ||
                            !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(value)) {
                          return l10n.invalidPassword;
                        }
                        return null;
                      },
                    ),
                    if (authState.hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      _AuthError(message: l10n.signupError),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: l10n.signup,
                      isEnabled: !isLoading,
                      isLoading: isLoading,
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

class _AuthError extends StatelessWidget {
  final String message;

  const _AuthError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withOpacity(.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(message, style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
  }
}
