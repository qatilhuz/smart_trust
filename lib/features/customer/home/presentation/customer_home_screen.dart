import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/customer_home_data.dart';
import 'providers/customer_home_provider.dart';

class CustomerHomeScreen extends ConsumerStatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  ConsumerState<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends ConsumerState<CustomerHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entranceController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 760),
  )..forward();
  late final Animation<double> _headerReveal = _reveal(.0, .34);
  late final Animation<double> _activeReveal = _reveal(.12, .48);
  late final Animation<double> _categoriesReveal = _reveal(.24, .62);
  late final Animation<double> _providersReveal = _reveal(.38, .82);
  late final Animation<double> _actionsReveal = _reveal(.56, 1);

  Animation<double> _reveal(double begin, double end) {
    return CurvedAnimation(
      parent: _entranceController,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const _HomeLoadingScaffold(),
      error: (_, __) => AuthenticationPrompt(
        message: AppLocalizations.of(context)!.customerOnlyMessage,
      ),
      data: (user) {
        if (user == null || user.role.toLowerCase() != 'customer') {
          return AuthenticationPrompt(
            message: AppLocalizations.of(context)!.customerOnlyMessage,
          );
        }
        return _CustomerHomeContent(
          user: user,
          headerReveal: _headerReveal,
          activeReveal: _activeReveal,
          categoriesReveal: _categoriesReveal,
          providersReveal: _providersReveal,
          actionsReveal: _actionsReveal,
          onRetry: () => ref.invalidate(customerHomeProvider),
        );
      },
    );
  }
}

class _CustomerHomeContent extends ConsumerWidget {
  final UserEntity user;
  final Animation<double> headerReveal;
  final Animation<double> activeReveal;
  final Animation<double> categoriesReveal;
  final Animation<double> providersReveal;
  final Animation<double> actionsReveal;
  final VoidCallback onRetry;

