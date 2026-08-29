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
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../request_acceptance/domain/entities/provider_request_entities.dart';
import '../../request_acceptance/presentation/providers/provider_request_providers.dart';

class ProviderJobFeedScreen extends ConsumerWidget {
  const ProviderJobFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _FeedLoading();
    if (auth.valueOrNull == null ||
        auth.valueOrNull!.role.toLowerCase() != 'provider') {
      return AuthenticationPrompt(message: l10n.providerOnlyMessage);
    }

    final providerId = ref.watch(localProviderIdProvider);
    final requests = ref.watch(providerIncomingRequestsProvider(providerId));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.incomingRequests)),
      body: requests.when(
        loading: () => const _FeedLoading(),
        error: (_, __) => _FeedError(
          onRetry: () =>
              ref.invalidate(providerIncomingRequestsProvider(providerId)),
        ),
        data: (items) => items.isEmpty
            ? const _EmptyFeed()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xxl,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                  AppSpacing.section,
                ),
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) => _IncomingRequestCard(
                  request: items[index],
                  onOpen: () => context.push(
                    Uri(
                      path: RouteNames.providerRequestDetails,
                      queryParameters: {
                        'requestId': items[index].requestId,
                        'providerId': providerId,
                      },
                    ).toString(),
                  ),
                ),
              ),
      ),
      bottomNavigationBar: _ProviderFeedNavigation(l10n: l10n),
    );
  }
}

class _IncomingRequestCard extends StatelessWidget {
  final ProviderRequest request;
  final VoidCallback onOpen;
  const _IncomingRequestCard({required this.request, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return InkWell(
      onTap: onOpen,
      borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      child: Container(
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
                Expanded(
                  child: Text(
                    l10n.requestReference(request.requestId),
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                _StatusPill(label: l10n.requestPending),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const _IconBubble(icon: Icons.home_repair_service_rounded),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _categoryName(l10n, request.categoryNameKey),
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        request.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              request.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodySmall,
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.openRequest,
                    style: AppTextStyles.label.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryDark,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _categoryName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'serviceCategoryHvac':
        return l10n.serviceCategoryHvac;
      case 'categoryElectrical':
        return l10n.categoryElectrical;
      case 'categoryPlumbing':
        return l10n.categoryPlumbing;
      case 'categoryPainting':
        return l10n.categoryPainting;
      case 'categoryCleaning':
        return l10n.categoryCleaning;
      default:
        return l10n.service;
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String label;
  const _StatusPill({required this.label});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(
      horizontal: AppSpacing.sm,
      vertical: AppSpacing.xs,
    ),
    decoration: BoxDecoration(
      color: AppColors.warning.withOpacity(.12),
      borderRadius: BorderRadius.circular(AppSizes.radiusPill),
    ),
    child: Text(
      label,
      style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
    ),
  );
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble({required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(AppSpacing.md),
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: AppColors.primary.withOpacity(.10),
    ),
    child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.iconMd),
  );
}

class _ProviderFeedNavigation extends StatelessWidget {
  final AppLocalizations l10n;
  const _ProviderFeedNavigation({required this.l10n});
  @override
  Widget build(BuildContext context) => BottomNavigationBar(
    currentIndex: 1,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textLight,
    items: [
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_rounded),
        label: l10n.feed,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.assignment_rounded),
        label: l10n.jobs,
      ),
      BottomNavigationBarItem(
        icon: const Icon(Icons.account_circle_rounded),
        label: l10n.profile,
      ),
    ],
  );
}

class _EmptyFeed extends StatelessWidget {
  const _EmptyFeed();
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox_rounded,
            color: AppColors.primaryDark,
            size: AppSizes.iconXl,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            AppLocalizations.of(context)!.noIncomingRequests,
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _FeedError extends StatelessWidget {
  final VoidCallback onRetry;
  const _FeedError({required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(
    child: TextButton.icon(
      onPressed: onRetry,
      icon: const Icon(Icons.refresh_rounded),
      label: Text(AppLocalizations.of(context)!.retry),
    ),
  );
}

class _FeedLoading extends StatelessWidget {
  const _FeedLoading();
  @override
  Widget build(BuildContext context) => const Scaffold(
    backgroundColor: AppColors.scaffoldBackground,
    body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
  );
}
