import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/job_tracking_repository_impl.dart';
import '../../domain/entities/job_tracking_entities.dart';
import '../../domain/usecases/get_job_tracking.dart';

final getJobTrackingProvider = Provider<GetJobTracking>((ref) {
  return GetJobTracking(ref.watch(jobTrackingRepositoryProvider));
});

final jobTrackingProvider = FutureProvider.autoDispose
    .family<JobTrackingData, TrackingQuery>((ref, query) {
  return ref.watch(getJobTrackingProvider).call(query: query);
});
