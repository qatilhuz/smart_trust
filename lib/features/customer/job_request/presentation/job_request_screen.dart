import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/authentication_prompt.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'domain/entities/job_request_entities.dart';
import 'domain/entities/job_request_state.dart';
import 'providers/job_request_providers.dart';

class JobRequestScreen extends ConsumerStatefulWidget {
  const JobRequestScreen({super.key});

  @override
  ConsumerState<JobRequestScreen> createState() => _JobRequestScreenState();
}

class _JobRequestScreenState extends ConsumerState<JobRequestScreen> {
  static const _stepCount = 5;
  final PageController _pageController = PageController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  int _step = 0;
  bool _locationLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateStep(JobRequestState request, AppLocalizations l10n) {
    switch (_step) {
      case 0:
        if (request.category == null) {
          _showMessage(l10n.categoryRequired);
          return false;
        }
      case 1:
        if (request.description.trim().isEmpty) {
          _showMessage(l10n.descriptionRequired);
          return false;
        }
      case 3:
        if (request.location == null) {
          _showMessage(l10n.locationRequired);
          return false;
        }
    }
    return true;
  }

  void _next(JobRequestState request, AppLocalizations l10n) {
    if (!_validateStep(request, l10n)) return;
    if (_step == _stepCount - 1) {
      ref.read(jobRequestFlowProvider.notifier).submit();
      return;
    }
    _goTo(_step + 1);
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).maybePop();
      return;
    }
    _goTo(_step - 1);
  }

  void _goTo(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _useCurrentLocation(AppLocalizations l10n) async {
    setState(() => _locationLoading = true);
    final result = await ref.read(jobRequestFlowProvider.notifier).useCurrentLocation();
    if (!mounted) return;
    setState(() => _locationLoading = false);
    switch (result.status) {
      case LocationResultStatus.granted:
        if (result.location != null) {
          ref.read(jobRequestFlowProvider.notifier).setLocation(result.location!);
          _addressController.text = result.location!.address;
          _showMessage(l10n.locationConfirmed);
        }
      case LocationResultStatus.denied:
        _showMessage(l10n.locationPermissionDenied);
      case LocationResultStatus.permanentlyDenied:
        _showMessage(l10n.locationPermissionPermanentlyDenied);
      case LocationResultStatus.unavailable:
        _showMessage(l10n.locationUnavailable);
    }
  }

  void _confirmManualLocation(AppLocalizations l10n) {
    final address = _addressController.text.trim();
    if (address.isEmpty) {
      _showMessage(l10n.locationRequired);
      return;
    }
    ref.read(jobRequestFlowProvider.notifier).setLocation(RequestLocation(address: address));
    _showMessage(l10n.locationConfirmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authStateProvider);
    final authenticatedCustomer = authState.valueOrNull?.role.toLowerCase() == 'customer';
    if (authState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.scaffoldBackground,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }
    if (!authenticatedCustomer) {
      return AuthenticationPrompt(message: l10n.customerOnlyMessage);
    }

    final request = ref.watch(jobRequestFlowProvider);
    final submissionStatus = request.submissionStatus;

    if (submissionStatus == JobRequestSubmissionStatus.success) {
      return _RequestSuccessState(
        request: request,
        onHome: () => context.go(RouteNames.customerHome),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.newRequest),
        leading: IconButton(
          onPressed: submissionStatus == JobRequestSubmissionStatus.submitting ? null : _back,
          tooltip: l10n.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.sm, AppSpacing.xxl, AppSpacing.lg),
              child: _RequestProgress(currentStep: _step, count: _stepCount),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _CategoryStep(request: request),
                  _DescriptionStep(request: request, controller: _descriptionController),
                  _MediaStep(request: request, onAdd: () => ref.read(jobRequestFlowProvider.notifier).addImages()),
                  _LocationStep(
                    request: request,
                    addressController: _addressController,
                    isLoading: _locationLoading,
                    onCurrentLocation: () => _useCurrentLocation(l10n),
                    onConfirmManual: () => _confirmManualLocation(l10n),
                  ),
                  _ReviewStep(request: request, onEdit: _goTo),
                ],
              ),
            ),
            _RequestBottomBar(
              label: _step == _stepCount - 1 ? l10n.submitRequest : l10n.next,
              isLoading: submissionStatus == JobRequestSubmissionStatus.submitting,
              onPressed: () => _next(request, l10n),
            ),
            if (submissionStatus == JobRequestSubmissionStatus.failure)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, 0, AppSpacing.xxl, AppSpacing.md),
                child: Text(l10n.requestSubmitError, style: const TextStyle(color: AppColors.error), textAlign: TextAlign.center),
              ),
          ],
        ),
      ),
    );
  }
}

