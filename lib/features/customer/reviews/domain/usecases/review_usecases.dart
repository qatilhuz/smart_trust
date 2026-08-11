import '../entities/review_entities.dart';
import '../repositories/review_repository.dart';

class SubmitReview {
  final ReviewRepository _repository;
  const SubmitReview(this._repository);
  Future<Review> call(ReviewDraft draft) => _repository.submit(draft);
}

class GetReviewForRequest {
  final ReviewRepository _repository;
  const GetReviewForRequest(this._repository);
  Future<Review?> call({required String requestId, required String customerId, required String providerId}) => _repository.getForRequest(requestId: requestId, customerId: customerId, providerId: providerId);
}

class CheckReviewEligibility {
  final ReviewRepository _repository;
  const CheckReviewEligibility(this._repository);
  Future<bool> call({required String requestId, required String customerId, required String providerId}) => _repository.isEligible(requestId: requestId, customerId: customerId, providerId: providerId);
}

class GetProviderReviewSummary {
  final ReviewRepository _repository;
  const GetProviderReviewSummary(this._repository);
  Future<ReviewSummary> call({required String providerId}) => _repository.getProviderSummary(providerId: providerId);
}
