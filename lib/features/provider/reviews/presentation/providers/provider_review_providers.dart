import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../customer/reviews/data/repositories/review_repository_impl.dart';
import '../../../../customer/reviews/domain/entities/review_entities.dart';
import '../../../../customer/reviews/domain/usecases/review_usecases.dart';

final providerReviewSummaryProvider = FutureProvider.autoDispose.family<ReviewSummary, String>((ref, providerId) => GetProviderReviewSummary(ref.watch(reviewRepositoryProvider)).call(providerId: providerId));
