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
import '../domain/entities/provider_request_entities.dart';
import 'providers/provider_request_providers.dart';

class ProviderRequestScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;

  const ProviderRequestScreen({super.key, required this.requestId, required this.providerId});

  @override
  ConsumerState<ProviderRequestScreen> createState() => _ProviderRequestScreenState();
}

class _ProviderRequestScreenState extends ConsumerState<ProviderRequestScreen> {
  ProviderRequestActionResult? _result;
  bool _actionLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _ProviderLoadingScaffold();
    if (auth.valueOrNull == null) return AuthenticationPrompt(message: l10n.providerOnlyMessage);
    if (auth.valueOrNull!.role.toLowerCase() != 'provider') {
      return AuthenticationPrompt(message: l10n.providerOnlyMessage);
    }
    if (widget.requestId.trim().isEmpty || widget.providerId.trim().isEmpty) {
      return _ProviderRequestError(message: l10n.requestUnavailable, onRetry: null);
    }
    if (_result != null) {
      return _ActionSuccess(result: _result!, onFeed: () => context.go(RouteNames.providerFeed), onQuotation: _result!.action == ProviderRequestAction.accepted ? () => context.push(Uri(path: RouteNames.providerQuotation, queryParameters: {'requestId': _result!.requestId, 'providerId': _result!.providerId}).toString()) : null);
    }

    final state = ref.watch(providerRequestDetailsProvider((requestId: widget.requestId, providerId: widget.providerId)));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.providerRequestDetails),
        leading: IconButton(onPressed: _actionLoading ? null : () => context.pop(), tooltip: l10n.back, icon: const Icon(Icons.arrow_back_rounded)),
      ),
      body: state.when(
        loading: () => const _ProviderRequestLoading(),
        error: (error, _) => _ProviderRequestError(message: _failureMessage(l10n, error), onRetry: () => ref.invalidate(providerRequestDetailsProvider((requestId: widget.requestId, providerId: widget.providerId)))),
        data: (request) => _ProviderRequestView(
          request: request,
          loading: _actionLoading,
          onAccept: () => _confirmAction(request, ProviderRequestAction.accepted),
          onDecline: () => _confirmAction(request, ProviderRequestAction.declined),
          onQuotation: request.status == RequestLifecycleStatus.accepted ? () => context.push(Uri(path: RouteNames.providerQuotation, queryParameters: {'requestId': request.requestId, 'providerId': request.providerId}).toString()) : null,
          onChat: request.status == RequestLifecycleStatus.accepted ? () => context.push(Uri(path: RouteNames.providerChat, queryParameters: {'requestId': request.requestId, 'providerId': request.providerId}).toString()) : null,
        ),
      ),
    );
  }

  String _failureMessage(AppLocalizations l10n, Object error) {
    if (error is ProviderRequestException) {
      switch (error.code) {
        case ProviderRequestFailureCode.requestUnavailable:
        case ProviderRequestFailureCode.invalidRequest:
          return l10n.requestUnavailable;
        case ProviderRequestFailureCode.unauthorizedProvider:
          return l10n.providerOnlyMessage;
        case ProviderRequestFailureCode.alreadyProcessed:
          return l10n.alreadyProcessed;
        case ProviderRequestFailureCode.unknown:
          return l10n.requestActionError;
      }
    }
    return l10n.requestActionError;
  }

  Future<void> _confirmAction(ProviderRequest request, ProviderRequestAction action) async {
    final l10n = AppLocalizations.of(context)!;
    final accepting = action == ProviderRequestAction.accepted;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      builder: (context) => _ActionSheet(
        title: accepting ? l10n.acceptRequest : l10n.declineRequest,
        question: accepting ? l10n.acceptThisRequestQuestion : l10n.declineRequestQuestion,
        confirmLabel: accepting ? l10n.acceptRequest : l10n.declineRequest,
        destructive: !accepting,
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _actionLoading = true);
    try {
      final result = accepting
          ? await ref.read(acceptProviderRequestProvider).call(requestId: widget.requestId, providerId: widget.providerId)
          : await ref.read(declineProviderRequestProvider).call(requestId: widget.requestId, providerId: widget.providerId);
      if (!mounted) return;
      setState(() {
        _actionLoading = false;
        _result = result;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _actionLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.requestActionError)));
    }
  }
}

class _ProviderRequestView extends StatelessWidget {
  final ProviderRequest request;
  final bool loading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback? onQuotation;
  final VoidCallback? onChat;

  const _ProviderRequestView({required this.request, required this.loading, required this.onAccept, required this.onDecline, this.onQuotation, this.onChat});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pending = request.status == RequestLifecycleStatus.providerSelected;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.section),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _RequestHeader(request: request),
        const SizedBox(height: AppSpacing.lg),
        _RequestSurface(icon: Icons.category_rounded, title: l10n.service, value: _categoryName(l10n, request.categoryNameKey)),
        _RequestSurface(icon: Icons.notes_rounded, title: l10n.problem, value: request.description),
        _RequestSurface(icon: Icons.location_on_rounded, title: l10n.location, value: request.location),
        if (request.attachmentCount > 0)
          _RequestSurface(icon: Icons.photo_library_rounded, title: l10n.attachments, value: l10n.requestAttachmentsCount(request.attachmentCount)),
        const SizedBox(height: AppSpacing.lg),
        if (pending)
          Row(children: [Expanded(child: PrimaryButton(label: l10n.acceptRequest, isLoading: loading, isEnabled: !loading, onPressed: onAccept)), const SizedBox(width: AppSpacing.md), Expanded(child: OutlinedButton(onPressed: loading ? null : onDecline, style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), minimumSize: const Size.fromHeight(AppSizes.buttonHeight)), child: Text(l10n.declineRequest)))])
        else
          Column(children: [
            _StatusBanner(status: request.status),
            if (onQuotation != null) ...[
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(label: l10n.createQuotation, onPressed: onQuotation!),
            ],
            if (onChat != null) ...[
              const SizedBox(height: AppSpacing.md),
              OutlinedButton.icon(onPressed: onChat, icon: const Icon(Icons.chat_bubble_outline_rounded), label: Text(l10n.chat)),
            ],
          ]),
      ]),
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
}

