import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../../provider/request_acceptance/presentation/providers/provider_request_providers.dart';
import 'domain/entities/service_completion_entities.dart';
import 'providers/service_completion_providers.dart';

class ServiceCompletionScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;
  const ServiceCompletionScreen({super.key, required this.requestId, required this.providerId});
  @override
  ConsumerState<ServiceCompletionScreen> createState() => _ServiceCompletionScreenState();
}

class _ServiceCompletionScreenState extends ConsumerState<ServiceCompletionScreen> {
  bool _loading = false;
  bool _success = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _CompletionLoading();
    if (auth.valueOrNull?.role.toLowerCase() != 'provider') return AuthenticationPrompt(message: l10n.providerOnlyMessage);
    if (widget.requestId.isEmpty || widget.providerId.isEmpty) return _CompletionError(message: l10n.completionUnavailable);
    if (_success) return _CompletionSuccess(requestId: widget.requestId, onBack: () => context.go(RouteNames.providerFeed));
    final requestState = ref.watch(providerRequestDetailsProvider((requestId: widget.requestId, providerId: widget.providerId)));
    return requestState.when(
      loading: () => const _CompletionLoading(),
      error: (_, __) => _CompletionError(message: l10n.completionUnavailable),
      data: (request) {
        if (request.status == RequestLifecycleStatus.serviceCompleted) return _CompletionError(message: l10n.alreadyCompleted);
        if (request.status != RequestLifecycleStatus.accepted) return _CompletionError(message: l10n.completionUnavailable);
        return Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        appBar: AppBar(title: Text(l10n.markServiceCompleted), leading: IconButton(onPressed: _loading ? null : () => context.pop(), tooltip: l10n.back, icon: const Icon(Icons.arrow_back_rounded))),
        body: SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.section), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _CompletionHeader(requestId: request.requestId, location: request.location, category: _categoryName(l10n, request.categoryNameKey)),
          const SizedBox(height: AppSpacing.xxl),
          _CompletionInfo(title: l10n.providerRequestDetails, value: request.description, icon: Icons.notes_rounded),
          _CompletionInfo(title: l10n.quotationStatus, value: l10n.statusAccepted, icon: Icons.receipt_long_rounded),
          _CompletionInfo(title: l10n.requestCompletedContext, value: l10n.markServiceCompletedQuestion, icon: Icons.task_alt_rounded),
          if (_error != null) Padding(padding: const EdgeInsets.only(top: AppSpacing.md), child: Text(_error!, style: const TextStyle(color: AppColors.error))),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(label: l10n.markServiceCompleted, isLoading: _loading, isEnabled: !_loading, onPressed: () => _confirmComplete(l10n)),
        ])),
        );
      },
    );
  }

  String _categoryName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'serviceCategoryHvac': return l10n.serviceCategoryHvac;
      case 'categoryElectrical': return l10n.categoryElectrical;
      case 'categoryPlumbing': return l10n.categoryPlumbing;
      case 'categoryPainting': return l10n.categoryPainting;
      case 'categoryCleaning': return l10n.categoryCleaning;
      default: return l10n.service;
    }
  }

  Future<void> _confirmComplete(AppLocalizations l10n) async {
    final confirm = await showModalBottomSheet<bool>(context: context, showDragHandle: true, backgroundColor: AppColors.card, builder: (context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.task_alt_rounded, color: AppColors.primary, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(l10n.markServiceCompletedQuestion, style: AppTextStyles.heading2, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: l10n.markServiceCompleted, onPressed: () => Navigator.pop(context, true)), TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel))]))));
    if (confirm != true || !mounted) return;
    setState(() { _loading = true; _error = null; });
    try {
      await ref.read(completeServiceProvider).call(requestId: widget.requestId, providerId: widget.providerId);
      if (!mounted) return;
      setState(() { _loading = false; _success = true; });
    } catch (error) {
      if (!mounted) return;
      setState(() { _loading = false; _error = _message(l10n, error); });
    }
  }

  String _message(AppLocalizations l10n, Object error) {
    if (error is CompletionException) {
      switch (error.code) {
        case CompletionFailureCode.quotationNotAccepted:
          return l10n.quotationNotAccepted;
        case CompletionFailureCode.alreadyCompleted:
          return l10n.alreadyCompleted;
        case CompletionFailureCode.unauthorizedProvider:
          return l10n.providerOnlyMessage;
        case CompletionFailureCode.requestUnavailable:
        case CompletionFailureCode.invalidRequest:
          return l10n.completionUnavailable;
        case CompletionFailureCode.unknown:
          return l10n.completionError;
      }
    }
    return l10n.completionError;
  }
}

class _CompletionHeader extends StatelessWidget {
  final String requestId;
  final String location;
  final String category;
  const _CompletionHeader({required this.requestId, required this.location, required this.category});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(padding: const EdgeInsets.all(AppSpacing.xl), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight]), borderRadius: BorderRadius.circular(AppSizes.radiusXl)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.requestReference(requestId), style: AppTextStyles.heading3.copyWith(color: AppColors.white)), const SizedBox(height: AppSpacing.md), Text(l10n.service, style: AppTextStyles.caption.copyWith(color: AppColors.white70)), const SizedBox(height: AppSpacing.xs), Text(category, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)), const SizedBox(height: AppSpacing.md), Row(children: [const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(location, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70)))]) ]));
  }
}

class _CompletionInfo extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _CompletionInfo({required this.title, required this.value, required this.icon});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.border)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: AppColors.primaryDark), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.xs), Text(value, style: AppTextStyles.bodySmall)]))]));
}

class _CompletionSuccess extends StatelessWidget {
  final String requestId;
  final VoidCallback onBack;
  const _CompletionSuccess({required this.requestId, required this.onBack});
  @override
  Widget build(BuildContext context) => Scaffold(backgroundColor: AppColors.scaffoldBackground, body: SafeArea(child: Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [TweenAnimationBuilder<double>(tween: Tween(begin: .7, end: 1), duration: const Duration(milliseconds: 500), curve: Curves.easeOutBack, builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 104)), const SizedBox(height: AppSpacing.xxl), Text(AppLocalizations.of(context)!.serviceCompleted, style: AppTextStyles.heading1, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.md), Text(AppLocalizations.of(context)!.serviceCompletedHelper, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.sm), Text(AppLocalizations.of(context)!.requestReference(requestId), style: AppTextStyles.caption), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: AppLocalizations.of(context)!.back, onPressed: onBack)]))));
}

class _CompletionLoading extends StatelessWidget { const _CompletionLoading(); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))); }
class _CompletionError extends StatelessWidget { final String message; const _CompletionError({required this.message}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text(message, textAlign: TextAlign.center))); }
