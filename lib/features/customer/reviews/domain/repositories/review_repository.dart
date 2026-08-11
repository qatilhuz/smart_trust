import '../entities/review_entities.dart';

abstract interface class ReviewRepository {
  Future<Review> submit(ReviewDraft draft);
  Future<Review?> getForRequest({required String requestId, required String customerId, required String providerId});
  Future<bool> isEligible({required String requestId, required String customerId, required String providerId});
  Future<ReviewSummary> getProviderSummary({required String providerId});
}
