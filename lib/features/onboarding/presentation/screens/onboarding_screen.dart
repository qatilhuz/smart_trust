import 'package:flutter/material.dart';
import "package:shared_preferences/shared_preferences.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/route_names.dart';
import '../presentation/widgets/onboarding_page.dart';

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

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (mounted) context.go(RouteNames.login);
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final isUrdu = locale.languageCode == 'ur';

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _page = i),
                children: const [
                  LanguagePage(),
                  IntroPage(),
                  RolePage(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _page > 0
                      ? TextButton(
                          onPressed: () => _controller.animateToPage(
                            _page - 1,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeInOut,
                          ),
                          child: Text(isUrdu ? 'واپس' : 'Back'),
                        )
                      : const SizedBox(width: 60),
                  Row(
                    children: List.generate(3, (i) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: _page == i ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: _page == i ? AppColors.primary : AppColors.border,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      );
                    }),
                  ),
                  ElevatedButton(
                    onPressed: _next,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(isUrdu ? (_page == 2 ? 'شروع' : 'اگلے') : (_page == 2 ? 'Get Started' : 'Next')),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
