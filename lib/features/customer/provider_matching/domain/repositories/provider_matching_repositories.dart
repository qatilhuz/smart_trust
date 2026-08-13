import '../entities/provider_matching_entities.dart';

abstract interface class ProviderMatchingRepository {
  Future<ProviderMatchResult> findProviders({required String requestId});

  Future<ProviderSelection> selectProvider({
    required String requestId,
    required String providerId,
  });
}
