import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constant.dart';
import '../../domain/entities/splash_destination.dart';
import '../../presentation/mappers/splash_destination_route_mapper.dart';
import '../providers/splash_providers.dart';
import '../widgets/animated_smarttrust_mark.dart';
import '../widgets/splash_background.dart';
import '../widgets/splash_status_panel.dart';

/// SmartTrust's animated entry point.
///
/// It has no API, storage or token code in the widget. Those concerns are
/// hidden behind [splashDestinationProvider], while this screen only owns UI
/// animation and the final go_router transition.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  static const _minimumBrandDuration = Duration(milliseconds: 3150);
  static const _reducedMotionDuration = Duration(milliseconds: 700);

  late final AnimationController _introController;
  late final AnimationController _ambientController;
  late final AnimationController _exitController;

  late final Animation<double> _markReveal;
  late final Animation<double> _markScale;
  late final Animation<double> _wordmarkReveal;
  late final Animation<double> _taglineReveal;
  late final Animation<double> _statusReveal;
  late final Animation<double> _loadingProgress;

  bool _didStart = false;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6200),
    );
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );

    _markReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.04, 0.36, curve: Curves.easeOutCubic),
    );
    _markScale = Tween<double>(begin: .70, end: 1).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.04, 0.42, curve: Curves.easeOutBack),
      ),
    );
    _wordmarkReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.34, 0.61, curve: Curves.easeOutCubic),
    );
    _taglineReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.53, 0.76, curve: Curves.easeOutCubic),
    );
    _statusReveal = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.65, 0.94, curve: Curves.easeOutCubic),
    );
    _loadingProgress = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.72, 1, curve: Curves.easeInOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  void _start() {
    if (_didStart || !mounted) return;
    _didStart = true;

    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (reduceMotion) {
      _introController.value = 1;
    } else {
      _introController.forward();
      _ambientController.repeat();
    }

    unawaited(_resolveAndNavigate(reduceMotion));
  }

  Future<void> _resolveAndNavigate(bool reduceMotion) async {
    // Start reading the session immediately; it runs in parallel with branding.
    final destinationFuture = _readDestination();

    await Future<void>.delayed(
      reduceMotion ? _reducedMotionDuration : _minimumBrandDuration,
    );

    final destination = await destinationFuture;
    if (!mounted) return;

    if (!reduceMotion) {
      await _exitController.forward();
      if (!mounted) return;
    }

    context.go(destination.routePath);
  }

  Future<SplashDestination> _readDestination() async {
    try {
      return await ref.read(splashDestinationProvider.future);
    } catch (_) {
      // A broken/expired local session should never trap the user on splash.
      return SplashDestination.login;
    }
  }

  @override
  void dispose() {
    _introController.dispose();
    _ambientController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: Listenable.merge(<Listenable>[
          _introController,
          _ambientController,
          _exitController,
        ]),
        builder: (context, child) {
          final exitValue = Curves.easeInCubic.transform(_exitController.value);

          return Opacity(
            opacity: 1 - exitValue,
            child: Transform.translate(
              offset: Offset(0, -18 * exitValue),
              child: Transform.scale(
                scale: 1 + (exitValue * .028),
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    SplashBackground(progress: _ambientController.value),
                    SafeArea(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 430),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 18,
                            ),
                            child: Column(
                              children: <Widget>[
                                const Spacer(flex: 3),
                                Transform.scale(
                                  scale: _markScale.value,
                                  child: AnimatedSmartTrustMark(
                                    reveal: _markReveal.value,
                                    orbitProgress: _ambientController.value,
                                    pulse: 1 -
                                        ((_ambientController.value * 2) - 1).abs(),
                                  ),
                                ),
                                const SizedBox(height: 26),
                                _BrandWordmark(reveal: _wordmarkReveal.value),
                                const SizedBox(height: 13),
                                _BrandTagline(reveal: _taglineReveal.value),
                                const Spacer(flex: 4),
                                Opacity(
                                  opacity: _statusReveal.value,
                                  child: Transform.translate(
                                    offset: Offset(
                                      0,
                                      14 * (1 - _statusReveal.value),
                                    ),
                                    child: SplashStatusPanel(
                                      reveal: _statusReveal.value,
                                      loadingProgress: _loadingProgress.value,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
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
          );
        },
      ),
    );
  }
}

class _BrandWordmark extends StatelessWidget {
  const _BrandWordmark({required this.reveal});

  final double reveal;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: reveal,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - reveal)),
        child: RichText(
          textAlign: TextAlign.center,
          text: const TextSpan(
            children: <InlineSpan>[
              TextSpan(
                text: 'Smart',
                style: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.35,
                ),
              ),
              TextSpan(
                text: 'Trust',
                style: TextStyle(
                  color: AppColors.primaryDark,
                  fontSize: 34,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BrandTagline extends StatelessWidget {
  const _BrandTagline({required this.reveal});

  final double reveal;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: reveal,
      child: Transform.translate(
        offset: Offset(0, 12 * (1 - reveal)),
        child: Column(
          children: <Widget>[
            Text(
              'Verified home services, made simple.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.secondaryLight.withOpacity(.86),
                fontSize: 14,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 42,
              height: 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(99),
                gradient: const LinearGradient(
                  colors: <Color>[
                    AppColors.primaryLight,
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
