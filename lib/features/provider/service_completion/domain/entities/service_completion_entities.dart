import '../../../../customer/job_request/domain/entities/job_request_entities.dart';

class ServiceCompletion {
  final String requestId;
  final String providerId;
  final RequestLifecycleStatus status;
  final DateTime completedAt;

  const ServiceCompletion({required this.requestId, required this.providerId, required this.status, required this.completedAt});
}

enum CompletionFailureCode { invalidRequest, unauthorizedProvider, quotationNotAccepted, alreadyCompleted, requestUnavailable, unknown }

class CompletionException implements Exception {
  final CompletionFailureCode code;
  const CompletionException(this.code);
}
