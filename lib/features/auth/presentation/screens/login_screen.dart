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
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(authStateProvider.notifier).login(
          phone: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (!mounted) return;
    final state = ref.read(authStateProvider);
    final user = state.valueOrNull;
    if (user != null) {
      context.go(_destinationFor(user));
    }
  }

  String _destinationFor(UserEntity user) {
    if (user.role.isEmpty) return RouteNames.roleSelection;
    return user.role.toLowerCase() == 'provider'
        ? RouteNames.providerFeed
        : RouteNames.customerHome;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Stack(
          children: [
            PositionedDirectional(
              top: AppSpacing.sm,
              end: AppSpacing.lg,
              child: Semantics(
                button: true,
                label: l10n.continueAsGuest,
                child: IconButton(
                  onPressed: isLoading ? null : () => context.go(RouteNames.customerHome),
                  tooltip: l10n.continueAsGuest,
                  icon: const Icon(Icons.close_rounded),
                  color: AppColors.secondary,
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AuthHeader(
                      title: l10n.loginTitle,
                      subtitle: l10n.loginSubtitle,
                      icon: Icons.lock_open_rounded,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    AppTextField(
                      controller: _emailController,
                      label: l10n.phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
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
                      controller: _passwordController,
                      label: l10n.password,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.done,
                      prefixIcon: const Icon(Icons.key_rounded),
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
                        final password = value ?? '';
                        if (password.isEmpty) return l10n.requiredField;
                        if (password.length < 8 || password.length > 100 ||
                            !RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).+$').hasMatch(password)) {
                          return l10n.invalidPassword;
                        }
                        return null;
                      },
                    ),
                    if (authState.hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      _AuthMessage(
                        message: l10n.loginError,
                        icon: Icons.error_outline_rounded,
                        color: AppColors.error,
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: l10n.login,
                      isEnabled: !isLoading,
                      isLoading: isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            l10n.signUpPrompt,
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.end,
                          ),
                        ),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => context.push(RouteNames.roleSelection),
                          child: Text(l10n.signup),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSizes.buttonHeightSmall),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AuthMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color color;

  const _AuthMessage({
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
          Expanded(child: Text(message, style: TextStyle(color: color))),
        ],
      ),
    );
  }
}
