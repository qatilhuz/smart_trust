import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trust_app/core/widgets/primary_button.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../l10n/app_localizations.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      drawer: const AppDrawer(variant: AppDrawerVariant.guest),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xxl,
                AppSpacing.section,
                AppSpacing.xxl,
                AppSpacing.section,
              ),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const HamburgerMenuButton(),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.hello, style: AppTextStyles.heading2),
                              const SizedBox(height: AppSpacing.xs),
                              Text(l.greeting, style: AppTextStyles.bodyMedium),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.push(RouteNames.login),
                          tooltip: l.login,
                          icon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.secondary,
                            AppColors.secondaryLight,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.verified_user_rounded,
                            color: AppColors.primaryLight,
                            size: AppSizes.iconXl,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            l.verifiedProfessionals,
                            style: AppTextStyles.heading2.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l.introDescription,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white70,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          OutlinedButton(
                            onPressed: () => showModalBottomSheet(
                              context: context,
                              builder: (_) => const AuthenticationPrompt(),
                            ),
                            child: Text(l.createAccount),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    Text(l.categories, style: AppTextStyles.heading3),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children:
                          [
                                l.serviceCategoryHvac,
                                l.categoryElectrical,
                                l.categoryPlumbing,
                                l.categoryPainting,
                                l.categoryCleaning,
                              ]
                              .map(
                                (x) => Chip(
                                  label: Text(x),
                                  backgroundColor: AppColors.card,
                                  side: BorderSide(color: AppColors.border),
                                ),
                              )
                              .toList(),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    PrimaryButton(
                      label: l.newRequest,
                      onPressed: () => showModalBottomSheet(
                        context: context,
                        builder: (_) => const AuthenticationPrompt(),
                      ),
                    ),
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
