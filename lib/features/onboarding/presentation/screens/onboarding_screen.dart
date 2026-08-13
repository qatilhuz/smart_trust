import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/router/route_names.dart';
import '../../../../l10n/app_localizations.dart';
import '../widgets/onboarding_page.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _page = 0;

  void _next() {
    if (_page < 2) {
      _controller.animateToPage(
        _page + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _back() {
    if (_page == 0) return;
    _controller.animateToPage(
      _page - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(RouteNames.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _page = index),
                children: const [
                  LanguagePage(),
                  IntroPage(),
                  RolePage(),
                ],
              ),
            ),
            _OnboardingControls(
              page: _page,
              pageCount: 3,
              backLabel: l10n.back,
              nextLabel: _page == 2 ? l10n.getStarted : l10n.next,
              onBack: _back,
              onNext: _next,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingControls extends StatelessWidget {
  final int page;
  final int pageCount;
  final String backLabel;
  final String nextLabel;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const _OnboardingControls({
    required this.page,
    required this.pageCount,
    required this.backLabel,
    required this.nextLabel,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.md,
        AppSpacing.xxl,
        AppSpacing.xxl,
      ),
      child: Row(
        children: [
          SizedBox(
            width: AppSizes.buttonHeightLarge,
            child: page > 0
                ? Semantics(
                    button: true,
                    label: backLabel,
                    child: IconButton(
                      onPressed: onBack,
                      tooltip: backLabel,
                      icon: const Icon(Icons.arrow_back_rounded),
                      color: AppColors.secondary,
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          Expanded(
            child: Center(
              child: _PageIndicator(currentPage: page, count: pageCount),
            ),
          ),
          _NextButton(label: nextLabel, onPressed: onNext),
        ],
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  final int currentPage;
  final int count;

  const _PageIndicator({required this.currentPage, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          width: currentPage == index ? AppSpacing.xxl : AppSpacing.sm,
          height: AppSpacing.sm,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            color: currentPage == index ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
          ),
        ),
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NextButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(.24),
                blurRadius: AppSpacing.md,
                offset: const Offset(0, AppSpacing.xs),
              ),
            ],
          ),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(AppSizes.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.md,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  label,
                  key: ValueKey(label),
                  style: AppTextStyles.button,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
