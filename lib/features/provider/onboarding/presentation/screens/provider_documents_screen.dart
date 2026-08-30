import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_sizes.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_text_styles.dart';
import '../../../../../core/router/route_names.dart';
import '../../../../../core/widgets/primary_button.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../domain/entities/provider_onboarding_entities.dart';
import '../providers/provider_onboarding_providers.dart';

/// Onboarding step 2: selfie + CNIC images with instant previews, uploaded
/// as multipart/form-data to /api/v1/providers/documents.
class ProviderDocumentsScreen extends ConsumerStatefulWidget {
  const ProviderDocumentsScreen({super.key});

  @override
  ConsumerState<ProviderDocumentsScreen> createState() =>
      _ProviderDocumentsScreenState();
}

class _DocSlot {
  XFile? file;
  Uint8List? bytes;

  bool get isReady => file != null && bytes != null;
}

class _ProviderDocumentsScreenState
    extends ConsumerState<ProviderDocumentsScreen> {
  final _picker = ImagePicker();

  final _selfie = _DocSlot();
  final _cnicFront = _DocSlot();
  final _cnicBack = _DocSlot();

  bool _isSubmitting = false;
  bool _hasError = false;

  Future<void> _pick(_DocSlot slot, ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        slot
          ..file = picked
          ..bytes = bytes;
        _hasError = false;
      });
    } catch (_) {
      if (!mounted) return;
      _showMessage(AppLocalizations.of(context)!.providerDocumentsError);
    }
  }

  Future<void> _chooseSource(_DocSlot slot) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXl),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded,
                  color: AppColors.primary),
              title: Text(l10n.camera),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded,
                  color: AppColors.primary),
              title: Text(l10n.gallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    await _pick(slot, source);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return; // Guard: a request is already in flight.
    final l10n = AppLocalizations.of(context)!;
    if (!_selfie.isReady || !_cnicFront.isReady || !_cnicBack.isReady) {
      _showMessage(l10n.documentsRequired);
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _isSubmitting = true;
      _hasError = false;
    });
    ProviderVerificationEntity? entity;
    var failed = false;
    try {
      final result =
          await ref.read(providerOnboardingRepositoryProvider).uploadDocuments(
                selfiePath: _selfie.file!.path,
                cnicFrontPath: _cnicFront.file!.path,
                cnicBackPath: _cnicBack.file!.path,
              );
      result.when(
        success: (value) => entity = value,
        failure: (_) => failed = true,
      );
    } catch (_) {
      failed = true;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
    if (!mounted) return;

    if (failed || entity == null) {
      setState(() => _hasError = true);
      _showMessage(l10n.providerDocumentsError);
      return;
    }

    // Refresh the app-wide gate with the fresh status before routing.
    ref.invalidate(providerVerificationStatusProvider);
    if (entity!.status == ProviderVerificationStatus.approved) {
      _showMessage(l10n.verificationApproved);
      context.go(RouteNames.providerFeed);
    } else {
      context.go(RouteNames.providerPendingReview);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showLoading = _isSubmitting;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text(l10n.uploadDocuments),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.uploadDocuments,
                    style: AppTextStyles.heading3,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.section),
                  Center(
                    child: _SelfieCircle(
                      slot: _selfie,
                      enabled: !showLoading,
                      addLabel: l10n.profilePhotoAdd,
                      changeLabel: l10n.profilePhotoChange,
                      onPick: () => _chooseSource(_selfie),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.section),
                  _DocumentCard(
                    slot: _cnicFront,
                    enabled: !showLoading,
                    title: l10n.uploadCnicFront,
                    onPick: () => _chooseSource(_cnicFront),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _DocumentCard(
                    slot: _cnicBack,
                    enabled: !showLoading,
                    title: l10n.uploadCnicBack,
                    onPick: () => _chooseSource(_cnicBack),
                  ),
                  if (_hasError) ...[
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.providerDocumentsError,
                      style: const TextStyle(color: AppColors.error),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                  PrimaryButton(
                    label: l10n.submitForReview,
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
    );
  }
}

/// Circular profile-picture style uploader with instant preview.
class _SelfieCircle extends StatelessWidget {
  final _DocSlot slot;
  final bool enabled;
  final String addLabel;
  final String changeLabel;
  final VoidCallback onPick;

  const _SelfieCircle({
    required this.slot,
    required this.enabled,
    required this.addLabel,
    required this.changeLabel,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: slot.isReady ? changeLabel : addLabel,
      child: GestureDetector(
        onTap: enabled ? onPick : null,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(.08),
                border: Border.all(
                  color: slot.isReady ? AppColors.primary : AppColors.border,
                  width: AppSizes.borderWidthFocused,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(.14),
                    blurRadius: AppSpacing.xl,
                    offset: const Offset(0, AppSpacing.sm),
                  ),
                ],
              ),
              child: ClipOval(
                child: slot.isReady
                    ? Image.memory(
                        slot.bytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      )
                    : const Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: AppColors.primaryDark,
                      ),
              ),
            ),
            Positioned.directional(
              textDirection: Directionality.of(context),
              end: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.xs + 2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
                child: Icon(
                  slot.isReady ? Icons.edit_rounded : Icons.add_a_photo_rounded,
                  size: AppSizes.iconSm,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Rectangular document uploader card with instant preview.
class _DocumentCard extends StatelessWidget {
  final _DocSlot slot;
  final bool enabled;
  final String title;
  final VoidCallback onPick;

  const _DocumentCard({
    required this.slot,
    required this.enabled,
    required this.title,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: GestureDetector(
        onTap: enabled ? onPick : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: 148,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSizes.radiusLg),
            border: Border.all(
              color: slot.isReady ? AppColors.primary : AppColors.border,
              width: slot.isReady
                  ? AppSizes.borderWidthFocused
                  : AppSizes.borderWidth,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusLg - 1),
            child: slot.isReady
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(
                        slot.bytes!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                      Positioned.directional(
                        textDirection: Directionality.of(context),
                        end: AppSpacing.sm,
                        top: AppSpacing.sm,
                        child: _PreviewBadge(icon: Icons.edit_rounded),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.upload_file_rounded,
                        color: AppColors.primary,
                        size: AppSizes.iconXl,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                        ),
                        child: Text(
                          title,
                          style: AppTextStyles.label,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _PreviewBadge extends StatelessWidget {
  final IconData icon;

  const _PreviewBadge({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xs),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary,
      ),
      child: Icon(icon, size: AppSizes.iconSm, color: AppColors.white),
    );
  }
}
