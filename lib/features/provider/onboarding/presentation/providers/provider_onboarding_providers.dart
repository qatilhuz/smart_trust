import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/provider_onboarding_repository_impl.dart';
import '../../domain/entities/provider_onboarding_entities.dart';

/// Service categories for the profile form dropdown, fetched from
/// GET /api/v1/categories. Throws on failure so the UI can offer a retry.
final providerCategoriesProvider =
    FutureProvider<List<ProviderCategory>>((ref) async {
  final result =
      await ref.watch(providerOnboardingRepositoryProvider).fetchCategories();
  return result.when(
    success: (categories) => categories,
    failure: (failure) => Exception(failure.message),
  );
});

/// Sequential onboarding status for the signed-in provider, or null for
/// guests/customers. Resolves strictly in order (profile -> documents ->
/// verificationStatus) and rebuilds automatically with the auth state,
/// driving both the post-login routing and the router gate.
final providerVerificationStatusProvider =
    FutureProvider<ProviderVerificationEntity?>((ref) async {
  final user = await ref.watch(authStateProvider.future);
  if (user == null || !user.role.toLowerCase().contains('provider')) {
    return null;
  }
  final result =
      await ref.watch(providerOnboardingRepositoryProvider).resolveOnboardingStatus();
  return result.when(
    success: (entity) => entity,
    failure: (_) => null,
  );
});
