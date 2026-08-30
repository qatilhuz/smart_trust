import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trust_app/core/widgets/primary_button.dart';

import '../../../../core/widgets/morphing_spinner.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/auth_provider.dart';

/// Masks an email for secure display, e.g.
/// `huzpubgkhahhn@gmail.com` -> `huz***@gmail.com`.
///
/// Robust across lengths: a local part longer than 3 keeps its first 3
/// characters, a shorter one keeps only its first character (the full
/// local part is never shown), the domain is preserved verbatim, and
/// empty/malformed input degrades safely (null or a fully masked form)
/// so callers can hide the row instead of leaking the address.
String? _maskEmail(String? email) {
  final value = email?.trim() ?? '';
  if (value.isEmpty) return null;
  final at = value.lastIndexOf('@');
  final String local;
  final String domain;
  if (at < 0) {
    // No '@' (malformed): mask everything, revealing at most 3 chars.
    local = value;
    domain = '';
  } else {
    local = value.substring(0, at);
    domain = value.substring(at); // includes '@'
  }
  if (local.isEmpty) return '***$domain';
  final head = local.length <= 3
      ? local.substring(0, 1)
      : local.substring(0, 3);
  return '$head***$domain';
}

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen>
    with TickerProviderStateMixin {
  static const _digitCount = 6;

  final List<TextEditingController> _controllers =
      List.generate(_digitCount, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_digitCount, (_) => FocusNode());
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _isVerifying = false;
  /// True while a resend-OTP request is in flight; locks the button and
  /// shows the inline spinner until the BE response is fully received.
  bool _isResending = false;
  bool _success = false;
  bool _hasError = false;

  /// Drives the "merge into a single glowing core" morph while the code is
  /// being verified. 0 = six separate boxes, 1 = fully merged core.
  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  late final CurvedAnimation _morphCurve = CurvedAnimation(
    parent: _morph,
    curve: Curves.easeInOutCubic,
    reverseCurve: Curves.easeOutCubic,
  );

  /// Loops while waiting for the backend response so the merged core keeps
  /// breathing/glowing instead of sitting static.
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  );

  @override
  void dispose() {
    _resendTimer?.cancel();
    _morphCurve.dispose();
    _morph.dispose();
    _pulse.dispose();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  bool get _isCodeComplete =>
      _controllers.every((controller) => controller.text.length == 1);

  void _onChanged(int index, String value) {
    if (_hasError) setState(() => _hasError = false);
    if (value.length == 1 && index < _digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Futuristic auto-submit: as soon as the last digit lands, the merge
    // animation and verification start without needing the button press.
    if (_isCodeComplete && !_isVerifying && ref.read(pendingRegistrationProvider) != null) {
      final l10n = AppLocalizations.of(context);
      if (l10n != null) _verify(l10n);
    }
  }

  Future<void> _verify(AppLocalizations l10n) async {
    if (_isVerifying) return; // Guard: a verification is already in flight.
    final pending = ref.read(pendingRegistrationProvider);
    final code = _controllers.map((controller) => controller.text).join();
    if (pending == null || !RegExp(r'^\d{6}$').hasMatch(code)) {
      setState(() => _hasError = true);
      _showMessage(l10n.otpRequired);
      return;
    }
    // Drop the keyboard so the morph is fully visible, lock every input,
    // then run the merge animation and the API call concurrently.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isVerifying = true;
      _hasError = false;
    });
    _pulse.repeat();
    final verification = ref
        .read(authStateProvider.notifier)
        .verifyOtp(phone: pending.phone, otp: code);
    await Future.wait<void>([_morph.forward(), verification]);
    if (!mounted) return;
    final user = ref.read(authStateProvider).valueOrNull;
    if (user != null) {
      setState(() {
        _isVerifying = false;
        _success = true;
      });
      ref.read(pendingRegistrationProvider.notifier).state = null;
      // Role-isolated landing: providers continue their onboarding flow at
      // step 1 (profile form); customers go to their profile completion.
      final isProvider = user.role.toLowerCase().contains('provider');
      if (mounted) {
        context.go(
          isProvider ? RouteNames.providerProfileForm : RouteNames.customerProfile,
        );
      }
    } else {
      setState(() {
        _isVerifying = false;
        _hasError = true;
      });
      _pulse
        ..stop()
        ..reset();
      await _morph.reverse();
      if (mounted) {
        _focusNodes.first.requestFocus();
        _showMessage(l10n.invalidCode);
      }
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
    if (pending == null ||
        _resendSeconds > 0 ||
        _isVerifying ||
        _isResending) {
      return;
    }
    setState(() => _isResending = true);
    try {
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
    } finally {
      // Released only after the BE response is fully received.
      if (mounted) setState(() => _isResending = false);
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
    // Email captured at registration, masked for secure display.
    final maskedEmail =
        _maskEmail(ref.watch(pendingRegistrationProvider)?.email);

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
                  if (maskedEmail != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      maskedEmail!,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.section),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final metrics = _resolveOtpMetrics(constraints.maxWidth);
                      return _buildMorphingOtpRow(
                        boxWidth: metrics.boxWidth,
                        gap: metrics.gap,
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
                    onPressed: _resendSeconds == 0 &&
                            !_isVerifying &&
                            !_isResending
                        ? _resend
                        : null,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isResending) ...[
                          const MorphingSpinner(
                            size: AppSizes.iconXs,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          _resendSeconds == 0
                              ? l10n.resendCode
                              : l10n.resendIn(_resendSeconds),
                        ),
                      ],
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

  /// Responsive sizing for the OTP cells.
  ///
  /// The row is [AppSizes.buttonHeightLarge] tall and must fit
  /// [availableWidth] exactly: 6 cells plus 5 gaps. The preferred layout uses
  /// the [AppSpacing.md] gap with cells capped at 72; on narrow viewports the
  /// gaps compress down to [AppSpacing.xs] first so the cells keep a
  /// comfortable touch target instead of overflowing. Below that floor the
  /// cells shrink rather than exceed the viewport, so a horizontal overflow is
  /// impossible at any width (phone, split-screen, or web pane).
  ({double boxWidth, double gap}) _resolveOtpMetrics(double availableWidth) {
    const boxMax = 72.0;
    const boxMin = AppSizes.buttonHeightSmall;
    var gap = AppSpacing.md;
    var boxWidth = (availableWidth - gap * (_digitCount - 1)) / _digitCount;
    if (boxWidth < boxMin) {
      gap = math.max(
        AppSpacing.xs,
        (availableWidth - boxMin * _digitCount) / (_digitCount - 1),
      );
      boxWidth = (availableWidth - gap * (_digitCount - 1)) / _digitCount;
    }
    return (boxWidth: math.min(boxMax, math.max(24.0, boxWidth)), gap: gap);
  }

  /// The six OTP cells plus the merged glowing "verification core".
  ///
  /// While verifying, each cell translates toward the row center, scales and
  /// fades out, and the core scales in with a breathing glow and an embedded
  /// spinner — a single futuristic element representing the code being
  /// checked. On failure the whole morph reverses back to the six cells.
  Widget _buildMorphingOtpRow({
    required double boxWidth,
    required double gap,
  }) {
    final pitch = boxWidth + gap;
    // Keep physical placement consistent with the flow direction so the
    // digit order matches the Row this replaces in RTL locales (ur).
    return SizedBox(
      width: double.infinity,
      height: AppSizes.buttonHeightLarge,
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphCurve, _pulse]),
        builder: (context, _) {
          final t = _morphCurve.value.clamp(0.0, 1.0);
          final merge = 1 - t;
          final pulse = math.sin(_pulse.value * 2 * math.pi) * .5 + .5;
          final rtl = Directionality.of(context) == TextDirection.rtl;
          final direction = rtl ? -1.0 : 1.0;
          return Stack(
            alignment: Alignment.center,
            children: [
              // Merged, glowing verification core with an embedded spinner.
              IgnorePointer(
                ignoring: true,
                child: Opacity(
                  opacity: t,
                  child: Transform.scale(
                    scale: math.max(0.0, Curves.easeOutBack.transform(t)),
                    child: _MergedOtpCore(
                      width: math.max(boxWidth + AppSpacing.lg, 64.0),
                      pulse: pulse,
                    ),
                  ),
                ),
              ),
              // The six cells collapsing into the core.
              for (var i = 0; i < _digitCount; i++)
                Transform.translate(
                  offset: Offset(
                    direction * (i - (_digitCount - 1) / 2) * pitch * merge,
                    0,
                  ),
                  child: Opacity(
                    opacity: merge,
                    child: Transform.scale(
                      scale: 1 - .85 * t,
                      child: SizedBox(
                        width: boxWidth,
                        height: AppSizes.buttonHeightLarge,
                        child: _OtpDigit(
                          controller: _controllers[i],
                          focusNode: _focusNodes[i],
                          hasError: _hasError,
                          locked: _isVerifying,
                          onChanged: (value) => _onChanged(i, value),
                          onBackspace: () {
                            if (_controllers[i].text.isEmpty && i > 0) {
                              _focusNodes[i - 1].requestFocus();
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
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

  /// True while the backend call is in flight: the cell becomes read-only,
  /// cannot take focus, and shows no cursor — preventing duplicate input or
  /// a second submission while the morph plays.
  final bool locked;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpDigit({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.onChanged,
    required this.onBackspace,
    this.locked = false,
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
        canRequestFocus: !widget.locked,
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
          enabled: !widget.locked,
          showCursor: !widget.locked,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.heading2.copyWith(color: AppColors.secondary),
          decoration: const InputDecoration(
            counterText: '',
            // Neutralize every InputDecorationTheme override so the
            // TextField contributes ZERO chrome of its own (the theme
            // paints an inner outlined box + fill inside the container,
            // producing the old "box inside a box"). The outer
            // AnimatedContainer is now the single unified boundary
            // carrying focus, filled, error, and locked states.
            filled: false,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            isDense: true,
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

/// The single glowing element the six OTP cells merge into while the code is
/// verified. Uses the SmartTrust brand gradient (primaryLight -> primary ->
/// primaryDark) and the same white spinner convention as [PrimaryButton].
class _MergedOtpCore extends StatelessWidget {
  final double width;
  final double pulse; // 0..1 breathing phase driven by the pulse controller.

  const _MergedOtpCore({
    required this.width,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: AppSizes.buttonHeightLarge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryLight,
            AppColors.primary,
            AppColors.primaryDark,
          ],
        ),
        border: Border.all(
          color: AppColors.primaryLight.withOpacity(.85),
          width: AppSizes.borderWidth,
        ),
        boxShadow: [
          // Wide ambient halo that breathes with the pulse.
          BoxShadow(
            color: AppColors.primary.withOpacity(.26 + .22 * pulse),
            blurRadius: AppSpacing.xxl + AppSpacing.lg * pulse,
            spreadRadius: AppSpacing.xs + 2 * pulse,
            offset: const Offset(0, AppSpacing.sm),
          ),
          // Tight inner halo for a crisp energy edge.
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(.30 + .25 * pulse),
            blurRadius: AppSpacing.lg,
            spreadRadius: -1 + 2 * pulse,
          ),
        ],
      ),
      child: const Center(
        child: SizedBox(
          width: AppSizes.iconMd,
          height: AppSizes.iconMd,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.white,
          ),
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