class _RequestProgress extends StatelessWidget {
  final int currentStep;
  final int count;

  const _RequestProgress({required this.currentStep, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final labels = [l10n.stepService, l10n.stepProblem, l10n.stepMedia, l10n.stepLocation, l10n.stepReview];
    return Row(
      children: List.generate(count, (index) {
        final active = index == currentStep;
        final complete = index < currentStep;
        return Expanded(
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                width: AppSizes.iconLg,
                height: AppSizes.iconLg,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: active || complete ? AppColors.primary : AppColors.card,
                  border: Border.all(color: active || complete ? AppColors.primary : AppColors.border),
                ),
                child: Icon(complete ? Icons.check_rounded : _stepIcon(index), size: AppSizes.iconSm, color: active || complete ? AppColors.white : AppColors.textLight),
              ),
              const SizedBox(width: AppSpacing.xs),
              if (active) Expanded(child: Text(labels[index], maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption.copyWith(color: AppColors.primaryDark))),
              if (index < count - 1) Expanded(child: AnimatedContainer(duration: const Duration(milliseconds: 240), height: AppSizes.borderWidthFocused, color: complete ? AppColors.primary : AppColors.border)),
            ],
          ),
        );
      }),
    );
  }

  IconData _stepIcon(int index) => [Icons.category_rounded, Icons.edit_note_rounded, Icons.photo_library_rounded, Icons.location_on_rounded, Icons.fact_check_rounded][index];
}

class _CategoryStep extends StatelessWidget {
  final JobRequestState request;
  const _CategoryStep({required this.request});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer(
      builder: (context, ref, _) {
        final state = ref.watch(requestCategoriesProvider);
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.section),
          child: state.when(
            loading: () => const _CategorySkeleton(),
            error: (_, __) => _InlineError(message: l10n.homeLoadError, onRetry: () => ref.invalidate(requestCategoriesProvider)),
            data: (items) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.selectServiceCategory, style: AppTextStyles.heading2),
                const SizedBox(height: AppSpacing.sm),
                Text(l10n.categoryHelper, style: AppTextStyles.bodyMedium),
                const SizedBox(height: AppSpacing.xxl),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md, childAspectRatio: 1.08),
                  itemCount: items.length,
                  itemBuilder: (context, index) => _CategoryCard(category: items[index], selected: request.category?.id == items[index].id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  final RequestCategory category;
  final bool selected;
  const _CategoryCard({required this.category, required this.selected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final name = _categoryText(l10n, category.nameKey);
    final description = _categoryText(l10n, category.descriptionKey);
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: InkWell(
        onTap: () => ref.read(jobRequestFlowProvider.notifier).selectCategory(category),
        borderRadius: BorderRadius.circular(AppSizes.radiusXl),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withOpacity(.10) : AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusXl),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? AppSizes.borderWidthFocused : AppSizes.borderWidth),
            boxShadow: [BoxShadow(color: selected ? AppColors.primary.withOpacity(.15) : AppColors.secondary.withOpacity(.04), blurRadius: selected ? AppSpacing.lg : AppSpacing.sm, offset: const Offset(0, AppSpacing.xs))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Expanded(child: _IconBubble(icon: IconData(category.iconCodePoint, fontFamily: 'MaterialIcons'), selected: selected)), if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primaryDark)]),
              const Spacer(),
              Text(name, style: AppTextStyles.heading3),
              const SizedBox(height: AppSpacing.xs),
              Text(description, maxLines: 2, overflow: TextOverflow.ellipsis, style: AppTextStyles.caption),
            ],
          ),
        ),
      ),
    );
  }

  String _categoryText(AppLocalizations l10n, String key) {
    switch (key) {
      case 'serviceCategoryHvac': return l10n.serviceCategoryHvac;
      case 'categoryHvacDescription': return l10n.categoryHvacDescription;
      case 'categoryElectrical': return l10n.categoryElectrical;
      case 'categoryPlumbing': return l10n.categoryPlumbing;
      case 'categoryPainting': return l10n.categoryPainting;
      case 'categoryCleaning': return l10n.categoryCleaning;
      case 'categoryElectricalDescription': return l10n.categoryElectricalDescription;
      case 'categoryPlumbingDescription': return l10n.categoryPlumbingDescription;
      case 'categoryPaintingDescription': return l10n.categoryPaintingDescription;
      case 'categoryCleaningDescription': return l10n.categoryCleaningDescription;
      default: return l10n.categoryHelper;
    }
  }
}

