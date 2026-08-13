import '../../../job_request/data/stores/customer_request_runtime_store.dart';
import '../../../job_request/domain/entities/job_request_entities.dart';
import '../../../../quotation/data/stores/quotation_runtime_store.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';
import '../../domain/entities/review_entities.dart';

class ReviewRuntimeStore {
  ReviewRuntimeStore._(this._requestStore, this._quotationStore);

  static final ReviewRuntimeStore instance = ReviewRuntimeStore._(CustomerRequestRuntimeStore.instance, QuotationRuntimeStore.instance);
  final CustomerRequestRuntimeStore _requestStore;
  final QuotationRuntimeStore _quotationStore;
  final Map<String, Review> _reviews = {};

  Review submit(ReviewDraft draft) {
    if (draft.rating < 1 || draft.rating > 5) throw const ReviewException(ReviewFailureCode.invalidRating);
    final request = _requestStore.get(draft.requestId);
    if (request == null) throw const ReviewException(ReviewFailureCode.invalidRequest);
    if (request.customerId != draft.customerId || request.providerId != draft.providerId) throw const ReviewException(ReviewFailureCode.unauthorized);
    if (request.status != RequestLifecycleStatus.serviceCompleted) throw const ReviewException(ReviewFailureCode.notCompleted);
    final quotation = _getQuotation(draft.requestId, draft.providerId);
    if (quotation?.status != QuotationStatus.accepted) throw const ReviewException(ReviewFailureCode.quotationNotAccepted);
    final key = _key(draft.requestId, draft.customerId, draft.providerId);
    if (_reviews.containsKey(key)) throw const ReviewException(ReviewFailureCode.alreadyReviewed);
    final now = DateTime.now();
    final review = Review(reviewId: 'local-review-${now.microsecondsSinceEpoch}', requestId: draft.requestId, customerId: draft.customerId, providerId: draft.providerId, providerName: _providerName(draft.providerId), rating: draft.rating, comment: draft.comment.trim(), createdAt: now, updatedAt: now, status: ReviewStatus.submitted);
    _reviews[key] = review;
    return review;
  }

  Review? getForRequest({required String requestId, required String customerId, required String providerId}) {
    final request = _requestStore.get(requestId);
    if (request == null || request.customerId != customerId || request.providerId != providerId) throw const ReviewException(ReviewFailureCode.unauthorized);
    return _reviews[_key(requestId, customerId, providerId)];
  }

  bool isEligible({required String requestId, required String customerId, required String providerId}) {
    final request = _requestStore.get(requestId);
    if (request == null || request.customerId != customerId || request.providerId != providerId) return false;
    if (request.status != RequestLifecycleStatus.serviceCompleted) return false;
    final quotation = _getQuotation(requestId, providerId);
    if (quotation?.status != QuotationStatus.accepted) return false;
    return !_reviews.containsKey(_key(requestId, customerId, providerId));
  }

  ReviewSummary getProviderSummary({required String providerId}) {
    final reviews = _reviews.values.where((review) => review.providerId == providerId).toList(growable: false);
    final distribution = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    for (final review in reviews) distribution[review.rating.round()] = (distribution[review.rating.round()] ?? 0) + 1;
    final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
    return ReviewSummary(providerId: providerId, averageRating: reviews.isEmpty ? 0 : total / reviews.length, totalReviews: reviews.length, ratingDistribution: distribution, reviews: reviews);
  }

  Quotation? _getQuotation(String requestId, String providerId) {
    try { return _quotationStore.get(requestId: requestId, providerId: providerId); } on QuotationException { return null; }
  }

  String _key(String requestId, String customerId, String providerId) => '$requestId::$customerId::$providerId';
  String _providerName(String id) { switch (id) { case 'provider-sara-ahmed': return 'Sara Ahmed'; case 'provider-usman-khan': return 'Usman Khan'; default: return 'Ali Hussain'; } }
}
