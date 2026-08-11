import '../entities/provider_matching_entities.dart';
import '../repositories/provider_matching_repositories.dart';

class GetMatchedProviders {
  final ProviderMatchingRepository _repository;

  const GetMatchedProviders(this._repository);

  Future<ProviderMatchResult> call({required String requestId}) {
    return _repository.findProviders(requestId: requestId);
  }
}

class SelectProvider {
  final ProviderMatchingRepository _repository;

  const SelectProvider(this._repository);

  Future<ProviderSelection> call({
    required String requestId,
    required String providerId,
  }) {
    return _repository.selectProvider(
      requestId: requestId,
      providerId: providerId,
    );
  }
}
