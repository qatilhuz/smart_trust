import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../quotation/domain/entities/quotation_entities.dart';
import 'providers/customer_quotation_providers.dart';

class CustomerQuotationScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;
  const CustomerQuotationScreen({super.key, required this.requestId, required this.providerId});

  @override
  ConsumerState<CustomerQuotationScreen> createState() => _CustomerQuotationScreenState();
}

class _CustomerQuotationScreenState extends ConsumerState<CustomerQuotationScreen> {
  QuotationActionResult? _result;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _QuoteLoading();
    if (auth.valueOrNull == null || auth.valueOrNull!.role.toLowerCase() != 'customer') return AuthenticationPrompt(message: l10n.customerOnlyMessage);
    if (widget.requestId.isEmpty || widget.providerId.isEmpty) return _QuoteError(message: l10n.requestUnavailable);
    if (_result != null) return _QuoteActionSuccess(result: _result!, onBack: () => context.pop());

    final state = ref.watch(customerQuotationProvider((requestId: widget.requestId, providerId: widget.providerId)));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(title: Text(l10n.viewQuotation), leading: IconButton(onPressed: () => context.pop(), tooltip: l10n.back, icon: const Icon(Icons.arrow_back_rounded))),
      body: state.when(
        loading: () => const _QuoteLoading(),
        error: (_, __) => _QuoteError(message: l10n.quotationNotFound),
        data: (quotation) => _CustomerQuoteView(
          quotation: quotation,
          loading: _loading,
          onAccept: () => _confirmAction(QuotationAction.accepted),
          onDecline: () => _confirmAction(QuotationAction.declined),
          onNegotiate: _negotiate,
        ),
      ),
    );
  }

  Future<void> _confirmAction(QuotationAction action) async {
    final l10n = AppLocalizations.of(context)!;
    final accepting = action == QuotationAction.accepted;
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      builder: (context) => _QuoteActionSheet(
        title: accepting ? l10n.acceptQuotation : l10n.declineQuotation,
        question: accepting ? l10n.acceptQuotationQuestion : l10n.declineQuotationQuestion,
        confirm: accepting ? l10n.acceptQuotation : l10n.declineQuotation,
        destructive: !accepting,
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      final result = accepting
          ? await ref.read(acceptQuotationProvider).call(requestId: widget.requestId, providerId: widget.providerId)
          : await ref.read(declineQuotationProvider).call(requestId: widget.requestId, providerId: widget.providerId);
      if (!mounted) return;
      setState(() { _loading = false; _result = result; });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.quotationActionError)));
    }
  }

  Future<void> _negotiate() async {
    final result = await showModalBottomSheet<_NegotiationValue>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.card,
      builder: (context) => const _NegotiationSheet(),
    );
    if (result == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    setState(() => _loading = true);
    try {
      final action = await ref.read(requestNegotiationProvider).call(requestId: widget.requestId, providerId: widget.providerId, proposedTotal: result.amount, note: result.note);
      if (!mounted) return;
      setState(() { _loading = false; _result = action; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _loading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.quotationActionError)));
    }
  }
}

class _CustomerQuoteView extends StatelessWidget {
  final Quotation quotation;
  final bool loading;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final VoidCallback onNegotiate;
  const _CustomerQuoteView({required this.quotation, required this.loading, required this.onAccept, required this.onDecline, required this.onNegotiate});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final actionable = quotation.status == QuotationStatus.submitted || quotation.status == QuotationStatus.counterOffered;
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.lg, AppSpacing.xxl, AppSpacing.section), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _ProviderHeader(quotation: quotation),
      const SizedBox(height: AppSpacing.xxl),
      Text(l10n.requestReference(quotation.requestId), style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)),
      const SizedBox(height: AppSpacing.lg),
      _PriceBreakdown(quotation: quotation),
      const SizedBox(height: AppSpacing.lg),
      _InfoCard(icon: Icons.schedule_rounded, title: l10n.estimatedDuration, value: quotation.estimatedDuration),
      _InfoCard(icon: Icons.notes_rounded, title: l10n.quotationNote, value: quotation.note),
      const SizedBox(height: AppSpacing.lg),
      _QuoteStatus(status: quotation.status),
      if (actionable) ...[
        const SizedBox(height: AppSpacing.xxl),
        PrimaryButton(label: l10n.acceptQuotation, isLoading: loading, isEnabled: !loading, onPressed: onAccept),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton(onPressed: loading ? null : onNegotiate, style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, minimumSize: const Size.fromHeight(AppSizes.buttonHeight)), child: Text(l10n.negotiateQuotation)),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: loading ? null : onDecline, child: Text(l10n.declineQuotation, style: const TextStyle(color: AppColors.error))),
      ],
    ]));
  }
}

