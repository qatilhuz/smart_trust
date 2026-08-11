import '../../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../domain/entities/service_completion_entities.dart';

class ServiceCompletionModel {
  final String requestId;
  final String providerId;
  final RequestLifecycleStatus status;
  final DateTime completedAt;

  const ServiceCompletionModel({required this.requestId, required this.providerId, required this.status, required this.completedAt});

  ServiceCompletion toEntity() => ServiceCompletion(requestId: requestId, providerId: providerId, status: status, completedAt: completedAt);
}
