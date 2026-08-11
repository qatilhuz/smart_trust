import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/job_tracking_entities.dart';
import '../../domain/repositories/job_tracking_repository.dart';
import '../datasources/job_tracking_datasource.dart';

final jobTrackingRepositoryProvider = Provider<JobTrackingRepository>((ref) {
  return JobTrackingRepositoryImpl(JobTrackingLocalDataSource());
});

class JobTrackingRepositoryImpl implements JobTrackingRepository {
  final JobTrackingDataSource _dataSource;

  const JobTrackingRepositoryImpl(this._dataSource);

  @override
  Future<JobTrackingData> getTracking({required TrackingQuery query}) async {
    final model = await _dataSource.getTracking(query: query);
    return model.toEntity();
  }
}