  const _CustomerHomeContent({
    required this.user,
    required this.headerReveal,
    required this.activeReveal,
    required this.categoriesReveal,
    required this.providersReveal,
    required this.actionsReveal,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final homeState = ref.watch(customerHomeProvider);

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async => ref.invalidate(customerHomeProvider),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.section,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Reveal(
                        animation: headerReveal,
                        child: _HomeHeader(
                          user: user,
                          onNotifications: () => context.push(RouteNames.customerNotifications),
                          onProfile: () => context.push(RouteNames.customerProfile),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      _Reveal(
                        animation: activeReveal,
                        child: homeState.when(
                          loading: () => const _ActiveJobSkeleton(),
                          error: (_, __) => _HomeErrorState(onRetry: onRetry),
                          data: (data) => _ActiveJobSection(
                            job: data.activeJob,
                            onRequest: () => context.push(RouteNames.customerJobRequest),
                            onTrack: (job) => context.push(Uri(path: RouteNames.customerJobTracking, queryParameters: {'requestId': job.requestId, 'providerId': job.providerId, 'service': job.service, 'location': job.location}).toString()),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      _Reveal(
                        animation: categoriesReveal,
                        child: homeState.maybeWhen(
                          data: (data) => _CategorySection(
                            categories: data.categories,
                            onTap: (_) => context.push(RouteNames.customerJobRequest),
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      _Reveal(
                        animation: providersReveal,
                        child: homeState.maybeWhen(
                          data: (data) => _ProviderSection(
                            providers: data.nearbyProviders,
                            onSeeAll: null,
                          ),
                          orElse: () => const SizedBox.shrink(),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.section),
                      _Reveal(
                        animation: actionsReveal,
                        child: _QuickActions(
                          onAi: () => context.push(RouteNames.aiAssistant),
                          onVoice: () => context.push(RouteNames.voiceAssistant),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _NewRequestButton(
        label: l10n.newRequest,
        onPressed: () => context.push(RouteNames.customerJobRequest),
      ),
      bottomNavigationBar: const _CustomerBottomNavigation(),
    );
  }
}

class _Reveal extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _Reveal({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final slide = Tween<Offset>(
      begin: const Offset(0, .035),
      end: Offset.zero,
    ).animate(animation);
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final UserEntity user;
  final VoidCallback onNotifications;
  final VoidCallback onProfile;

  const _HomeHeader({
    required this.user,
    required this.onNotifications,
    required this.onProfile,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = user.name.trim().isEmpty ? l10n.customerRole : user.name;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.helloUser(displayName),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.heading2,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(l10n.greeting, style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        _HeaderIconButton(
          icon: Icons.notifications_none_rounded,
          label: l10n.notifications,
          onPressed: onNotifications,
        ),
        const SizedBox(width: AppSpacing.sm),
        Semantics(
          button: true,
          label: l10n.profile,
          child: InkWell(
            onTap: onProfile,
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: CircleAvatar(
              radius: AppSizes.avatarMedium / 2,
              backgroundColor: AppColors.secondary,
              child: Text(
                displayName.characters.first.toUpperCase(),
                style: AppTextStyles.label.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _HeaderIconButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: IconButton(
          onPressed: onPressed,
          tooltip: label,
          icon: Icon(icon, color: AppColors.secondary),
          iconSize: AppSizes.iconMd,
        ),
      ),
    );
  }
}

class _ActiveJobSection extends StatelessWidget {
  final ActiveCustomerJob? job;
  final VoidCallback onRequest;
  final ValueChanged<ActiveCustomerJob> onTrack;

  const _ActiveJobSection({required this.job, required this.onRequest, required this.onTrack});

  @override
  Widget build(BuildContext context) {
    return job == null
        ? _NoActiveJob(onRequest: onRequest)
        : _ActiveJobCard(job: job!, onTrack: () => onTrack(job!));
  }
}

class _ActiveJobCard extends StatelessWidget {
  final ActiveCustomerJob job;
  final VoidCallback onTrack;

  const _ActiveJobCard({required this.job, required this.onTrack});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(.18),
            blurRadius: AppSpacing.xxl,
            offset: const Offset(0, AppSpacing.md),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(.14),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMd),
                ),
                child: const Icon(Icons.engineering_rounded, color: AppColors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(l10n.activeJob, style: AppTextStyles.label.copyWith(color: AppColors.white70)),
              ),
              _StatusPill(label: job.status),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(job.service, style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.activeJobSummary(job.service, job.location, job.eta),
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusPill),
            child: LinearProgressIndicator(
              value: job.progress.clamp(0.0, 1.0).toDouble(),
              minHeight: AppSpacing.xs,
              backgroundColor: AppColors.white.withOpacity(.18),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(job.providerName, style: AppTextStyles.label.copyWith(color: AppColors.white)),
              ),
              TextButton(
                onPressed: onTrack,
                style: TextButton.styleFrom(foregroundColor: AppColors.white),
                child: Text(l10n.viewDetails),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String label;

  const _StatusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(.18),
        borderRadius: BorderRadius.circular(AppSizes.radiusPill),
      ),
      child: Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.white)),
    );
  }
}

class _NoActiveJob extends StatelessWidget {
  final VoidCallback onRequest;

  const _NoActiveJob({required this.onRequest});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const _SoftIcon(icon: Icons.home_repair_service_rounded),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.noActiveJob, style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.xs),
                Text(l10n.startRequest, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
          IconButton(
            onPressed: onRequest,
            tooltip: l10n.newRequest,
            icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final List<ServiceCategory> categories;
  final ValueChanged<ServiceCategory> onTap;

  const _CategorySection({required this.categories, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.categories),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 112,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _CategoryTile(
              category: categories[index],
              onTap: () => onTap(categories[index]),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final ServiceCategory category;
  final VoidCallback onTap;

  const _CategoryTile({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: category.name,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Container(
            width: 92,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(.04),
                  blurRadius: AppSpacing.sm,
                  offset: const Offset(0, AppSpacing.xs),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _SoftIcon(icon: IconData(category.iconCodePoint, fontFamily: 'MaterialIcons')),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  category.shortLabel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderSection extends StatelessWidget {
  final List<NearbyProvider> providers;
  final VoidCallback? onSeeAll;

  const _ProviderSection({required this.providers, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (providers.isEmpty) {
      return _EmptySection(
        icon: Icons.location_searching_rounded,
        title: l10n.nearbyProviders,
        message: l10n.noNearbyProviders,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: l10n.nearbyProviders, actionLabel: l10n.seeAll, onAction: onSeeAll),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 218,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, index) => _ProviderPreview(provider: providers[index]),
          ),
        ),
      ],
    );
  }
}

class _ProviderPreview extends StatelessWidget {
  final NearbyProvider provider;

  const _ProviderPreview({required this.provider});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: 246,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(.06),
            blurRadius: AppSpacing.lg,
            offset: const Offset(0, AppSpacing.sm),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: AppSizes.avatarMedium / 2,
                backgroundColor: AppColors.primary.withOpacity(.12),
                child: Text(provider.name.characters.first.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(provider.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.heading3.copyWith(fontSize: AppFonts.lg)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(provider.category, style: AppTextStyles.bodySmall),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: AppSizes.iconSm, color: AppColors.warning),
              const SizedBox(width: AppSpacing.xs),
              Text(provider.rating.toStringAsFixed(1), style: AppTextStyles.label),
              const SizedBox(width: AppSpacing.md),
              const Icon(Icons.near_me_rounded, size: AppSizes.iconSm, color: AppColors.primaryDark),
              const SizedBox(width: AppSpacing.xs),
              Text(l10n.distanceKm(provider.distanceKm.toStringAsFixed(1)), style: AppTextStyles.label),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  provider.isAvailable ? l10n.availableNow : l10n.pending,
                  style: AppTextStyles.caption.copyWith(color: provider.isAvailable ? AppColors.success : AppColors.textSecondary),
                ),
              ),
              if (provider.isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(.10),
                    borderRadius: BorderRadius.circular(AppSizes.radiusPill),
                  ),
                  child: Text(l10n.recommended, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onAi;
  final VoidCallback onVoice;

  const _QuickActions({required this.onAi, required this.onVoice});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(child: _QuickAction(icon: Icons.auto_awesome_rounded, label: l10n.aiAssistant, onTap: onAi)),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: _QuickAction(icon: Icons.mic_rounded, label: l10n.voiceAssistant, onTap: onVoice)),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primaryDark, size: AppSizes.iconLg),
                const SizedBox(height: AppSpacing.sm),
                Text(label, style: AppTextStyles.label.copyWith(color: AppColors.secondary)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SectionHeader({required this.title, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(title, style: AppTextStyles.heading3)),
        if (actionLabel != null && onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel!)),
      ],
    );
  }
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;

  const _SoftIcon({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.10),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.iconMd),
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptySection({required this.icon, required this.title, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _SoftIcon(icon: icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.heading3),
                const SizedBox(height: AppSpacing.xs),
                Text(message, style: AppTextStyles.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _HomeErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.error.withOpacity(.22)),
      ),
      child: Row(
        children: [
          const _SoftIcon(icon: Icons.cloud_off_rounded),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(l10n.homeLoadError, style: AppTextStyles.bodySmall)),
          IconButton(
            onPressed: onRetry,
            tooltip: l10n.retry,
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primaryDark),
          ),
        ],
      ),
    );
  }
}

class _ActiveJobSkeleton extends StatelessWidget {
  const _ActiveJobSkeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 190,
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withOpacity(.22),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: const Center(
        child: SizedBox(
          width: AppSizes.iconLg,
          height: AppSizes.iconLg,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryDark),
        ),
      ),
    );
  }
}

class _HomeLoadingScaffold extends StatelessWidget {
  const _HomeLoadingScaffold();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(child: _ActiveJobSkeleton()),
    );
  }
}

class _NewRequestButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _NewRequestButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.white,
      icon: const Icon(Icons.add_rounded),
      label: Text(label),
    );
  }
}

