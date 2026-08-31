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
/// with a continuous premium verification animation: a glowing CNIC document
/// being scanned line by line (checks landing with a pop), wrapped in a
/// breathing radar halo and a slowly orbiting dashed ring.
class ProviderPendingReviewScreen extends StatefulWidget {
  const ProviderPendingReviewScreen({super.key});

  @override
  State<ProviderPendingReviewScreen> createState() =>
      _ProviderPendingReviewScreenState();
}

class _ProviderPendingReviewScreenState
    extends State<ProviderPendingReviewScreen> with TickerProviderStateMixin {
  /// Master loop driving the scan, the staggered checks, the radar pulses,
  /// and the breathing glow.
  late final AnimationController _master = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  );

  /// Slow continuous rotation for the outer dashed orbit ring.
  late final AnimationController _orbit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 9000),
  );

  @override
  void initState() {
    super.initState();
    _master.repeat();
    _orbit.repeat();
  }

  @override
  void dispose() {
    _master.dispose();
    _orbit.dispose();
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
                    width: 280,
                    height: 280,
                    child: RepaintBoundary(
                      child: AnimatedBuilder(
                        animation:
                            Listenable.merge([_master, _orbit]),
                        builder: (context, _) => CustomPaint(
                          painter: _DocumentVerifyPainter(
                            progress: _master.value,
                            orbit: _orbit.value,
                          ),
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
                      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
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

double _easeOutBack(double t) {
  const c1 = 1.70158;
  const c3 = c1 + 1;
  final p3 = math.pow(t - 1, 3).toDouble();
  final p2 = math.pow(t - 1, 2).toDouble();
  return 1 + c3 * p3 + c1 * p2;
}

double _clamp01(double value) => value.clamp(0.0, 1.0);

/// The premium verification composition.
///
/// Phases of [progress] (one 4200 ms loop):
///   0.00–0.58  scan beam sweeps the document top -> bottom
///   0.30/0.42/0.54  the three field checks pop in (easeOutBack), then hold
///   0.86–1.00  checks and glow gently fade so the loop restarts cleanly
///   full loop  staggered radar rings + breathing glow; the dashed orbit
///              ring rotates continuously on its own slower controller.
class _DocumentVerifyPainter extends CustomPainter {
  final double progress;
  final double orbit;

  const _DocumentVerifyPainter({
    required this.progress,
    required this.orbit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final breath = math.sin(progress * 2 * math.pi) * .5 + .5;
    final fadeOut = 1 - _clamp01((progress - .86) / .14);

    _paintGlow(canvas, size, center, breath);
    _paintRadarRings(canvas, center, size);
    _paintOrbitDashes(canvas, center, size);
    _paintDocument(canvas, center, breath, fadeOut);
    _paintScanBeam(canvas, center, fadeOut);
    _paintFieldChecks(canvas, center, fadeOut);
  }

  void _paintGlow(Canvas canvas, Size size, Offset center, double breath) {
    final rect = Rect.fromCircle(
      center: center,
      radius: size.shortestSide / 2 - AppSpacing.xs,
    );
    canvas.drawCircle(
      center,
      rect.width / 2,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withOpacity(.16 + .10 * breath),
            AppColors.primary.withOpacity(0),
          ],
        ).createShader(rect),
    );
  }

  void _paintRadarRings(Canvas canvas, Offset center, Size size) {
    final maxRadius = size.shortestSide / 2 - AppSpacing.lg;
    for (var i = 0; i < 3; i++) {
      final t = (progress + i / 3) % 1;
      final radius =
          AppSizes.avatarLarge / 2 + t * (maxRadius - AppSizes.avatarLarge / 2);
      canvas.drawCircle(
        center,
        radius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5 + 1.5 * (1 - t)
          ..color = AppColors.primary.withOpacity((1 - t) * .38),
      );
    }
  }

  void _paintOrbitDashes(Canvas canvas, Offset center, Size size) {
    final radius = size.shortestSide / 2 - AppSpacing.xs;
    final dashCount = 36;
    final sweep = 2 * math.pi / dashCount;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = AppColors.primaryLight.withOpacity(.55);
    for (var i = 0; i < dashCount; i++) {
      final start = orbit * 2 * math.pi + i * sweep;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep * .45,
        false,
        paint,
      );
    }
  }

  void _paintDocument(
    Canvas canvas,
    Offset center,
    double breath,
    double fadeOut,
  ) {
    final docRect = Rect.fromCenter(
      center: center,
      width: 108,
      height: 132,
    );
    final rrect = RRect.fromRectAndRadius(
      docRect,
      const Radius.circular(AppSizes.radiusMd),
    );

    // Card surface + border with a soft breathing shadow.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = AppColors.card
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawRRect(
      rrect,
      Paint()..color = AppColors.card,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppSizes.borderWidthFocused
        ..color = AppColors.primary.withOpacity(.45 + .25 * breath),
    );

    // Header avatar circle + field lines.
    final avatarCenter = Offset(docRect.left + 24, docRect.top + 24);
    canvas.drawCircle(
      avatarCenter,
      10,
      Paint()..color = AppColors.primary.withOpacity(.22),
    );
    final linePaint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5
      ..color = AppColors.border.withOpacity(.9);
    final startY = docRect.top + 52;
    final rowGap = 22.0;
    for (var row = 0; row < 3; row++) {
      final y = startY + row * rowGap;
      canvas.drawLine(
        Offset(docRect.left + 18, y),
        Offset(docRect.right - 34, y),
        linePaint,
      );
    }
  }

  void _paintScanBeam(Canvas canvas, Offset center, double fadeOut) {
    // Sweep window: 0.02–0.58 of the loop, easing down the document.
    final t = _clamp01((progress - .02) / .56);
    if (t <= 0 || t >= 1) return;
    final ease = Curves.easeInOut.transform(t);
    final docTop = center.dy - 66;
    final docBottom = center.dy + 66;
    final y = docTop + (docBottom - docTop) * ease;
    final beamRect = Rect.fromLTWH(center.dx - 58, y - 14, 116, 28);
    final beam = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0),
          AppColors.primary.withOpacity(.30 * fadeOut),
          AppColors.primary.withOpacity(0),
        ],
      ).createShader(beamRect);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        beamRect,
        const Radius.circular(AppSpacing.sm),
      ),
      beam,
    );
    canvas.drawLine(
      Offset(center.dx - 54, y),
      Offset(center.dx + 54, y),
      Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = AppColors.primary.withOpacity(.85 * fadeOut),
    );
  }

  void _paintFieldChecks(Canvas canvas, Offset center, double fadeOut) {
    const thresholds = [.30, .42, .54];
    final startY = center.dy - 14;
    final rowGap = 22.0;
    for (var row = 0; row < 3; row++) {
      final t = _clamp01((progress - thresholds[row]) / .08);
      if (t <= 0) continue;
      final pop = _easeOutBack(t);
      final circleCenter = Offset(center.dx + 36, startY + row * rowGap);
      final radius = 7.0 * pop;
      if (radius <= 0) continue;
      // Filled check bubble.
      canvas.drawCircle(
        circleCenter,
        radius,
        Paint()
          ..color = AppColors.success
              .withOpacity(_clamp01(t) * fadeOut),
      );
      // Checkmark stroke, drawn with the same pop.
      final check = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = AppColors.white.withOpacity(fadeOut);
      final path = Path()
        ..moveTo(circleCenter.dx - 3 * pop, circleCenter.dy + 0 * pop)
        ..lineTo(circleCenter.dx - 1 * pop, circleCenter.dy + 2.5 * pop)
        ..lineTo(circleCenter.dx + 3 * pop, circleCenter.dy - 2.5 * pop);
      canvas.drawPath(path, check);
    }
  }

  @override
  bool shouldRepaint(_DocumentVerifyPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.orbit != orbit;
}
