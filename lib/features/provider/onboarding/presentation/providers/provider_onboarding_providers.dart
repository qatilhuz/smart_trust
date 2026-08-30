import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/provider_onboarding_repository_impl.dart';
import '../../domain/entities/provider_onboarding_entities.dart';

/// Fixed provider-service catalog shown in the profile form dropdown.
/// IDs are the backend category identifiers.
class ProviderCategoryOption {
  final int id;
  final String Function(AppLocalizations) label;

  const ProviderCategoryOption(this.id, this.label);
}

final providerCategoryOptions = <ProviderCategoryOption>[
  ProviderCategoryOption(1, (l10n) => l10n.serviceCategoryHvac),
  ProviderCategoryOption(2, (l10n) => l10n.categoryElectrical),
  ProviderCategoryOption(3, (l10n) => l10n.categoryPlumbing),
  ProviderCategoryOption(4, (l10n) => l10n.categoryPainting),
  ProviderCategoryOption(5, (l10n) => l10n.categoryCleaning),
];

/// Session marker set after step 1 (profile) succeeds. Lets the router
/// distinguish "profile missing" from "documents missing" even though the
/// documents lookup reports 404 for both. Reset on logout.
final providerProfileSubmittedProvider = StateProvider<bool>((ref) => false);

/// Current verification status for the signed-in provider, or null for
/// guests/customers. Drives the router gate and the post-login routing.
///
/// A `missingProfile` result means onboarding step 1 must run first;
/// `pendingReview` blocks every home surface until APPROVED arrives.
final providerVerificationStatusProvider =
    FutureProvider<ProviderVerificationEntity?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null || !user.role.toLowerCase().contains('provider')) {
    return null;
  }
  final result =
      await ref.watch(providerOnboardingRepositoryProvider).fetchDocumentsStatus();
  return result.when(
    success: (entity) => entity,
    failure: (_) => null,
  );
});
