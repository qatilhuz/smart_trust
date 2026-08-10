import 'package:flutter/material.dart';

import '../../../../core/constants/constant.dart';

/// Bottom loading/status treatment for the splash screen.
class SplashStatusPanel extends StatelessWidget {
  const SplashStatusPanel({
    required this.reveal,
    required this.loadingProgress,
    super.key,
  });

  final double reveal;
  final double loadingProgress;

  @override
  Widget build(BuildContext context) {
    final safeProgress = loadingProgress.clamp(.035, 1.0).toDouble();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            _StatusChip(
              icon: Icons.verified_rounded,
              label: 'VERIFIED',
              reveal: _staggeredReveal(0),
            ),
            _StatusChip(
              icon: Icons.location_on_outlined,
              label: 'HYPERLOCAL',
              reveal: _staggeredReveal(1),
            ),
            _StatusChip(
              icon: Icons.handshake_outlined,
              label: 'RELIABLE',
              reveal: _staggeredReveal(2),
            ),
          ],
        ),
        const SizedBox(height: 21),
        Text(
          'Preparing your trusted home network',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.secondaryLight.withOpacity(.78),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: .15,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 194,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                ColoredBox(color: AppColors.primaryLight.withOpacity(.25)),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FractionallySizedBox(
                    widthFactor: safeProgress,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: <Color>[
                            AppColors.primaryLight,
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  double _staggeredReveal(int index) {
    final start = index * .15;
    return ((reveal - start) / (1 - start)).clamp(0.0, 1.0).toDouble();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.reveal,
  });

  final IconData icon;
  final String label;
  final double reveal;

  @override
  Widget build(BuildContext context) {
    final curvedValue = Curves.easeOutBack
        .transform(reveal)
        .clamp(0.0, 1.1)
        .toDouble();

    return Opacity(
      opacity: reveal,
      child: Transform.scale(
        scale: .86 + (curvedValue * .14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(.80),
            borderRadius: BorderRadius.circular(99),
            border: Border.all(color: AppColors.primary.withOpacity(.17)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.secondaryDark.withOpacity(.045),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 13, color: AppColors.primaryDark),
              const SizedBox(width: 5),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 9.5,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .65,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
