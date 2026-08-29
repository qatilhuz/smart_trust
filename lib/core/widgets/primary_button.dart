import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_sizes.dart';
import '../constants/app_spacing.dart';
import 'morphing_spinner.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isEnabled;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = isEnabled && !isLoading;
    return SizedBox(
      height: AppSizes.buttonHeight,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: AppColors.primary.withOpacity(.45),
          disabledForegroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.buttonPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: isLoading
              ? MorphingSpinner(
                  key: const ValueKey('loading'),
                  size: AppSizes.iconSm,
                  strokeWidth: 2.2,
                  color: AppColors.white,
                )
              : Text(label, key: ValueKey(label)),
        ),
      ),
    );
  }
}
