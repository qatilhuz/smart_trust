class Review {
  final String reviewId;
  final String requestId;
  final String customerId;
  final String providerId;
  final String providerName;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final DateTime updatedAt;
  final ReviewStatus status;

  const Review({
    required this.reviewId,
    required this.requestId,
    required this.customerId,
    required this.providerId,
    required this.providerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.status,
  });
}

enum ReviewStatus { submitted }

class ReviewDraft {
  final String requestId;
  final String customerId;
  final String providerId;
  final double rating;
  final String comment;

  const ReviewDraft({required this.requestId, required this.customerId, required this.providerId, required this.rating, required this.comment});
}

class ReviewSummary {
  final String providerId;
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;
  final List<Review> reviews;

  const ReviewSummary({required this.providerId, required this.averageRating, required this.totalReviews, required this.ratingDistribution, required this.reviews});
}

enum ReviewFailureCode { invalidRequest, unauthorized, notCompleted, quotationNotAccepted, alreadyReviewed, invalidRating, unknown }

class ReviewException implements Exception {
  final ReviewFailureCode code;
  const ReviewException(this.code);
}