class _ProviderHeader extends StatelessWidget {
  final Quotation quotation;
  const _ProviderHeader({required this.quotation});
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(AppSpacing.xl), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.secondary, AppColors.secondaryLight]), borderRadius: BorderRadius.circular(AppSizes.radiusXl)), child: Row(children: [CircleAvatar(radius: AppSizes.avatarLarge / 2, backgroundColor: AppColors.primary.withOpacity(.18), child: Text(quotation.providerName.characters.first.toUpperCase(), style: AppTextStyles.heading3.copyWith(color: AppColors.white))), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [Flexible(child: Text(quotation.providerName, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.heading3.copyWith(color: AppColors.white))), if (quotation.providerVerified) const Padding(padding: EdgeInsets.only(left: AppSpacing.xs), child: Icon(Icons.verified_rounded, color: AppColors.primaryLight, size: AppSizes.iconSm))]), const SizedBox(height: AppSpacing.xs), Text(quotation.providerProfession, style: AppTextStyles.bodySmall.copyWith(color: AppColors.white70)), const SizedBox(height: AppSpacing.sm), Row(children: [const Icon(Icons.star_rounded, color: AppColors.warning, size: AppSizes.iconSm), const SizedBox(width: AppSpacing.xs), Text(quotation.providerRating.toStringAsFixed(1), style: AppTextStyles.label.copyWith(color: AppColors.white))])]))]));
  }
}

class _PriceBreakdown extends StatelessWidget {
  final Quotation quotation;
  const _PriceBreakdown({required this.quotation});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Container(padding: const EdgeInsets.all(AppSpacing.xl), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusXl), border: Border.all(color: AppColors.border), boxShadow: [BoxShadow(color: AppColors.secondary.withOpacity(.06), blurRadius: AppSpacing.lg, offset: const Offset(0, AppSpacing.sm))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l10n.pricingBreakdown, style: AppTextStyles.heading3), const SizedBox(height: AppSpacing.lg), _AmountRow(label: l10n.laborCharge, amount: quotation.laborAmount), _AmountRow(label: l10n.materialsCharge, amount: quotation.materialsAmount), _AmountRow(label: l10n.additionalCharge, amount: quotation.additionalAmount), const Divider(height: AppSpacing.xxl), Row(children: [Expanded(child: Text(l10n.totalAmount, style: AppTextStyles.heading3)), Text(AppLocalizations.of(context)!.currencyAmount(quotation.totalAmount.toStringAsFixed(0)), style: AppTextStyles.heading2.copyWith(color: AppColors.primaryDark))]) ]));
  }
}

class _AmountRow extends StatelessWidget {
  final String label;
  final double amount;
  const _AmountRow({required this.label, required this.amount});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: AppSpacing.md), child: Row(children: [Expanded(child: Text(label, style: AppTextStyles.bodySmall)), Text(AppLocalizations.of(context)!.currencyAmount(amount.toStringAsFixed(0)), style: AppTextStyles.bodyRegular)]));
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  const _InfoCard({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.border)), child: Row(children: [Icon(icon, color: AppColors.primaryDark), const SizedBox(width: AppSpacing.md), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.xs), Text(value, style: AppTextStyles.bodySmall)]))]));
}

