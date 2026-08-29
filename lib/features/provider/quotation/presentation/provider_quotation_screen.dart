import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smart_trust_app/features/customer/job_request/domain/entities/job_request_entities.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../request_acceptance/domain/entities/provider_request_entities.dart';
import '../../request_acceptance/presentation/providers/provider_request_providers.dart';
import '../../../quotation/domain/entities/quotation_entities.dart';
import 'providers/provider_quotation_providers.dart';

class ProviderQuotationScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;

  const ProviderQuotationScreen({
    super.key,
    required this.requestId,
    required this.providerId,
  });

  @override
  ConsumerState<ProviderQuotationScreen> createState() =>
      _ProviderQuotationScreenState();
}

class _ProviderQuotationScreenState
    extends ConsumerState<ProviderQuotationScreen> {
  final _labor = TextEditingController();
  final _materials = TextEditingController();
  final _additional = TextEditingController();
  final _duration = TextEditingController();
  final _note = TextEditingController();
  bool _loading = false;
  bool _created = false;
  String? _error;

  @override
  void dispose() {
    _labor.dispose();
    _materials.dispose();
    _additional.dispose();
    _duration.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _QuotationLoading();
    if (auth.valueOrNull == null ||
        auth.valueOrNull!.role.toLowerCase() != 'provider')
      return AuthenticationPrompt(message: l10n.providerOnlyMessage);
    if (widget.requestId.isEmpty || widget.providerId.isEmpty)
      return _QuotationError(message: l10n.requestUnavailable);
    if (_created)
      return _QuotationSuccess(
        requestId: widget.requestId,
        onBack: () => context.pop(),
      );

    final requestState = ref.watch(
      providerRequestDetailsProvider((
        requestId: widget.requestId,
        providerId: widget.providerId,
      )),
    );
    return requestState.when(
      loading: () => const _QuotationLoading(),
      error: (_, __) => _QuotationError(message: l10n.requestUnavailable),
      data: (request) {
        if (request.status != RequestLifecycleStatus.accepted)
          return _QuotationError(message: l10n.requestNotAccepted);
        final quoteState = ref.watch(
          providerQuotationByRequestProvider((
            requestId: widget.requestId,
            providerId: widget.providerId,
          )),
        );
        return quoteState.when(
          loading: () => const _QuotationLoading(),
          error: (error, _) =>
              error is QuotationException &&
                  error.code == QuotationFailureCode.quotationNotFound
              ? _CreateQuotationForm(
                  request: request,
                  loading: _loading,
                  error: _error,
                  labor: _labor,
                  materials: _materials,
                  additional: _additional,
                  duration: _duration,
                  note: _note,
                  onChanged: () => setState(() {}),
                  onSubmit: () => _submit(request),
                )
              : _QuotationError(message: l10n.requestActionError),
          data: (quotation) => _ExistingQuotation(
            quotation: quotation,
            loading: _loading,
            onRespond: (accept, total, note) => _respond(accept, total, note),
          ),
        );
      },
    );
  }

  Future<void> _submit(ProviderRequest request) async {
    final l10n = AppLocalizations.of(context)!;
    final labor = double.tryParse(_labor.text.trim());
    final materials = double.tryParse(_materials.text.trim());
    final additional = double.tryParse(_additional.text.trim());
    if (labor == null ||
        materials == null ||
        additional == null ||
        labor < 0 ||
        materials < 0 ||
        additional < 0) {
      setState(() => _error = l10n.invalidAmount);
      return;
    }
    if (_duration.text.trim().isEmpty) {
      setState(() => _error = l10n.durationRequired);
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await ref
          .read(createQuotationProvider)
          .call(
            QuotationDraft(
              requestId: widget.requestId,
              providerId: widget.providerId,
              providerName: request.providerName,
              providerProfession: request.providerProfession,
              providerRating: request.providerRating,
              providerVerified: request.providerVerified,
              laborAmount: labor,
              materialsAmount: materials,
              additionalAmount: additional,
              estimatedDuration: _duration.text.trim(),
              note: _note.text.trim(),
            ),
          );
      if (!mounted) return;
      setState(() {
        _loading = false;
        _created = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.requestActionError;
      });
    }
  }

  Future<void> _respond(bool accept, double? total, String note) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      await ref
          .read(respondToNegotiationProvider)
          .call(
            requestId: widget.requestId,
            providerId: widget.providerId,
            acceptProposal: accept,
            counterTotal: total,
            note: note,
          );
      if (!mounted) return;
      ref.invalidate(
        providerQuotationByRequestProvider((
          requestId: widget.requestId,
          providerId: widget.providerId,
        )),
      );
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = l10n.requestActionError;
      });
    }
  }
}

