import '../../../../customer/job_request/domain/entities/job_request_entities.dart';

class ProviderRequest {
  final String requestId;
  final String providerId;
  final String providerName;
  final String providerProfession;
  final double providerRating;
  final bool providerVerified;
  final String categoryNameKey;
  final String categoryDescriptionKey;
  final String description;
  final String location;
  final int attachmentCount;
  final RequestLifecycleStatus status;

  const ProviderRequest({
    required this.requestId,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.providerRating,
    required this.providerVerified,
    required this.categoryNameKey,
    required this.categoryDescriptionKey,
    required this.description,
    required this.location,
    required this.attachmentCount,
    required this.status,
  });
}

enum ProviderRequestAction { accepted, declined }

enum ProviderRequestFailureCode {
  invalidRequest,
  unauthorizedProvider,
  alreadyProcessed,
  requestUnavailable,
  unknown,
}

class ProviderRequestException implements Exception {
  final ProviderRequestFailureCode code;

  const ProviderRequestException(this.code);
}

class ProviderRequestActionResult {
  final String requestId;
  final String providerId;
  final ProviderRequestAction action;
  final RequestLifecycleStatus status;

  const ProviderRequestActionResult({
    required this.requestId,
    required this.providerId,
    required this.action,
    required this.status,
  });
}
