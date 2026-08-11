import '../entities/job_request_entities.dart';

abstract interface class JobRequestCategoryRepository {
  Future<List<RequestCategory>> fetchCategories();
}

abstract interface class JobRequestMediaRepository {
  Future<List<RequestAttachment>> pickImages({required int remainingSlots});
}

abstract interface class JobRequestLocationRepository {
  Future<LocationResult> getCurrentLocation();
}

abstract interface class JobRequestSubmissionRepository {
  Future<CreatedJobRequest> submit({
    required RequestCategory category,
    required String description,
    required List<RequestAttachment> attachments,
    required RequestLocation location,
    required String customerId,
  });
}
