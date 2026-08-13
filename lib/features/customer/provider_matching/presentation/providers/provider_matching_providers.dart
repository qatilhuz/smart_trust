import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/provider_matching_repository_impl.dart';
import '../../domain/entities/provider_matching_entities.dart';
import '../../domain/usecases/provider_matching_usecases.dart';

final getMatchedProvidersProvider = Provider<GetMatchedProviders>((ref) {
  return GetMatchedProviders(ref.watch(providerMatchingRepositoryProvider));
});

final selectProviderUseCaseProvider = Provider<SelectProvider>((ref) {
  return SelectProvider(ref.watch(providerMatchingRepositoryProvider));
});

final matchedProvidersProvider = FutureProvider.autoDispose
    .family<ProviderMatchResult, String>((ref, requestId) {
  return ref.watch(getMatchedProvidersProvider).call(requestId: requestId);
});

final providerSelectionStateProvider = StateProvider.autoDispose<ProviderSelection?>((ref) => null);
