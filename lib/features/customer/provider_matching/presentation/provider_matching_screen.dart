import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trust_app/core/widgets/primary_button.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/provider_matching_entities.dart';
import '../domain/entities/provider_matching_failures.dart';
import 'providers/provider_matching_providers.dart';

class ProviderMatchingScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String? service;
  final String? location;

  const ProviderMatchingScreen({super.key, required this.requestId, this.service, this.location});

  @override
  ConsumerState<ProviderMatchingScreen> createState() => _ProviderMatchingScreenState();
}

class _ProviderMatchingScreenState extends ConsumerState<ProviderMatchingScreen> {
  ProviderSelection? _selection;
  bool _selecting = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _MatchingLoadingScaffold();
    if (auth.valueOrNull?.role.toLowerCase() != 'customer') {
      return AuthenticationPrompt(message: l10n.customerOnlyMessage);
    }
    if (widget.requestId.trim().isEmpty) {
      return _MatchingError(message: l10n.requestUnavailable, onRetry: null);
    }
    if (_selection != null) {
      return _ProviderSelectedState(selection: _selection!, onHome: () => context.go(RouteNames.customerHome));
    }

    final matches = ref.watch(matchedProvidersProvider(widget.requestId));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.availableProviders),
        leading: IconButton(onPressed: () => context.pop(), tooltip: l10n.back, icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: matches.when(
        loading: () => const _MatchingView(),
        error: (error, _) => _MatchingError(message: _failureMessage(l10n, error), onRetry: () => ref.invalidate(matchedProvidersProvider(widget.requestId))),
        data: (result) => _ProviderList(
          result: ProviderMatchResult(
            request: ProviderMatchRequest(
              requestId: result.request.requestId,
              service: widget.service ?? result.request.service,
              location: widget.location ?? result.request.location,
              summary: result.request.summary,
            ),
            providers: result.providers,
          ),
          selecting: _selecting,
          onDetails: (provider) => context.push(Uri(path: RouteNames.customerProviderDetails, queryParameters: {'requestId': widget.requestId, 'providerId': provider.id, 'service': widget.service ?? result.request.service, 'location': widget.location ?? result.request.location}).toString()),
          onSelect: _confirmSelection,
        ),
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, Object error) {
    if (error is ProviderMatchingException) {
      switch (error.code) {
        case ProviderMatchingFailureCode.invalidRequest:
          return l10n.requestUnavailable;
        case ProviderMatchingFailureCode.noProviders:
          return l10n.noProvidersFound;
        case ProviderMatchingFailureCode.providerUnavailable:
          return l10n.providerNotAvailable;
        case ProviderMatchingFailureCode.unknown:
          return l10n.matchingError;
      }
    }
    return l10n.matchingError;
  }

  Future<void> _confirmSelection(MatchedProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final shouldSelect = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      builder: (context) => _ConfirmProviderSheet(provider: provider, l10n: l10n),
    );
    if (shouldSelect != true || !mounted) return;
    setState(() => _selecting = true);
    try {
      final selected = await ref.read(selectProviderUseCaseProvider).call(
            requestId: widget.requestId,
            providerId: provider.id,
          );
      final selection = ProviderSelection(
        requestId: selected.requestId,
        providerId: selected.providerId,
        provider: selected.provider,
        service: widget.service,
        location: widget.location,
      );
      if (!mounted) return;
      ref.read(providerSelectionStateProvider.notifier).state = selection;
      setState(() {
        _selecting = false;
        _selection = selection;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _selecting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.providerSelectionError)));
    }
  }
}

class ProviderSelectionScreen extends StatelessWidget {
  final String requestId;
  final String? service;
  final String? location;

  const ProviderSelectionScreen({super.key, required this.requestId, this.service, this.location});

  @override
  Widget build(BuildContext context) {
    return ProviderMatchingScreen(requestId: requestId, service: service, location: location);
  }
}

class _ProviderList extends StatelessWidget {
  final ProviderMatchResult result;
  final bool selecting;
  final ValueChanged<MatchedProvider> onDetails;
  final ValueChanged<MatchedProvider> onSelect;

  const _ProviderList({required this.result, required this.selecting, required this.onDetails, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.section),
      children: [
        _RequestContextCard(request: result.request),
        const SizedBox(height: AppSpacing.xxl),
        Row(children: [Expanded(child: Text(l10n.providersFound(result.providers.length), style: AppTextStyles.heading3)), if (selecting) const SizedBox(width: AppSizes.iconSm, height: AppSizes.iconSm, child: CircularProgressIndicator(strokeWidth: 2))]),
        const SizedBox(height: AppSpacing.md),
        if (result.providers.isEmpty) _MatchingError(message: l10n.noProvidersFound, onRetry: null),
        ...result.providers.map((provider) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: _ProviderCard(provider: provider, onDetails: () => onDetails(provider), onSelect: () => onSelect(provider)))),
      ],
    );
  }
}

class _RequestContextCard extends StatelessWidget {
  final ProviderMatchRequest request;
  const _RequestContextCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight]),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.16), blurRadius: AppSpacing.lg, offset: const Offset(0, AppSpacing.sm))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.matchForRequest, style: AppTextStyles.label.copyWith(color: AppColors.white70)),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.requestReference(request.requestId), style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        const SizedBox(height: AppSpacing.md),
        Row(children: [const Icon(Icons.home_repair_service_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(request.service, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)))]),
        const SizedBox(height: AppSpacing.xs),
        Row(children: [const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(request.location, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70)))]),
      ]),
    );
  }
}

class _ProviderCard extends StatelessWidget {
  final MatchedProvider provider;
  final VoidCallback onDetails;
  final VoidCallback onSelect;

