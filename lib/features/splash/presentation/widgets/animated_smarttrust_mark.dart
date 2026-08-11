import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';

/// A text-led brand mark for SmartTrust.
///
/// The letters "ST" are the logo; the shield, orbit rings and verification
/// tick simply give that text a polished, trustworthy product identity until a
/// permanent SVG logo is commissioned.
class AnimatedSmartTrustMark extends StatelessWidget {
  const AnimatedSmartTrustMark({
    required this.reveal,
    required this.orbitProgress,
    required this.pulse,
    super.key,
  });

  final double reveal;
  final double orbitProgress;
  final double pulse;

  @override
  Widget build(BuildContext context) {
    final safeReveal = reveal.clamp(0.0, 1.0).toDouble();
    final checkScale = .86 + (pulse * .14);

    return SizedBox(
      width: 236,
      height: 236,
      child: Opacity(
        opacity: safeReveal,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: <Widget>[
            _OrbitRing(
              diameter: 224,
              rotation: orbitProgress * math.pi * 2,
              color: AppColors.primary,
              opacity: .22,
              dotAlignment: Alignment.topCenter,
              dotSize: 8,
            ),
            _OrbitRing(
              diameter: 184,
              rotation: -orbitProgress * math.pi * 1.45,
              color: AppColors.secondaryLight,
              opacity: .15,
              dotAlignment: Alignment.bottomRight,
              dotSize: 6,
            ),
            Container(
              width: 146,
              height: 146,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.055),
                border: Border.all(
                  color: AppColors.primary.withOpacity(.13),
                ),
              ),
            ),
            Transform.scale(
              scale: .94 + (pulse * .06),
              child: _ShieldMonogram(glowProgress: orbitProgress),
            ),
            Positioned(
              right: 32,
              bottom: 31,
              child: Transform.scale(
                scale: checkScale,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryLight.withOpacity(.65),
                      width: 1.5,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.primary.withOpacity(.20),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primaryDark,
                    size: 24,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 27,
              top: 44,
              child: _SignalDot(
                size: 9,
                opacity: .38 + (pulse * .42),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShieldMonogram extends StatelessWidget {
  const _ShieldMonogram({required this.glowProgress});

  final double glowProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 116,
      height: 136,
      child: ClipPath(
        clipper: const _ShieldClipper(),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                AppColors.primary,
                AppColors.primaryDark,
                AppColors.secondaryLight,
              ],
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(.28),
                blurRadius: 25,
                offset: const Offset(0, 13),
              ),
            ],
          ),
          child: Stack(
            children: <Widget>[
              // Moving translucent highlight, giving the monogram a premium
              // glass-like scan without relying on an image asset.
              Positioned(
                left: -86 + (glowProgress * 220),
                top: -44,
                child: Transform.rotate(
                  angle: -.42,
                  child: Container(
                    width: 42,
                    height: 220,
                    color: AppColors.white.withOpacity(.15),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: const Offset(1, -2),
                  child: const Text(
                    'ST',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 43,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -4.5,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 21,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(.72),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbitRing extends StatelessWidget {
  const _OrbitRing({
    required this.diameter,
    required this.rotation,
    required this.color,
    required this.opacity,
    required this.dotAlignment,
    required this.dotSize,
  });

  final double diameter;
  final double rotation;
  final Color color;
  final double opacity;
  final Alignment dotAlignment;
  final double dotSize;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: SizedBox(
        width: diameter,
        height: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(opacity)),
          ),
          child: Align(
            alignment: dotAlignment,
            child: Transform.translate(
              offset: Offset(0, -dotSize / 2),
              child: Container(
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(opacity + .34),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: color.withOpacity(.35),
                      blurRadius: 8,
                    ),
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

class _SignalDot extends StatelessWidget {
  const _SignalDot({required this.size, required this.opacity});

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withOpacity(opacity),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: AppColors.primary.withOpacity(opacity),
            blurRadius: 10,
          ),
        ],
      ),
    );
  }
}

class _ShieldClipper extends CustomClipper<Path> {
  const _ShieldClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width * .5, 0)
      ..lineTo(size.width * .94, size.height * .14)
      ..lineTo(size.width * .84, size.height * .69)
      ..quadraticBezierTo(
        size.width * .76,
        size.height * .89,
        size.width * .5,
        size.height,
      )
      ..quadraticBezierTo(
        size.width * .24,
        size.height * .89,
        size.width * .16,
        size.height * .69,
      )
      ..lineTo(size.width * .06, size.height * .14)
      ..close();
  }

  @override
  bool shouldReclip(covariant _ShieldClipper oldClipper) => false;
}
