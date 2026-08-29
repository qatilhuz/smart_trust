import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trust_app/core/widgets/primary_button.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const _digitCount = 6;

  final List<TextEditingController> _controllers =
      List.generate(_digitCount, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_digitCount, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _isVerifying = false;
  bool _success = false;
  bool _hasError = false;

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (_hasError) setState(() => _hasError = false);
    if (value.length == 1 && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Future<void> _verify(AppLocalizations l10n) async {
    final pending = ref.read(pendingRegistrationProvider);
    final code = _controllers.map((controller) => controller.text).join();
    if (pending == null || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _hasError = true);
      _showMessage(l10n.otpRequired);
      return;
    }
    setState(() { _isVerifying = true; _hasError = false; });
    await ref.read(authStateProvider.notifier).verifyOtp(phone: pending.phone, otp: code);
    if (!mounted) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      setState(() { _isVerifying = false; _success = true; });
      ref.read(pendingRegistrationProvider.notifier).state = null;
      await Future<void>.delayed(const Duration(milliseconds: 450));
      if (mounted) context.go(RouteNames.roleSelection);
    } else {
      setState(() { _isVerifying = false; _hasError = true; });
      _showMessage(l10n.invalidCode);
    }
  }

  String _destinationFor(UserEntity? user, String role) {
    final resolved = user?.role.isNotEmpty == true ? user!.role : role;
    return resolved.toLowerCase().contains('provider') ? RouteNames.providerFeed : RouteNames.customerHome;
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_resendSeconds <= 1) {
        timer.cancel();
        setState(() => _resendSeconds = 0);
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  Future<void> _resend() async {
    final pending = ref.read(pendingRegistrationProvider);
    if (pending == null || _resendSeconds > 0 || _isVerifying) return;
    final ok = await ref.read(authStateProvider.notifier).resendOtp(pending.phone);
    if (!mounted) return;
    if (ok) {
      for (final controller in _controllers) { controller.clear(); }
      _hasError = false;
      _focusNodes.first.requestFocus();
      _startResendCountdown();
    } else {
      _showMessage(AppLocalizations.of(context)!.unknownError);
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

    if (_success) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(
          child: _SuccessState(message: l10n.verificationSuccess),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.otpVerification),
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: _isVerifying ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _OtpHero(),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    l10n.enterOtp,
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.otpSubtitle,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - AppSpacing.md * 3) / 4;
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _digitCount,
                          (index) => Padding(
                            padding: EdgeInsets.only(
                              right: index == _digitCount - 1 ? 0 : AppSpacing.md,
                            ),
                            child: SizedBox(
                              width: width.clamp(AppSizes.buttonHeightSmall, 72.0).toDouble(),
                              height: AppSizes.buttonHeightLarge,
                              child: _OtpDigit(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                hasError: _hasError,
                                onChanged: (value) => _onChanged(index, value),
                                onBackspace: () {
                                  if (_controllers[index].text.isEmpty && index > 0) {
                                    _focusNodes[index - 1].requestFocus();
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  if (_hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.invalidCode,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: l10n.verify,
                    isEnabled: !_isVerifying,
                    isLoading: _isVerifying,
                    onPressed: () => _verify(l10n),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextButton(
                    onPressed: _resendSeconds == 0 && !_isVerifying ? _resend : null,
                    child: Text(
                      _resendSeconds == 0
                          ? l10n.resendCode
                          : l10n.resendIn(_resendSeconds),
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

class _OtpHero extends StatelessWidget {
  const _OtpHero();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: AppSizes.avatarLarge + AppSpacing.xxl,
        height: AppSizes.avatarLarge + AppSpacing.xxl,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withOpacity(.10),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: const Icon(
          Icons.mark_email_read_rounded,
          color: AppColors.primaryDark,
          size: AppSizes.iconXl,
        ),
      ),
    );
  }
}

class _OtpDigit extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpDigit({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<_OtpDigit> createState() => _OtpDigitState();
}

class _OtpDigitState extends State<_OtpDigit> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant _OtpDigit oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_handleFocus);
      widget.focusNode.addListener(_handleFocus);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocus);
    super.dispose();
  }

  void _handleFocus() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final focused = widget.focusNode.hasFocus;
    final filled = widget.controller.text.isNotEmpty;
    final borderColor = widget.hasError
        ? AppColors.error
        : focused || filled
            ? AppColors.primary
            : AppColors.border;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: focused ? AppColors.primary.withOpacity(.07) : AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(
          color: borderColor,
          width: focused ? AppSizes.borderWidthFocused : AppSizes.borderWidth,
        ),
        boxShadow: focused
            ? [
                BoxShadow(
                  color: AppColors.primary.withOpacity(.16),
                  blurRadius: AppSpacing.md,
                  offset: const Offset(0, AppSpacing.xs),
                ),
              ]
            : null,
      ),
      child: Focus(
        onKeyEvent: (node, event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              widget.controller.text.isEmpty) {
            widget.onBackspace();
            return KeyEventResult.handled;
          }
          return KeyEventResult.ignored;
        },
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.heading2.copyWith(color: AppColors.secondary),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) {
            setState(() {});
            widget.onChanged(value);
          },
        ),
      ),
    );
  }
}

class _SuccessState extends StatelessWidget {
  final String message;

  const _SuccessState({required this.message});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: .75, end: 1),
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 96),
          const SizedBox(height: AppSpacing.xxl),
          Text(message, style: AppTextStyles.heading2, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}