  const _ProviderCard({required this.provider, required this.onDetails, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(
      button: true,
      label: provider.name,
      child: InkWell(
        onTap: onDetails,
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: provider.isAvailable ? AppColors.border : AppColors.textLight),
            boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.06), blurRadius: AppSpacing.lg, offset: const Offset(0, AppSpacing.sm))],
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: AppSizes.avatarMedium / 2, backgroundColor: AppColors.primary.withOpacity(.12), child: Text(provider.name.characters.first.toUpperCase(), style: AppTextStyles.label.copyWith(color: AppColors.primaryDark))),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(provider.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.heading3)), if (provider.isVerified) const Padding(padding: EdgeInsets.only(left: AppSpacing.xs), child: Icon(Icons.verified_rounded, size: AppSizes.iconSm, color: AppColors.primary))]), const SizedBox(height: AppSpacing.xs), Text(provider.profession, style: AppTextStyles.bodySmall)])),
            ]),
            const SizedBox(height: AppSpacing.lg),
            Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.sm, children: [_Metric(icon: Icons.star_rounded, value: provider.rating.toStringAsFixed(1), color: AppColors.warning), _Metric(icon: Icons.workspace_premium_rounded, value: '${provider.completedJobs} ${l10n.completedJobs}', color: AppColors.primaryDark), _Metric(icon: Icons.near_me_rounded, value: l10n.distanceKm(provider.distanceKm.toStringAsFixed(1)), color: AppColors.secondary)]),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [Expanded(child: Text(provider.isAvailable ? l10n.available : l10n.unavailable, style: AppTextStyles.caption.copyWith(color: provider.isAvailable ? AppColors.success : AppColors.textSecondary))), TextButton(onPressed: onDetails, child: Text(l10n.providerDetails)), const SizedBox(width: AppSpacing.xs), SizedBox(height: AppSizes.buttonHeightSmall, child: ElevatedButton(onPressed: provider.isAvailable ? onSelect : null, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd))), child: Text(l10n.selectProvider)))])
          ]),
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  const _Metric({required this.icon, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: AppSizes.iconSm, color: color), const SizedBox(width: AppSpacing.xs), Text(value, style: AppTextStyles.caption)]);
}

class _ConfirmProviderSheet extends StatelessWidget {
  final MatchedProvider provider;
  final AppLocalizations l10n;
  const _ConfirmProviderSheet({required this.provider, required this.l10n});
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [const _SelectionIcon(), const SizedBox(height: AppSpacing.lg), Text(l10n.confirmProviderQuestion(provider.name), style: AppTextStyles.heading2, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.sm), Text(l10n.providerSnapshot(provider.profession, provider.rating.toStringAsFixed(1)), textAlign: TextAlign.center, style: AppTextStyles.bodyMedium), const SizedBox(height: AppSpacing.xxl), ElevatedButton(onPressed: () => Navigator.of(context).pop(true), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.white, minimumSize: const Size.fromHeight(AppSizes.buttonHeight), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd))), child: Text(l10n.confirmProvider)), TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel))])));
}

class _SelectionIcon extends StatelessWidget {
  const _SelectionIcon();
  @override
  Widget build(BuildContext context) => const Center(child: Icon(Icons.handshake_rounded, color: AppColors.primary, size: AppSizes.iconXl));
}

class _MatchingView extends StatelessWidget {
  const _MatchingView();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [TweenAnimationBuilder<double>(tween: Tween(begin: .85, end: 1.05), duration: const Duration(milliseconds: 900), curve: Curves.easeInOut, builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: const _SelectionIcon()), const SizedBox(height: AppSpacing.xxl), Text(l10n.findingProviders, style: AppTextStyles.heading2, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.sm), Text(l10n.matchingProvidersHelper, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center)])));
  }
}

class _MatchingLoadingScaffold extends StatelessWidget {
  const _MatchingLoadingScaffold();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.scaffoldBackground, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
}

class _MatchingError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _MatchingError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.search_off_rounded, color: AppColors.primaryDark, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium), if (onRetry != null) TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry))])));
}

class _ProviderSelectedState extends StatelessWidget {
  final ProviderSelection selection;
  final VoidCallback onHome;
  const _ProviderSelectedState({required this.selection, required this.onHome});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(backgroundColor: AppColors.scaffoldBackground, body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [TweenAnimationBuilder<double>(tween: Tween(begin: .7, end: 1), duration: const Duration(milliseconds: 520), curve: Curves.easeOutBack, builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: Container(width: 112, height: 112, decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])), child: const Icon(Icons.check_rounded, color: AppColors.white, size: AppSizes.iconXl))), const SizedBox(height: AppSpacing.xxl), Text(l10n.providerSelected, style: AppTextStyles.heading1, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.md), Text(l10n.providerSelectedHelper(selection.provider.name), textAlign: TextAlign.center, style: AppTextStyles.bodyMedium), const SizedBox(height: AppSpacing.sm), Text(l10n.requestReference(selection.requestId), style: AppTextStyles.caption), const SizedBox(height: AppSpacing.xxl), _Metric(icon: Icons.verified_rounded, value: selection.provider.name, color: AppColors.primaryDark), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: l10n.trackJob, onPressed: () => context.push(Uri(path: RouteNames.customerJobTracking, queryParameters: {
              'requestId': selection.requestId,
              'providerId': selection.providerId,
              if (selection.service != null) 'service': selection.service!,
              if (selection.location != null) 'location': selection.location!,
            }).toString())), const SizedBox(height: AppSpacing.md), TextButton(onPressed: onHome, child: Text(l10n.backHome)) ])))));
  }
}