class _DescriptionStep extends ConsumerWidget {
  final JobRequestState request;
  final TextEditingController controller;
  const _DescriptionStep({required this.request, required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    if (controller.text != request.description && controller.text.isEmpty) controller.text = request.description;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.describeProblem, style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.problemHelper, style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xxl),
          AppTextField(controller: controller, label: l10n.requestDescription, hintText: l10n.problemHint, maxLines: 6, minLines: 5, maxLength: 500, onChanged: (value) => ref.read(jobRequestFlowProvider.notifier).updateDescription(value)),
        ],
      ),
    );
  }
}

class _MediaStep extends ConsumerWidget {
  final JobRequestState request;
  final VoidCallback onAdd;
  const _MediaStep({required this.request, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.section),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.addImages, style: AppTextStyles.heading2),
          const SizedBox(height: AppSpacing.sm),
          Text(l10n.imagesOptional(4), style: AppTextStyles.bodyMedium),
          const SizedBox(height: AppSpacing.xxl),
          if (request.attachments.isEmpty)
            _MediaEmpty(onAdd: onAdd)
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: AppSpacing.md, mainAxisSpacing: AppSpacing.md),
              itemCount: request.attachments.length + (request.attachments.length < 4 ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == request.attachments.length) return _AddMediaTile(onTap: onAdd);
                return _MediaPreview(attachment: request.attachments[index], onRemove: () => ref.read(jobRequestFlowProvider.notifier).removeImage(index));
              },
            ),
        ],
      ),
    );
  }
}

class _MediaEmpty extends StatelessWidget {
  final VoidCallback onAdd;
  const _MediaEmpty({required this.onAdd});
  @override
  Widget build(BuildContext context) => _AddMediaTile(onTap: onAdd, large: true);
}

class _AddMediaTile extends StatelessWidget {
  final VoidCallback onTap;
  final bool large;
  const _AddMediaTile({required this.onTap, this.large = false});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Semantics(button: true, label: l10n.addImage, child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(AppSizes.radiusXl), child: Container(height: large ? 190 : null, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.06), borderRadius: BorderRadius.circular(AppSizes.radiusXl), border: Border.all(color: AppColors.primaryLight, width: AppSizes.borderWidthFocused)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.add_a_photo_rounded, size: AppSizes.iconXl, color: AppColors.primaryDark), const SizedBox(height: AppSpacing.sm), Text(l10n.addImage, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark))])));
  }
}

class _MediaPreview extends StatelessWidget {
  final RequestAttachment attachment;
  final VoidCallback onRemove;
  const _MediaPreview({required this.attachment, required this.onRemove});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(children: [ClipRRect(borderRadius: BorderRadius.circular(AppSizes.radiusXl), child: attachment.bytes == null ? Container(color: AppColors.surface, child: const Center(child: Icon(Icons.image_rounded, size: AppSizes.iconXl, color: AppColors.primary))) : Image.memory(attachment.bytes!, width: double.infinity, height: double.infinity, fit: BoxFit.cover)), Positioned(top: AppSpacing.sm, right: AppSpacing.sm, child: IconButton(onPressed: onRemove, tooltip: l10n.removeImage, style: IconButton.styleFrom(backgroundColor: AppColors.secondary.withOpacity(.76), foregroundColor: AppColors.white), icon: const Icon(Icons.close_rounded))) ]);
  }
}

