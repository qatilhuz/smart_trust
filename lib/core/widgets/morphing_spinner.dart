import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Lightweight, futuristic two-arc loader used for submission states.
///
/// A single repeating [AnimationController] drives a brand-gradient comet
/// arc whose sweep "breathes" (morphs) while it orbits, over a faint track
/// and a counter-rotating echo arc. Canvas-only repaints — no layout
/// animations — so it is cheap enough to embed inside buttons.
class MorphingSpinner extends StatefulWidget {
  final double size;
  final double strokeWidth;

  /// Base color; gradients/echo arcs are derived from it. Use
  /// [AppColors.white] on filled surfaces such as [PrimaryButton].
  final Color color;

  const MorphingSpinner({
    super.key,
    this.size = 24,
    this.strokeWidth = 2.5,
    this.color = AppColors.primary,
  });

  @override
  State<MorphingSpinner> createState() => _MorphingSpinnerState();
}

class _MorphingSpinnerState extends State<MorphingSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Transform.rotate(
            angle: t * 2 * math.pi,
            child: Transform.scale(
              scale: 1 + .07 * math.sin(t * 2 * math.pi),
              child: CustomPaint(
                painter: _MorphingArcPainter(
                  progress: t,
                  color: widget.color,
                  strokeWidth: widget.strokeWidth,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MorphingArcPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  const _MorphingArcPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Faint full track so the orbit reads even on busy backgrounds.
    final track = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color.withOpacity(.14);
    canvas.drawArc(rect.deflate(strokeWidth / 2), 0, math.pi * 2, false, track);

    // Main brand-gradient comet: the sweep oscillates, producing the
    // morphing grow/shrink motion as it spins.
    final sweep = math.pi * (0.62 + 0.34 * math.sin(progress * 2 * math.pi));
    final comet = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        colors: [color.withOpacity(.25), color, color],
        stops: const [0, .7, 1],
        transform: const GradientRotation(-math.pi / 2),
      ).createShader(rect);
    canvas.drawArc(
      rect.deflate(strokeWidth / 2),
      -math.pi / 2,
      sweep,
      false,
      comet,
    );

    // Counter-rotating echo arc for depth.
    final echo = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * .6
      ..strokeCap = StrokeCap.round
      ..color = color.withOpacity(.4);
    canvas.drawArc(
      rect.deflate(strokeWidth * 1.9),
      progress * 4 * math.pi,
      math.pi * .38,
      false,
      echo,
    );
  }

  @override
  bool shouldRepaint(_MorphingArcPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.strokeWidth != strokeWidth;
}
