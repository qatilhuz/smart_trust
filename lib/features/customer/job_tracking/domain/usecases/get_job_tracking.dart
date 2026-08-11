import '../entities/job_tracking_entities.dart';
import '../repositories/job_tracking_repository.dart';

class GetJobTracking {
  final JobTrackingRepository _repository;

  const GetJobTracking(this._repository);

  Future<JobTrackingData> call({required TrackingQuery query}) {
    return _repository.getTracking(query: query);
  }
}
