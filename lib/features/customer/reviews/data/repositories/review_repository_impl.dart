import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/review_entities.dart';
import '../../domain/repositories/review_repository.dart';
import '../datasources/review_datasource.dart';
import '../stores/review_runtime_store.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) => ReviewRepositoryImpl(ReviewLocalDataSource(ReviewRuntimeStore.instance)));

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewDataSource _source;
  const ReviewRepositoryImpl(this._source);
  @override Future<Review> submit(ReviewDraft draft) async => (await _source.submit(draft)).toEntity();
  @override Future<Review?> getForRequest({required String requestId, required String customerId, required String providerId}) async => (await _source.getForRequest(requestId: requestId, customerId: customerId, providerId: providerId))?.toEntity();
  @override Future<bool> isEligible({required String requestId, required String customerId, required String providerId}) => _source.isEligible(requestId: requestId, customerId: customerId, providerId: providerId);
  @override Future<ReviewSummary> getProviderSummary({required String providerId}) => _source.getProviderSummary(providerId: providerId);
}