class _CreateQuotationForm extends StatelessWidget {
  final ProviderRequest request;
  final bool loading;
  final String? error;
  final TextEditingController labor;
  final TextEditingController materials;
  final TextEditingController additional;
  final TextEditingController duration;
  final TextEditingController note;
  final VoidCallback onChanged;
  final VoidCallback onSubmit;

  const _CreateQuotationForm({
    required this.request,
    required this.loading,
    required this.error,
    required this.labor,
    required this.materials,
    required this.additional,
    required this.duration,
    required this.note,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total =
        (double.tryParse(labor.text) ?? 0) +
        (double.tryParse(materials.text) ?? 0) +
        (double.tryParse(additional.text) ?? 0);
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.createQuotation),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xxl,
          AppSpacing.lg,
          AppSpacing.xxl,
          AppSpacing.section,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RequestMiniHeader(request: request),
            const SizedBox(height: AppSpacing.xxl),
            Text(l10n.pricingBreakdown, style: AppTextStyles.heading3),
            const SizedBox(height: AppSpacing.md),
            _MoneyField(
              controller: labor,
              label: l10n.laborCharge,
              icon: Icons.handyman_rounded,
              onChanged: onChanged,
            ),
            _MoneyField(
              controller: materials,
              label: l10n.materialsCharge,
              icon: Icons.inventory_2_rounded,
              onChanged: onChanged,
            ),
            _MoneyField(
              controller: additional,
              label: l10n.additionalCharge,
              icon: Icons.add_card_rounded,
              onChanged: onChanged,
            ),
            const SizedBox(height: AppSpacing.lg),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(AppSizes.radiusLg),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.totalAmount,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white70,
                      ),
                    ),
                  ),
                  Text(
                    l10n.currencyAmount(total.toStringAsFixed(0)),
                    style: AppTextStyles.heading2.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            AppTextField(
              controller: duration,
              label: l10n.estimatedDuration,
              prefixIcon: const Icon(Icons.schedule_rounded),
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: note,
              label: l10n.quotationNote,
              hintText: l10n.quotationNoteHint,
              maxLines: 4,
              minLines: 3,
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.md),
                child: Text(
                  error!,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: l10n.submitQuotation,
              isLoading: loading,
              isEnabled: !loading,
              onPressed: onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoneyField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final VoidCallback onChanged;
  const _MoneyField({
    required this.controller,
    required this.label,
    required this.icon,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: AppSpacing.md),
    child: AppTextField(
      controller: controller,
      label: label,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      prefixIcon: Icon(icon),
      onChanged: (_) => onChanged(),
    ),
  );
}

class _RequestMiniHeader extends StatelessWidget {
  final ProviderRequest request;
  const _RequestMiniHeader({required this.request});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.secondaryLight],
        ),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.requestReference(request.requestId),
            style: AppTextStyles.heading3.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            request.location,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              const Icon(
                Icons.verified_rounded,
                color: AppColors.primaryLight,
                size: AppSizes.iconSm,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                request.providerName,
                style: AppTextStyles.label.copyWith(color: AppColors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExistingQuotation extends StatelessWidget {
  final Quotation quotation;
  final bool loading;
  final void Function(bool accept, double? counter, String note) onRespond;
  const _ExistingQuotation({
    required this.quotation,
    required this.loading,
    required this.onRespond,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.viewQuotation)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.requestReference(quotation.requestId),
              style: AppTextStyles.label.copyWith(color: AppColors.primaryDark),
            ),
            const SizedBox(height: AppSpacing.xl),
            Text(l10n.quotationStatus, style: AppTextStyles.heading2),
            const SizedBox(height: AppSpacing.md),
            _StatusBanner(status: quotation.status),
            const SizedBox(height: AppSpacing.xxl),
            if (quotation.status == QuotationStatus.negotiationRequested)
              _NegotiationResponse(
                quotation: quotation,
                loading: loading,
                onRespond: onRespond,
              )
            else
              _QuotationSummary(quotation: quotation),
          ],
        ),
      ),
    );
  }
}

