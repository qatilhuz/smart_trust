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
import '../../job_request/domain/entities/job_request_entities.dart';
import '../domain/entities/review_entities.dart';
import 'providers/review_providers.dart';

class CustomerReviewScreen extends ConsumerStatefulWidget {
  final String requestId;
  final String providerId;
  final String? providerName;
  final String? service;
  const CustomerReviewScreen({
    super.key,
    required this.requestId,
    required this.providerId,
    this.providerName,
    this.service,
  });
  @override
  ConsumerState<CustomerReviewScreen> createState() =>
      _CustomerReviewScreenState();
}

class _CustomerReviewScreenState extends ConsumerState<CustomerReviewScreen> {
  final _comment = TextEditingController();
  double _rating = 0;
  bool _submitting = false;
  Review? _submitted;
  String? _error;
  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authStateProvider);
    if (auth.isLoading) return const _ReviewLoading();
    if (auth.valueOrNull == null ||
        auth.valueOrNull!.role.toLowerCase() != 'customer')
      return AuthenticationPrompt(message: l10n.customerOnlyMessage);
    if (widget.requestId.isEmpty || widget.providerId.isEmpty)
      return _ReviewError(message: l10n.reviewUnavailable);
    if (_submitted != null)
      return _ReviewSuccess(review: _submitted!, onBack: () => context.pop());
    final query = (
      requestId: widget.requestId,
      customerId: auth.valueOrNull!.id,
      providerId: widget.providerId,
    );
    final existing = ref.watch(reviewForRequestProvider(query));
    final eligible = ref.watch(reviewEligibilityProvider(query));
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.reviewProvider),
        leading: IconButton(
          onPressed: () => context.pop(),
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: existing.when(
        loading: () => const _ReviewLoading(),
        error: (_, __) => _ReviewError(message: l10n.reviewUnavailable),
        data: (review) {
          if (review != null) return _ExistingReview(review: review);
          return eligible.when(
            loading: () => const _ReviewLoading(),
            error: (_, __) => _ReviewError(message: l10n.reviewUnavailable),
            data: (canReview) => canReview
                ? _ReviewForm(
                    providerName: widget.providerName ?? widget.providerId,
                    service: widget.service ?? l10n.service,
                    rating: _rating,
                    comment: _comment,
                    submitting: _submitting,
                    error: _error,
                    onRating: (value) => setState(() => _rating = value),
                    onSubmit: () => _submit(auth.valueOrNull!.id),
                  )
                : _ReviewError(message: l10n.reviewPendingCompletion),
          );
        },
      ),
    );
  }

  Future<void> _submit(String customerId) async {
    final l10n = AppLocalizations.of(context)!;
    if (_rating < 1) {
      setState(() => _error = l10n.reviewRequired);
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final review = await ref
          .read(submitReviewProvider)
          .call(
            ReviewDraft(
              requestId: widget.requestId,
              customerId: customerId,
              providerId: widget.providerId,
              rating: _rating,
              comment: _comment.text.trim(),
            ),
          );
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _submitted = review;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error =
            error is ReviewException &&
                error.code == ReviewFailureCode.alreadyReviewed
            ? l10n.alreadyReviewed
            : l10n.reviewError;
      });
    }
  }
}

class _ReviewForm extends StatelessWidget {
  final String providerName;
  final String service;
  final double rating;
  final TextEditingController comment;
  final bool submitting;
  final String? error;
  final ValueChanged<double> onRating;
  final VoidCallback onSubmit;
  const _ReviewForm({
    required this.providerName,
    required this.service,
    required this.rating,
    required this.comment,
    required this.submitting,
    required this.error,
    required this.onRating,
    required this.onSubmit,
  });
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.lg,
        AppSpacing.xxl,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryLight],
              ),
              borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: AppSizes.avatarLarge / 2,
                  backgroundColor: AppColors.primary.withOpacity(.18),
                  child: Text(
                    providerName.characters.first.toUpperCase(),
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        providerName,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        service,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(l10n.requestCompletedContext, style: AppTextStyles.heading3),
          const SizedBox(height: AppSpacing.xs),
          Text(l10n.reviewProviderHelper, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.section),
          Text(
            l10n.yourRating,
            style: AppTextStyles.heading3,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => _RatingStar(
                index: index,
                selected: rating >= index + 1,
                onTap: () => onRating(index + 1.0),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.section),
          AppTextField(
            controller: comment,
            label: l10n.writeReview,
            hintText: l10n.reviewHint,
            maxLines: 5,
            minLines: 4,
            maxLength: 500,
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
            label: l10n.submitReview,
            isLoading: submitting,
            isEnabled: !submitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}

class _RatingStar extends StatelessWidget {
  final int index;
  final bool selected;
  final VoidCallback onTap;
  const _RatingStar({
    required this.index,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    label: '${index + 1}',
    child: IconButton(
      onPressed: onTap,
      icon: AnimatedScale(
        scale: selected ? 1.12 : 1,
        duration: const Duration(milliseconds: 180),
        child: Icon(
          selected ? Icons.star_rounded : Icons.star_outline_rounded,
          size: AppSizes.iconXl,
          color: selected ? AppColors.warning : AppColors.textLight,
        ),
      ),
    ),
  );
}

class _ExistingReview extends StatelessWidget {
  final Review review;
  const _ExistingReview({required this.review});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.alreadyReviewed,
              style: AppTextStyles.heading2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              '${review.rating.toStringAsFixed(0)} / 5',
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              review.comment.isEmpty ? l10n.noReviews : review.comment,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewSuccess extends StatelessWidget {
  final Review review;
  final VoidCallback onBack;
  const _ReviewSuccess({required this.review, required this.onBack});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: .7, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, scale, child) =>
                    Transform.scale(scale: scale, child: child),
                child: const Icon(
                  Icons.star_rounded,
                  color: AppColors.warning,
                  size: 104,
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              Text(
                l10n.reviewSubmitted,
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.reviewSubmittedHelper,
                style: AppTextStyles.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryButton(label: l10n.back, onPressed: onBack),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewLoading extends StatelessWidget {
  const _ReviewLoading();
  @override
  Widget build(BuildContext context) => const Scaffold(
    body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
  );
}

class _ReviewError extends StatelessWidget {
  final String message;
  const _ReviewError({required this.message});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyMedium,
        ),
      ),
    ),
  );
}
