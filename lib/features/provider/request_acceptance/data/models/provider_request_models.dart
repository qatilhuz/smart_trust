import '../../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../domain/entities/provider_request_entities.dart';

class ProviderRequestModel {
  final String requestId;
  final String providerId;
  final String categoryNameKey;
  final String categoryDescriptionKey;
  final String description;
  final String location;
  final int attachmentCount;
  final RequestLifecycleStatus status;

  const ProviderRequestModel({
    required this.requestId,
    required this.providerId,
    required this.categoryNameKey,
    required this.categoryDescriptionKey,
    required this.description,
    required this.location,
    required this.attachmentCount,
    required this.status,
  });

  ProviderRequest toEntity() => ProviderRequest(
        requestId: requestId,
        providerId: providerId,
        categoryNameKey: categoryNameKey,
        categoryDescriptionKey: categoryDescriptionKey,
        description: description,
        location: location,
        attachmentCount: attachmentCount,
        status: status,
      );
}
