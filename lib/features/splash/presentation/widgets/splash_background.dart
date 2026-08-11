import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';

/// A very light animated technical grid, deliberately kept behind the content
/// so the white SmartTrust theme remains clean rather than looking dark/heavy.
class SplashBackground extends StatelessWidget {
  const SplashBackground({
    required this.progress,
    super.key,
  });

  /// A repeating value from 0 to 1 supplied by the screen.
  final double progress;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _SplashBackgroundPainter(progress),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SplashBackgroundPainter extends CustomPainter {
  _SplashBackgroundPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    canvas.drawColor(AppColors.white, BlendMode.src); // Clear the canvas with white.

    final phase = progress * math.pi * 2;

    _paintGlow(
      canvas,
      Offset(
        size.width * .91 + math.sin(phase) * 10,
        size.height * .12,
      ),
      size.width * .56,
      AppColors.primaryLight.withOpacity(.24),
    );
    _paintGlow(
      canvas,
      Offset(
        size.width * .04 + math.cos(phase * .8) * 8,
        size.height * .59,
      ),
      size.width * .45,
      AppColors.primary.withOpacity(.09),
    );
    _paintGlow(
      canvas,
      Offset(size.width * .56, size.height * .96),
      size.width * .66,
      AppColors.secondaryLight.withOpacity(.06),
    );

    _paintPerspectiveGrid(canvas, size);
    _paintFloatingParticles(canvas, size, phase);
  }

  void _paintGlow(Canvas canvas, Offset center, double radius, Color color) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: <Color>[color, color.withOpacity(0)],
        stops: const <double>[0, 1],
      ).createShader(rect);
    canvas.drawCircle(center, radius, paint);
  }

  void _paintPerspectiveGrid(Canvas canvas, Size size) {
    final horizon = size.height * .76;
    final gridPaint = Paint()
      ..color = AppColors.primary.withOpacity(.085)
      ..strokeWidth = 1;

    // Horizontal perspective lines at the bottom of the screen.
    for (var index = 1; index <= 7; index++) {
      final t = index / 7;
      final y = horizon + (size.height - horizon) * t * t;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Lines converge around the lower-center horizon, creating a subtle
    // futuristic depth without competing with the logo mark.
    final vanishingPoint = Offset(size.width * .5, horizon);
    for (var index = -8; index <= 8; index++) {
      final bottomX = size.width * .5 + index * size.width * .16;
      canvas.drawLine(vanishingPoint, Offset(bottomX, size.height), gridPaint);
    }
  }

  void _paintFloatingParticles(Canvas canvas, Size size, double phase) {
    for (var index = 0; index < 22; index++) {
      final baseX = (index * 71.0) % size.width;
      final baseY = 64 + ((index * 113.0) % (size.height * .62));
      final x = baseX + math.sin(phase + index) * 5;
      final y = baseY + math.cos(phase * .75 + index) * 5;
      final opacity = .10 + ((math.sin(phase + index) + 1) * .06);
      final radius = index % 5 == 0 ? 2.2 : 1.15;

      canvas.drawCircle(
        Offset(x, y),
        radius,
        Paint()..color = AppColors.primaryDark.withOpacity(opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
