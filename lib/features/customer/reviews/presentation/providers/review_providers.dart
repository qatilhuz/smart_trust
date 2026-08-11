import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/review_repository_impl.dart';
import '../../domain/entities/review_entities.dart';
import '../../domain/usecases/review_usecases.dart';

final submitReviewProvider = Provider<SubmitReview>((ref) => SubmitReview(ref.watch(reviewRepositoryProvider)));
final reviewEligibilityProvider = FutureProvider.autoDispose.family<bool, ({String requestId, String customerId, String providerId})>((ref, query) => CheckReviewEligibility(ref.watch(reviewRepositoryProvider)).call(requestId: query.requestId, customerId: query.customerId, providerId: query.providerId));
final reviewForRequestProvider = FutureProvider.autoDispose.family<Review?, ({String requestId, String customerId, String providerId})>((ref, query) => GetReviewForRequest(ref.watch(reviewRepositoryProvider)).call(requestId: query.requestId, customerId: query.customerId, providerId: query.providerId));
final providerReviewSummaryProvider = FutureProvider.autoDispose.family<ReviewSummary, String>((ref, providerId) => GetProviderReviewSummary(ref.watch(reviewRepositoryProvider)).call(providerId: providerId));