class _LocationStep extends StatelessWidget {
  final JobRequestState request;
  final TextEditingController addressController;
  final bool isLoading;
  final VoidCallback onCurrentLocation;
  final VoidCallback onConfirmManual;
  const _LocationStep({required this.request, required this.addressController, required this.isLoading, required this.onCurrentLocation, required this.onConfirmManual});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (addressController.text.isEmpty && request.location?.address.isNotEmpty == true) addressController.text = request.location!.address;
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.section), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(l10n.location, style: AppTextStyles.heading2), const SizedBox(height: AppSpacing.sm), Text(l10n.locationHelper, style: AppTextStyles.bodyMedium), const SizedBox(height: AppSpacing.xxl), _LocationCard(location: request.location), const SizedBox(height: AppSpacing.lg), PrimaryButton(label: isLoading ? l10n.locationLoading : l10n.useCurrentLocation, isLoading: isLoading, isEnabled: !isLoading, onPressed: onCurrentLocation), const SizedBox(height: AppSpacing.xl), Row(children: [const Expanded(child: Divider(color: AppColors.border)), Padding(padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md), child: Text(l10n.manualAddress, style: AppTextStyles.caption)), const Expanded(child: Divider(color: AppColors.border))]), const SizedBox(height: AppSpacing.lg), AppTextField(controller: addressController, label: l10n.requestAddress, hintText: l10n.manualAddressHint, prefixIcon: const Icon(Icons.edit_location_alt_rounded)), const SizedBox(height: AppSpacing.md), OutlinedButton(onPressed: onConfirmManual, style: OutlinedButton.styleFrom(foregroundColor: AppColors.secondary, side: const BorderSide(color: AppColors.border), minimumSize: const Size.fromHeight(AppSizes.buttonHeight)), child: Text(l10n.confirmLocation)) ]));
  }
}

class _LocationCard extends StatelessWidget {
  final RequestLocation? location;
  const _LocationCard({required this.location});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = location != null;
    return AnimatedContainer(duration: const Duration(milliseconds: 240), padding: const EdgeInsets.all(AppSpacing.xl), decoration: BoxDecoration(color: confirmed ? AppColors.primary.withOpacity(.08) : AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusXl), border: Border.all(color: confirmed ? AppColors.primary : AppColors.border, width: confirmed ? AppSizes.borderWidthFocused : AppSizes.borderWidth)), child: Row(children: [const _IconBubble(icon: Icons.location_on_rounded, selected: true), const SizedBox(width: AppSpacing.md), Expanded(child: Text(confirmed ? (location!.address.isEmpty ? l10n.locationConfirmed : location!.address) : l10n.locationHelper, maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall.copyWith(color: confirmed ? AppColors.secondary : AppColors.textSecondary))), if (confirmed) const Icon(Icons.check_circle_rounded, color: AppColors.success) ]));
  }
}

class _ReviewStep extends StatelessWidget {
  final JobRequestState request;
  final ValueChanged<int> onEdit;
  const _ReviewStep({required this.request, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final category = request.category;
    return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.section), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [Text(l10n.reviewRequest, style: AppTextStyles.heading2), const SizedBox(height: AppSpacing.sm), Text(l10n.reviewHelper, style: AppTextStyles.bodyMedium), const SizedBox(height: AppSpacing.xxl), _ReviewCard(title: l10n.service, icon: Icons.category_rounded, value: category == null ? l10n.noData : _categoryName(l10n, category.nameKey), onEdit: () => onEdit(0)), _ReviewCard(title: l10n.problem, icon: Icons.notes_rounded, value: request.description, onEdit: () => onEdit(1)), _ReviewCard(title: l10n.attachments, icon: Icons.photo_library_rounded, value: request.attachments.isEmpty ? l10n.noImages : '${request.attachments.length}', onEdit: () => onEdit(2)), _ReviewCard(title: l10n.location, icon: Icons.location_on_rounded, value: request.location?.address.isNotEmpty == true ? request.location!.address : l10n.locationConfirmed, onEdit: () => onEdit(3)) ]));
  }
  String _categoryName(AppLocalizations l10n, String key) { switch (key) { case 'serviceCategoryHvac': return l10n.serviceCategoryHvac; case 'categoryElectrical': return l10n.categoryElectrical; case 'categoryPlumbing': return l10n.categoryPlumbing; case 'categoryPainting': return l10n.categoryPainting; case 'categoryCleaning': return l10n.categoryCleaning; default: return l10n.noData; } }
}

