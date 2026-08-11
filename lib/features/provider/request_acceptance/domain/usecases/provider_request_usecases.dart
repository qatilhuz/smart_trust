import '../entities/provider_request_entities.dart';
import '../repositories/provider_request_repository.dart';

class GetIncomingProviderRequests {
  final ProviderRequestRepository _repository;

  const GetIncomingProviderRequests(this._repository);

  Future<List<ProviderRequest>> call({required String providerId}) {
    return _repository.getIncomingRequests(providerId: providerId);
  }
}

class GetProviderRequest {
  final ProviderRequestRepository _repository;

  const GetProviderRequest(this._repository);

  Future<ProviderRequest> call({required String requestId, required String providerId}) {
    return _repository.getRequest(requestId: requestId, providerId: providerId);
  }
}

class AcceptProviderRequest {
  final ProviderRequestRepository _repository;

  const AcceptProviderRequest(this._repository);

  Future<ProviderRequestActionResult> call({required String requestId, required String providerId}) {
    return _repository.accept(requestId: requestId, providerId: providerId);
  }
}

class DeclineProviderRequest {
  final ProviderRequestRepository _repository;

  const DeclineProviderRequest(this._repository);

  Future<ProviderRequestActionResult> call({required String requestId, required String providerId}) {
    return _repository.decline(requestId: requestId, providerId: providerId);
  }
}