class _RequestHeader extends StatelessWidget {
  final ProviderRequest request;
  const _RequestHeader({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight]), borderRadius: BorderRadius.circular(AppSizes.radiusXl), boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.16), blurRadius: AppSpacing.xxl, offset: const Offset(0, AppSpacing.md))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(l10n.selectedForRequest, style: AppTextStyles.label.copyWith(color: AppColors.white70)),
        const SizedBox(height: AppSpacing.sm),
        Text(l10n.requestReference(request.requestId), style: AppTextStyles.heading3.copyWith(color: AppColors.white)),
        const SizedBox(height: AppSpacing.lg),
        Row(children: [const Icon(Icons.home_repair_service_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(_categoryName(l10n, request.categoryNameKey), style: AppTextStyles.bodySmall.copyWith(color: AppColors.white)))]),
        const SizedBox(height: AppSpacing.xs),
        Row(children: [const Icon(Icons.location_on_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.sm), Expanded(child: Text(request.location, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70)))]),
      ]),
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
}

class _RequestSurface extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _RequestSurface({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.border)), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(padding: const EdgeInsets.all(AppSpacing.sm), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle), child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.iconMd)), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.xs), Text(value, style: AppTextStyles.bodySmall)]))]));
}

class _StatusBanner extends StatelessWidget {
  final RequestLifecycleStatus status;
  const _StatusBanner({required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accepted = status == RequestLifecycleStatus.accepted;
    return Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: accepted ? AppColors.success.withOpacity(.10) : AppColors.error.withOpacity(.08), borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: accepted ? AppColors.success : AppColors.error)), child: Row(children: [Icon(accepted ? Icons.check_circle_rounded : Icons.cancel_rounded, color: accepted ? AppColors.success : AppColors.error), const SizedBox(width: AppSpacing.md), Expanded(child: Text(accepted ? l10n.requestAcceptedSuccess : l10n.requestDeclined, style: AppTextStyles.heading3))]));
  }
}

class _ActionSheet extends StatelessWidget {
  final String title;
  final String question;
  final String confirmLabel;
  final bool destructive;
  const _ActionSheet({required this.title, required this.question, required this.confirmLabel, required this.destructive});
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(destructive ? Icons.warning_amber_rounded : Icons.handshake_rounded, color: destructive ? AppColors.error : AppColors.primary, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(title, style: AppTextStyles.heading2, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.sm), Text(question, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.xxl), SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: destructive ? AppColors.error : AppColors.primary, foregroundColor: AppColors.white, minimumSize: const Size.fromHeight(AppSizes.buttonHeight), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.radiusMd))), child: Text(confirmLabel))), TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel))])));
}

class _ActionSuccess extends StatelessWidget {
  final ProviderRequestActionResult result;
  final VoidCallback onFeed;
  final VoidCallback? onQuotation;
  const _ActionSuccess({required this.result, required this.onFeed, this.onQuotation});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final accepted = result.action == ProviderRequestAction.accepted;
    return Scaffold(backgroundColor: AppColors.scaffoldBackground, body: SafeArea(child: Center(child: SingleChildScrollView(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [TweenAnimationBuilder<double>(tween: Tween(begin: .7, end: 1), duration: const Duration(milliseconds: 500), curve: Curves.easeOutBack, builder: (context, scale, child) => Transform.scale(scale: scale, child: child), child: Icon(accepted ? Icons.check_circle_rounded : Icons.cancel_rounded, color: accepted ? AppColors.success : AppColors.error, size: 104)), const SizedBox(height: AppSpacing.xxl), Text(accepted ? l10n.requestAcceptedSuccess : l10n.requestDeclined, style: AppTextStyles.heading1, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.md), Text(accepted ? l10n.acceptedRequestHelper : l10n.declinedRequestHelper, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.sm), Text(l10n.requestReference(result.requestId), style: AppTextStyles.caption), const SizedBox(height: AppSpacing.xxl), if (onQuotation != null) PrimaryButton(label: l10n.createQuotation, onPressed: onQuotation!), if (onQuotation != null) const SizedBox(height: AppSpacing.md), TextButton(onPressed: onFeed, child: Text(l10n.incomingRequests))]))));
  }
}

class _ProviderLoadingScaffold extends StatelessWidget {
  const _ProviderLoadingScaffold();
  @override
  Widget build(BuildContext context) => const Scaffold(backgroundColor: AppColors.scaffoldBackground, body: Center(child: CircularProgressIndicator(color: AppColors.primary)));
}

class _ProviderRequestLoading extends StatelessWidget {
  const _ProviderRequestLoading();
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(AppSpacing.xxl), children: [Container(height: 170, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(.18), borderRadius: BorderRadius.circular(AppSizes.radiusXl))), const SizedBox(height: AppSpacing.lg), ...List.generate(3, (index) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), height: 92, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(.12), borderRadius: BorderRadius.circular(AppSizes.radiusLg))))]);
}

class _ProviderRequestError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ProviderRequestError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.assignment_late_rounded, color: AppColors.primaryDark, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodyMedium), if (onRetry != null) TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry))])));
}
