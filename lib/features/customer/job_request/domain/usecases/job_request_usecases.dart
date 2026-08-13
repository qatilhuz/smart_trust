import '../entities/job_request_entities.dart';
import '../repositories/job_request_repositories.dart';

class GetRequestCategories {
  final JobRequestCategoryRepository _repository;

  const GetRequestCategories(this._repository);

  Future<List<RequestCategory>> call() => _repository.fetchCategories();
}

class PickRequestImages {
  final JobRequestMediaRepository _repository;

  const PickRequestImages(this._repository);

  Future<List<RequestAttachment>> call({required int remainingSlots}) {
    return _repository.pickImages(remainingSlots: remainingSlots);
  }
}

class GetCurrentRequestLocation {
  final JobRequestLocationRepository _repository;

  const GetCurrentRequestLocation(this._repository);

  Future<LocationResult> call() => _repository.getCurrentLocation();
}

class SubmitJobRequest {
  final JobRequestSubmissionRepository _repository;

  const SubmitJobRequest(this._repository);

  Future<CreatedJobRequest> call({
    required RequestCategory category,
    required String description,
    required List<RequestAttachment> attachments,
    required RequestLocation location,
    required String customerId,
  }) {
    return _repository.submit(
      category: category,
      description: description,
      attachments: attachments,
      location: location,
      customerId: customerId,
    );
  }
}
