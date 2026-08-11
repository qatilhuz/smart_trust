import '../../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../domain/entities/provider_request_entities.dart';

class ProviderRequestModel {
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

  const ProviderRequestModel({
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

  ProviderRequest toEntity() => ProviderRequest(
        requestId: requestId,
        providerId: providerId,
        providerName: providerName,
        providerProfession: providerProfession,
        providerRating: providerRating,
        providerVerified: providerVerified,
        categoryNameKey: categoryNameKey,
        categoryDescriptionKey: categoryDescriptionKey,
        description: description,
        location: location,
        attachmentCount: attachmentCount,
        status: status,
      );
}
