import '../entities/service_completion_entities.dart';
import '../repositories/service_completion_repository.dart';

class CompleteService {
  final ServiceCompletionRepository _repository;
  const CompleteService(this._repository);
  Future<ServiceCompletion> call({required String requestId, required String providerId}) => _repository.complete(requestId: requestId, providerId: providerId);
}