class _ReviewCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String value;
  final VoidCallback? onEdit;
  const _ReviewCard({required this.title, required this.icon, required this.value, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(AppSizes.radiusLg), border: Border.all(color: AppColors.border)),
      child: Row(
        children: [
          const _SoftIcon(icon: Icons.check_rounded),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: AppTextStyles.label.copyWith(color: AppColors.primaryDark)), const SizedBox(height: AppSpacing.xs), Text(value, maxLines: 3, overflow: TextOverflow.ellipsis, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textPrimary))])),
          if (onEdit != null) IconButton(onPressed: onEdit, tooltip: AppLocalizations.of(context)!.changeRole, icon: const Icon(Icons.edit_rounded, color: AppColors.secondary)),
        ],
      ),
    );
  }
}

class _RequestBottomBar extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;
  const _RequestBottomBar({required this.label, required this.isLoading, required this.onPressed});
  @override
  Widget build(BuildContext context) => SafeArea(top: false, child: Padding(padding: const EdgeInsets.fromLTRB(AppSpacing.xxl, AppSpacing.md, AppSpacing.xxl, AppSpacing.lg), child: PrimaryButton(label: label, isLoading: isLoading, isEnabled: !isLoading, onPressed: onPressed)));
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  final bool selected;
  const _IconBubble({required this.icon, required this.selected});
  @override
  Widget build(BuildContext context) => AnimatedScale(scale: selected ? 1.08 : 1, duration: const Duration(milliseconds: 220), child: Container(padding: const EdgeInsets.all(AppSpacing.md), decoration: BoxDecoration(shape: BoxShape.circle, color: selected ? AppColors.primary : AppColors.primary.withOpacity(.10)), child: Icon(icon, color: selected ? AppColors.white : AppColors.primaryDark, size: AppSizes.iconMd)));
}

class _SoftIcon extends StatelessWidget {
  final IconData icon;
  const _SoftIcon({required this.icon});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(AppSpacing.sm), decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withOpacity(.10)), child: Icon(icon, color: AppColors.primaryDark, size: AppSizes.iconMd));
}

class _CategorySkeleton extends StatelessWidget {
  const _CategorySkeleton();
  @override
  Widget build(BuildContext context) => Column(children: List.generate(3, (index) => Container(margin: const EdgeInsets.only(bottom: AppSpacing.md), height: 90, decoration: BoxDecoration(color: AppColors.primaryLight.withOpacity(.16), borderRadius: BorderRadius.circular(AppSizes.radiusLg)))));
}

class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _InlineError({required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Column(children: [const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: AppSizes.iconXl), const SizedBox(height: AppSpacing.md), Text(message, textAlign: TextAlign.center, style: AppTextStyles.bodySmall), TextButton(onPressed: onRetry, child: Text(AppLocalizations.of(context)!.retry))]);
}

class _RequestSuccessState extends StatelessWidget {
  final JobRequestState request;
  final VoidCallback onHome;

  const _RequestSuccessState({required this.request, required this.onHome});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: .65, end: 1),
                  duration: const Duration(milliseconds: 520),
                  curve: Curves.easeOutBack,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                    child: const Icon(Icons.check_rounded, color: AppColors.white, size: AppSizes.iconXl),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                Text(l10n.requestCreated, style: AppTextStyles.heading1, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.md),
                Text(l10n.requestCreatedHelper, style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
                const SizedBox(height: AppSpacing.xxl),
                if (request.category != null)
                  _ReviewCard(title: l10n.service, icon: Icons.category_rounded, value: _categoryName(l10n, request.category!.nameKey)),
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.findProviders,
                  onPressed: request.submittedRequestId == null
                      ? onHome
                      : () {
                          final query = <String, String>{
                            'requestId': request.submittedRequestId!,
                            'service': _categoryName(l10n, request.category!.nameKey),
                            'location': request.location?.address.isNotEmpty == true
                                ? request.location!.address
                                : l10n.locationConfirmed,
                          };
                          context.push(Uri(path: RouteNames.customerProviderMatching, queryParameters: query).toString());
                        },
                ),
                const SizedBox(height: AppSpacing.md),
                TextButton(onPressed: onHome, child: Text(l10n.backHome)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _categoryName(AppLocalizations l10n, String key) {
    switch (key) {
      case 'serviceCategoryHvac': return l10n.serviceCategoryHvac;
      case 'categoryElectrical': return l10n.categoryElectrical;
      case 'categoryPlumbing': return l10n.categoryPlumbing;
      case 'categoryPainting': return l10n.categoryPainting;
      case 'categoryCleaning': return l10n.categoryCleaning;
      default: return l10n.noData;
    }
  }
}
