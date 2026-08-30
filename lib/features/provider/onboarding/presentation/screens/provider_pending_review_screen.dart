import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../l10n/app_localizations.dart';

/// Mandatory "Pending Review" screen for service providers whose
/// verificationStatus is not APPROVED yet.
///
/// Navigation to every home surface is blocked by the router gate while this
/// state is active; this screen itself is a terminal, back-free destination
/// with a continuous premium radar animation.
class ProviderPendingReviewScreen extends StatefulWidget {
  const ProviderPendingReviewScreen({super.key});

  @override
  State<ProviderPendingReviewScreen> createState() =>
      _ProviderPendingReviewScreenState();
}

class _ProviderPendingReviewScreenState
    extends State<ProviderPendingReviewScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radar = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );

  @override
  void initState() {
    super.initState();
    _radar.repeat();
  }

  @override
  void dispose() {
    _radar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: AnimatedBuilder(
                      animation: _radar,
                      builder: (context, _) => CustomPaint(
                        painter: _RadarPainter(progress: _radar.value),
                        child: Center(
                          child: _PulsingCore(progress: _radar.value),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Text(
                    l10n.verificationPending,
                    style: AppTextStyles.heading2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Text(
                      l10n.pendingReviewSubtitle,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(.12),
                      borderRadius:
                          BorderRadius.circular(AppSizes.radiusPill),
                      border: Border.all(
                        color: AppColors.warning.withOpacity(.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.admin_panel_settings_rounded,
                          size: AppSizes.iconSm,
                          color: AppColors.warning,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          l10n.adminReview,
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.textPrimary,
                          ),
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
}

/// Smooth pulsing radar: expanding fading rings plus a rotating sweep beam.
class _RadarPainter extends CustomPainter {
  final double progress; // 0..1 looping

  const _RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2 - AppSpacing.sm;

    // Expanding rings — three staggered pulses.
    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1;
      final radius = AppSizes.avatarMedium / 2 +
          t * (maxRadius - AppSizes.avatarMedium / 2);
      final ring = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 + 1.5 * (1 - t)
        ..color = AppColors.primary.withOpacity((1 - t) * .45);
      canvas.drawCircle(center, radius, ring);
    }

    // Static guide circles for depth.
    final guide = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.border;
    canvas.drawCircle(center, maxRadius, guide);
    canvas.drawCircle(center, maxRadius * .62, guide);

    // Rotating sweep beam.
    final sweepRect = Rect.fromCircle(center: center, radius: maxRadius);
    final sweepAngle = progress * 2 * math.pi;
    final sweep = Paint()
      ..shader = SweepGradient(
        startAngle: sweepAngle,
        endAngle: sweepAngle + math.pi / 2,
        colors: [
          AppColors.primary.withOpacity(0),
          AppColors.primary.withOpacity(.30),
        ],
        tileMode: TileMode.clamp,
      ).createShader(sweepRect);
    canvas.drawCircle(center, maxRadius, sweep);
  }

  @override
  bool shouldRepaint(_RadarPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

/// Glowing center core that gently breathes with the radar loop.
class _PulsingCore extends StatelessWidget {
  final double progress;

  const _PulsingCore({required this.progress});

  @override
  Widget build(BuildContext context) {
    final breath = math.sin(progress * 2 * math.pi) * .5 + .5;
    return Container(
      width: AppSizes.avatarMedium + breath * 6,
      height: AppSizes.avatarMedium + breath * 6,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(.16 + breath * .08),
        border: Border.all(
          color: AppColors.primary.withOpacity(.5 + breath * .3),
          width: AppSizes.borderWidthFocused,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(.20 + breath * .18),
            blurRadius: AppSpacing.xl + breath * AppSpacing.lg,
            spreadRadius: breath * 2,
          ),
        ],
      ),
      child: const Icon(
        Icons.verified_user_rounded,
        color: AppColors.primaryDark,
        size: AppSizes.iconLg,
      ),
    );
  }
}