class _QuoteStatus extends StatelessWidget {
  final QuotationStatus status;
  const _QuoteStatus({required this.status});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = status == QuotationStatus.accepted ? l10n.statusAccepted : status == QuotationStatus.declined ? l10n.statusDeclined : status == QuotationStatus.negotiationRequested ? l10n.statusNegotiationRequested : status == QuotationStatus.counterOffered ? l10n.statusCounterOffered : l10n.statusSubmitted;
    return Container(padding: const EdgeInsets.all(AppSpacing.lg), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.08), borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.primary.withOpacity(.24))), child: Row(children: [const Icon(Icons.info_outline_rounded, color: AppColors.primaryDark), const SizedBox(width: AppSpacing.md), Expanded(child: Text(text, style: AppTextStyles.heading3.copyWith(color: AppColors.primaryDark)))]));
  }
}

class _QuoteActionSheet extends StatelessWidget {
  final String title;
  final String question;
  final String confirm;
  final bool destructive;
  const _QuoteActionSheet({required this.title, required this.question, required this.confirm, required this.destructive});
  @override
  Widget build(BuildContext context) => SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.xxl), child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(destructive ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded, color: destructive ? AppColors.error : AppColors.primary, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.lg), Text(title, style: AppTextStyles.heading2), const SizedBox(height: AppSpacing.sm), Text(question, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: confirm, onPressed: () => Navigator.pop(context, true)), TextButton(onPressed: () => Navigator.pop(context, false), child: Text(AppLocalizations.of(context)!.cancel))])));
}

class _NegotiationValue {
  final double amount;
  final String note;
  const _NegotiationValue(this.amount, this.note);
}

class _NegotiationSheet extends StatefulWidget {
  const _NegotiationSheet();
  @override
  State<_NegotiationSheet> createState() => _NegotiationSheetState();
}

class _NegotiationSheetState extends State<_NegotiationSheet> {
  final _amount = TextEditingController();
  final _note = TextEditingController();
  String? _error;
  @override
  void dispose() { _amount.dispose(); _note.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(child: Padding(padding: EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, MediaQuery.viewInsetsOf(context).bottom + AppSpacing.xxl), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(l10n.negotiateQuotation, style: AppTextStyles.heading2), const SizedBox(height: AppSpacing.lg), AppTextField(controller: _amount, label: l10n.negotiationAmount, keyboardType: const TextInputType.numberWithOptions(decimal: true)), const SizedBox(height: AppSpacing.lg), AppTextField(controller: _note, label: l10n.negotiationNote, hintText: l10n.negotiationNoteHint, maxLines: 3), if (_error != null) Text(_error!, style: const TextStyle(color: AppColors.error)), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: l10n.submitNegotiation, onPressed: () { final amount = double.tryParse(_amount.text.trim()); if (amount == null || amount < 0) { setState(() => _error = l10n.negotiationAmountRequired); return; } Navigator.pop(context, _NegotiationValue(amount, _note.text.trim())); })])));
  }
}

class _QuoteActionSuccess extends StatelessWidget {
  final QuotationActionResult result;
  final VoidCallback onBack;
  const _QuoteActionSuccess({required this.result, required this.onBack});
  @override
  Widget build(BuildContext context) { final l10n = AppLocalizations.of(context)!; final text = result.action == QuotationAction.accepted ? l10n.quotationAccepted : result.action == QuotationAction.declined ? l10n.quotationDeclined : l10n.negotiationReceived; return Scaffold(body: Center(child: Padding(padding: const EdgeInsets.all(AppSpacing.xxl), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(result.action == QuotationAction.declined ? Icons.cancel_rounded : Icons.check_circle_rounded, size: 104, color: result.action == QuotationAction.declined ? AppColors.error : AppColors.success), const SizedBox(height: AppSpacing.xxl), Text(text, style: AppTextStyles.heading1, textAlign: TextAlign.center), const SizedBox(height: AppSpacing.xxl), PrimaryButton(label: l10n.back, onPressed: onBack)])))); }
}

class _QuoteLoading extends StatelessWidget { const _QuoteLoading(); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary))); }
class _QuoteError extends StatelessWidget { final String message; const _QuoteError({required this.message}); @override Widget build(BuildContext context) => Scaffold(body: Center(child: Text(message, textAlign: TextAlign.center))); }
