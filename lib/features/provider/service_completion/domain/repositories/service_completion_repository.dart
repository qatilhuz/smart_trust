import '../entities/service_completion_entities.dart';

abstract interface class ServiceCompletionRepository {
  Future<ServiceCompletion> complete({required String requestId, required String providerId});
}