class _QuotationSummary extends StatelessWidget {
  final Quotation quotation;
  const _QuotationSummary({required this.quotation});
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        AppLocalizations.of(
          context,
        )!.currencyAmount(quotation.totalAmount.toStringAsFixed(0)),
        style: AppTextStyles.heading1,
      ),
      const SizedBox(height: AppSpacing.md),
      Text(quotation.note, style: AppTextStyles.bodyMedium),
    ],
  );
}

class _NegotiationResponse extends StatefulWidget {
  final Quotation quotation;
  final bool loading;
  final void Function(bool, double?, String) onRespond;
  const _NegotiationResponse({
    required this.quotation,
    required this.loading,
    required this.onRespond,
  });
  @override
  State<_NegotiationResponse> createState() => _NegotiationResponseState();
}

class _NegotiationResponseState extends State<_NegotiationResponse> {
  late final TextEditingController _counter;
  final _note = TextEditingController();
  @override
  void initState() {
    super.initState();
    _counter = TextEditingController(
      text: widget.quotation.negotiation!.proposedTotal.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _counter.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.negotiationReceived, style: AppTextStyles.heading2),
        const SizedBox(height: AppSpacing.md),
        Text(
          l10n.currencyAmount(
            widget.quotation.negotiation!.proposedTotal.toStringAsFixed(0),
          ),
          style: AppTextStyles.heading1,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          widget.quotation.negotiation!.note,
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: AppSpacing.xxl),
        AppTextField(
          controller: _counter,
          label: l10n.counterOfferAmount,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: AppSpacing.lg),
        AppTextField(controller: _note, label: l10n.quotationNote, maxLines: 3),
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(
          label: l10n.acceptProposal,
          isLoading: widget.loading,
          isEnabled: !widget.loading,
          onPressed: () => widget.onRespond(
            true,
            double.tryParse(_counter.text),
            _note.text,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(
          onPressed: widget.loading
              ? null
              : () => widget.onRespond(
                  false,
                  double.tryParse(_counter.text),
                  _note.text,
                ),
          child: Text(l10n.sendCounterOffer),
        ),
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final QuotationStatus status;
  const _StatusBanner({required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = status == QuotationStatus.accepted
        ? l10n.statusAccepted
        : status == QuotationStatus.declined
        ? l10n.statusDeclined
        : status == QuotationStatus.negotiationRequested
        ? l10n.statusNegotiationRequested
        : status == QuotationStatus.counterOffered
        ? l10n.statusCounterOffered
        : l10n.statusSubmitted;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusLg),
        border: Border.all(color: AppColors.primary.withOpacity(.24)),
      ),
      child: Text(
        text,
        style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark),
      ),
    );
  }
}

class _QuotationSuccess extends StatelessWidget {
  final String requestId;
  final VoidCallback onBack;
  const _QuotationSuccess({required this.requestId, required this.onBack});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: AppSizes.iconXl,
            color: AppColors.success,
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            AppLocalizations.of(context)!.quotationSubmitted,
            style: AppTextStyles.heading1,
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryButton(
            label: AppLocalizations.of(context)!.back,
            onPressed: onBack,
          ),
        ],
      ),
    ),
  );
}

class _QuotationLoading extends StatelessWidget {
  const _QuotationLoading();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
  );
}

class _QuotationError extends StatelessWidget {
  final String message;
  const _QuotationError({required this.message});
  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Text(message)));
}
