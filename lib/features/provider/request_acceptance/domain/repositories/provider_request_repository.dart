import '../entities/provider_request_entities.dart';

abstract interface class ProviderRequestRepository {
  Future<List<ProviderRequest>> getIncomingRequests({required String providerId});

  Future<ProviderRequest> getRequest({
    required String requestId,
    required String providerId,
  });

  Future<ProviderRequestActionResult> accept({
    required String requestId,
    required String providerId,
  });

  Future<ProviderRequestActionResult> decline({
    required String requestId,
    required String providerId,
  });
}
