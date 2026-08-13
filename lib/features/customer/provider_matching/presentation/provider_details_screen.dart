import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/constant.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../domain/entities/provider_matching_entities.dart';
import '../domain/entities/provider_matching_failures.dart';
import 'providers/provider_matching_providers.dart';

class ProviderDetailsScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;
  final String? service;
  final String? location;

  const ProviderDetailsScreen({super.key, required this.requestId, required this.providerId, this.service, this.location});

  @override
  ConsumerState<ProviderDetailsScreen> createState() => _ProviderDetailsScreenState();
}

class _ProviderDetailsScreenState extends ConsumerState<ProviderDetailsScreen> {
  bool _loading = false;
  bool _selected = false;
  MatchedProvider? _provider;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
    if (auth.valueOrNull?.role.toLowerCase() != 'customer') return AuthenticationPrompt(message: l10n.customerOnlyMessage);
    if (_selected && _provider != null) return _Success(provider: _provider!, requestId: widget.requestId, service: widget.service, location: widget.location, onHome: () => context.go(RouteNames.customerHome));

    final matches = ref.watch(matchedProvidersProvider(widget.requestId));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.providerDetails), leading: IconButton(onPressed: () => context.pop(), tooltip: l10n.back, icon: const Icon(Icons.arrow_back_rounded))),
      body: matches.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => _DetailsError(message: _errorText(l10n, error)),
        data: (result) {
          MatchedProvider? provider;
          for (final item in result.providers) {
            if (item.id == widget.providerId) {
              provider = item;
              break;
            }
          }
          if (provider == null) return _DetailsError(message: l10n.providerNotAvailable);
          _provider = provider;
          return _Details(provider: provider, loading: _loading, service: widget.service, location: widget.location, onSelect: () => _confirm(provider!));
        },
      ),
    );
  }

  String _errorText(AppLocalizations l10n, Object error) {
    if (error is ProviderMatchingException && error.code == ProviderMatchingFailureCode.invalidRequest) return l10n.requestUnavailable;
    return l10n.matchingError;
  }

  Future<void> _confirm(MatchedProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.confirmProvider),
        content: Text(l10n.confirmProviderQuestion(provider.name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(l10n.confirmProvider)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      final selected = await ref.read(selectProviderUseCaseProvider).call(requestId: widget.requestId, providerId: provider.id);
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
        _loading = false;
        _selected = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.providerSelectionError)));
    }
  }
}

class _Details extends StatelessWidget {
  final MatchedProvider provider;
  final bool loading;
  final String? service;
  final String? location;
  final VoidCallback onSelect;

  const _Details({required this.provider, required this.loading, this.service, this.location, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.section),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Center(child: CircleAvatar(radius: AppSizes.avatarLarge / 2, backgroundColor: AppColors.primary.withOpacity(.12), child: Text(provider.name.characters.first.toUpperCase(), style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark)))),
        const SizedBox(height: AppSpacing.lg),
        Text(provider.name, style: AppTextStyles.heading2, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.xs),
        Text(provider.profession, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: AppSpacing.lg),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [if (provider.isVerified) _Tag(icon: Icons.verified_rounded, label: l10n.verified), _Tag(icon: Icons.star_rounded, label: provider.rating.toStringAsFixed(1)), _Tag(icon: Icons.near_me_rounded, label: l10n.distanceKm(provider.distanceKm.toStringAsFixed(1)))]),
        const SizedBox(height: AppSpacing.section),
        if (service != null || location != null)
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.primary.withOpacity(.22))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n.requestContext, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
              if (service != null) Text(service!, style: AppTextStyles.bodySmall),
              if (location != null) Text(location!, style: AppTextStyles.caption),
            ]),
          ),
        const SizedBox(height: AppSpacing.lg),
        _InfoSection(title: l10n.providerBio, child: Text(provider.bio, style: AppTextStyles.bodyRegular)),
        const SizedBox(height: AppSpacing.lg),
        _InfoSection(title: l10n.services, child: Wrap(spacing: AppSpacing.sm, runSpacing: AppSpacing.sm, children: provider.services.map((service) => Chip(label: Text(service), backgroundColor: AppColors.primary.withOpacity(.08), side: BorderSide.none)).toList())),
        const SizedBox(height: AppSpacing.lg),
        _InfoSection(title: l10n.completedJobs, child: Text('${provider.completedJobs}', style: AppTextStyles.heading3)),
        const SizedBox(height: AppSpacing.section),
        PrimaryButton(label: l10n.selectProvider, isLoading: loading, isEnabled: !loading && provider.isAvailable, onPressed: onSelect),
      ]),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Tag({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs), child: Container(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusPill), border: Border.all(color: AppColors.border)), child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: AppSizes.iconSm, color: AppColors.primaryDark), const SizedBox(width: AppSpacing.xs), Text(label, style: AppTextStyles.caption)])));
}

class _InfoSection extends StatelessWidget {
  final String title;
  final Widget child;
  const _InfoSection({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.border)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.sm), child]));
}

class _DetailsError extends StatelessWidget {
  final String message;
  const _DetailsError({required this.message});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium)));
}

class _Success extends StatelessWidget {
  final MatchedProvider provider;
  final String requestId;
  final String? service;
  final String? location;
  final VoidCallback onHome;
  const _Success({required this.provider, required this.requestId, this.service, this.location, required this.onHome});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(backgroundColor: AppColors.scaffoldBackground, body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [TweenAnimationBuilder<double>(tween: Tween(begin: .7, end: 1), duration: const Duration(milliseconds: 500), curve: Curves.easeOutBack, builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 104)), const SizedBox(height: AppSpacing.xxl), Text(l10n.providerSelected, style: AppTextStyles.heading1, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.md), Text(l10n.providerSelectedHelper(provider.name), style: AppTextStyles.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.sm), Text(l10n.requestReference(requestId), style: AppTextStyles.caption), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: l10n.trackJob, onPressed: () => context.push(Uri(path: RouteNames.customerJobTracking, queryParameters: {
              'requestId': requestId,
              'providerId': provider.id,
              if (service != null) 'service': service!,
              if (location != null) 'location': location!,
            }).toString())), const SizedBox(height: AppSpacing.md), TextButton(onPressed: onHome, child: Text(l10n.backHome))])))));
  }
}