class _CustomerBottomNavigation extends StatelessWidget {
  const _CustomerBottomNavigation();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.home_rounded, l10n.home, (BuildContext context) {}),
      (Icons.assignment_rounded, l10n.jobs, (BuildContext context) => context.push(RouteNames.customerJobTracking)),
      (Icons.chat_bubble_rounded, l10n.chat, (BuildContext context) => context.push(RouteNames.customerChat)),
      (Icons.person_rounded, l10n.profile, (BuildContext context) => context.push(RouteNames.customerProfile)),
    ];

    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.xs),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSizes.radiusXl),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondary.withOpacity(.08),
              blurRadius: AppSpacing.lg,
              offset: const Offset(0, AppSpacing.xs),
            ),
          ],
        ),
        child: Row(
          children: List.generate(
            items.length,
            (index) => Expanded(
              child: _NavigationItem(
                icon: items[index].$1,
                label: items[index].$2,
                selected: index == 0,
                onTap: () => items[index].$3(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavigationItem({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(.10) : AppColors.transparent,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: selected ? AppColors.primaryDark : AppColors.textLight, size: AppSizes.iconMd),
              const SizedBox(height: AppSpacing.xs),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.navigation.copyWith(color: selected ? AppColors.primaryDark : AppColors.textLight)),
            ],
          ),
        ),
      ),
    );
  }
}
