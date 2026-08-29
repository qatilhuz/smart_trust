import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// A responsive row of unified single-digit code boxes.
///
/// Same visual contract as the auth OTP screen — exactly ONE boundary per
/// digit (the theme's inner outlined box/fill is neutralized), focus, error,
/// and locked states all live on this single boundary — generalized so any
/// flow that collects a verification code can reuse it.
class OtpDigitsField extends StatefulWidget {
  final int digitCount;

  /// Reports the joined code (e.g. "123456") whenever any digit changes.
  final ValueChanged<String> onChanged;

  /// While false every box is read-only and cannot take focus.
  final bool enabled;
  final bool hasError;

  const OtpDigitsField({
    super.key,
    this.digitCount = 6,
    required this.onChanged,
    this.enabled = true,
    this.hasError = false,
  });

  @override
  State<OtpDigitsField> createState() => _OtpDigitsFieldState();
}

class _OtpDigitsFieldState extends State<OtpDigitsField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.digitCount, (_) => TextEditingController());
    _focusNodes = List.generate(widget.digitCount, (_) => FocusNode());
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _notify() =>
      widget.onChanged(_controllers.map((controller) => controller.text).join());

  ({double boxWidth, double gap}) _resolveMetrics(double availableWidth) {
    const boxMax = 72.0;
    const boxMin = AppSizes.buttonHeightSmall;
    var gap = AppSpacing.md;
    var boxWidth = (availableWidth - gap * (widget.digitCount - 1)) /
        widget.digitCount;
    if (boxWidth < boxMin) {
      gap = (availableWidth - boxMin * widget.digitCount) /
          (widget.digitCount - 1);
      gap = gap < AppSpacing.xs ? AppSpacing.xs : gap;
      boxWidth =
          (availableWidth - gap * (widget.digitCount - 1)) / widget.digitCount;
    }
    return (
      boxWidth: boxWidth > boxMax ? boxMax : (boxWidth < 24 ? 24 : boxWidth),
      gap: gap,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final metrics = _resolveMetrics(constraints.maxWidth);
        return SizedBox(
          width: double.infinity,
          height: AppSizes.buttonHeightLarge,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.digitCount,
              (index) => Padding(
                padding: EdgeInsets.only(
                  right: index == widget.digitCount - 1 ? 0 : metrics.gap,
                ),
                child: SizedBox(
                  width: metrics.boxWidth,
                  height: AppSizes.buttonHeightLarge,
                  child: _CodeDigitBox(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    hasError: widget.hasError,
                    enabled: widget.enabled,
                    isLast: index == widget.digitCount - 1,
                    onChanged: (value) => _handleInput(index, value),
                    onBackspace: () {
                      if (_controllers[index].text.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleInput(int index, String value) {
    if (value.length == 1 && index < widget.digitCount - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    _notify();
  }
}

class _CodeDigitBox extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool hasError;
  final bool enabled;
  final bool isLast;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _CodeDigitBox({
    required this.controller,
    required this.focusNode,
    required this.hasError,
    required this.enabled,
    required this.isLast,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  State<_CodeDigitBox> createState() => _CodeDigitBoxState();
}

class _CodeDigitBoxState extends State<_CodeDigitBox> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(covariant _CodeDigitBox oldWidget) {
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
        canRequestFocus: widget.enabled,
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
          enabled: widget.enabled,
          showCursor: widget.enabled,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          textInputAction: widget.isLast
              ? TextInputAction.done
              : TextInputAction.next,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppTextStyles.heading2.copyWith(color: AppColors.secondary),
          decoration: const InputDecoration(
            counterText: '',
            // Neutralize every InputDecorationTheme override so the theme
            // never paints a second inner box (single unified boundary).
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
