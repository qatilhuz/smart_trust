import '../../domain/entities/review_entities.dart';
import '../models/review_model.dart';
import '../stores/review_runtime_store.dart';

abstract interface class ReviewDataSource {
  Future<ReviewModel> submit(ReviewDraft draft);
  Future<ReviewModel?> getForRequest({required String requestId, required String customerId, required String providerId});
  Future<bool> isEligible({required String requestId, required String customerId, required String providerId});
  Future<ReviewSummary> getProviderSummary({required String providerId});
}

class ReviewLocalDataSource implements ReviewDataSource {
  final ReviewRuntimeStore _store;
  const ReviewLocalDataSource(this._store);
  @override Future<ReviewModel> submit(ReviewDraft draft) async { await Future<void>.delayed(const Duration(milliseconds: 520)); return ReviewModel(_store.submit(draft)); }
  @override
  Future<ReviewModel?> getForRequest({required String requestId, required String customerId, required String providerId}) async {
    final review = _store.getForRequest(requestId: requestId, customerId: customerId, providerId: providerId);
    return review == null ? null : ReviewModel(review);
  }
  @override Future<bool> isEligible({required String requestId, required String customerId, required String providerId}) async => _store.isEligible(requestId: requestId, customerId: customerId, providerId: providerId);
  @override Future<ReviewSummary> getProviderSummary({required String providerId}) async => _store.getProviderSummary(providerId: providerId);
}
