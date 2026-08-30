import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/widgets/app_text_field.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../l10n/app_localizations.dart';
import '../providers/provider_onboarding_providers.dart';

/// Onboarding step 1 for service providers: professional profile.
/// On success POSTs /api/v1/providers/profile and moves to the documents
/// upload step.
class ProviderProfileFormScreen extends ConsumerStatefulWidget {
  const ProviderProfileFormScreen({super.key});

  @override
  ConsumerState<ProviderProfileFormScreen> createState() =>
      _ProviderProfileFormScreenState();
}

class _ProviderProfileFormScreenState
    extends ConsumerState<ProviderProfileFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _experienceController = TextEditingController();
  final _skillController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();

  int? _categoryId;
  final _skills = <String>[];
  bool _hasError = false;

  /// True from tap until the BE response is fully handled — guarantees a
  /// single profile submission.
  bool _isSubmitting = false;

  @override
  void dispose() {
    for (final controller in [
      _fullNameController,
      _experienceController,
      _skillController,
      _bioController,
      _addressController,
      _cityController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() {
      _skills.add(skill);
      _skillController.clear();
    });
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // Guard: a request is already in flight.
    if (!_formKey.currentState!.validate()) return;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSubmitting = true;
      _hasError = false;
    });
    try {
      var ok = false;
      await ref
          .read(providerOnboardingRepositoryProvider)
          .submitProfile(
            fullName: _fullNameController.text.trim(),
            categoryId: _categoryId!,
            experienceYears: int.parse(_experienceController.text.trim()),
            skills: List.unmodifiable(_skills),
            bio: _bioController.text.trim(),
            address: _addressController.text.trim(),
            city: _cityController.text.trim(),
          )
          .when(
            success: (_) => ok = true,
            failure: (_) => ok = false,
          );
      if (!mounted) return;
      if (ok) {
        // Step 1 done: the router now expects the documents step next.
        ref.read(providerProfileSubmittedProvider.notifier).state = true;
        context.push(RouteNames.providerDocumentsUpload);
      } else {
        setState(() => _hasError = true);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showLoading = _isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.fullName),
        leading: IconButton(
          tooltip: l10n.back,
          onPressed: showLoading ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xxl,
              AppSpacing.md,
              AppSpacing.xxl,
              AppSpacing.section,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.providerRole,
                      style: AppTextStyles.heading3,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      l10n.profileCompletionHelper,
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.section),
                    AppTextField(
                      controller: _fullNameController,
                      label: l10n.fullName,
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      textInputAction: TextInputAction.next,
                      enabled: !showLoading,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.requiredField
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    DropdownButtonFormField<int>(
                      value: _categoryId,
                      decoration: InputDecoration(
                        labelText: l10n.chooseCategory,
                        prefixIcon: const Icon(Icons.category_rounded),
                      ),
                      items: providerCategoryOptions
                          .map(
                            (option) => DropdownMenuItem<int>(
                              value: option.id,
                              child: Text(option.label(l10n)),
                            ),
                          )
                          .toList(),
                      onChanged: showLoading
                          ? null
                          : (value) => setState(() => _categoryId = value),
                      validator: (value) =>
                          value == null ? l10n.categoryRequired : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _experienceController,
                      label: l10n.yearsExperience,
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.work_history_rounded),
                      textInputAction: TextInputAction.next,
                      enabled: !showLoading,
                      validator: (value) {
                        final years = int.tryParse(value?.trim() ?? '');
                        if (years == null || years < 0 || years > 60) {
                          return l10n.invalidExperience;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    // Skills chips input.
                    Text(l10n.skillsAreas, style: AppTextStyles.label),
                    const SizedBox(height: AppSpacing.xs),
                    AppTextField(
                      controller: _skillController,
                      label: l10n.addSkill,
                      hintText: l10n.addSkillHint,
                      enabled: !showLoading,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        tooltip: l10n.addSkill,
                        onPressed: showLoading ? null : _addSkill,
                        icon: const Icon(Icons.add_circle_rounded,
                            color: AppColors.primary),
                      ),
                    ),
                    if (_skills.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: _skills
                            .map(
                              (skill) => InputChip(
                                label: Text(skill),
                                onDeleted: showLoading
                                    ? null
                                    : () =>
                                        setState(() => _skills.remove(skill)),
                                backgroundColor: AppColors.card,
                                side: const BorderSide(color: AppColors.border),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _bioController,
                      label: l10n.bioLabel,
                      hintText: l10n.reviewHint,
                      maxLines: 3,
                      minLines: 3,
                      enabled: !showLoading,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _addressController,
                      label: l10n.addressLine,
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      textInputAction: TextInputAction.next,
                      enabled: !showLoading,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.requiredField
                              : null,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    AppTextField(
                      controller: _cityController,
                      label: l10n.city,
                      prefixIcon: const Icon(Icons.location_city_rounded),
                      textInputAction: TextInputAction.done,
                      enabled: !showLoading,
                      validator: (value) =>
                          (value == null || value.trim().isEmpty)
                              ? l10n.requiredField
                              : null,
                    ),
                    if (_hasError) ...[
                      const SizedBox(height: AppSpacing.md),
                      _FormError(message: l10n.providerProfileError),
                    ],
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryButton(
                      label: l10n.next,
                      isEnabled: !showLoading,
                      isLoading: showLoading,
                      onPressed: _submit,
                    ),
                    SizedBox(height: AppSizes.buttonHeightSmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FormError extends StatelessWidget {
  final String message;

  const _FormError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(.08),
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
        border: Border.all(color: AppColors.error.withOpacity(.22)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: AppColors.error, size: AppSizes.iconSm),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
