import '../entities/job_tracking_entities.dart';

abstract interface class JobTrackingRepository {
  Future<JobTrackingData> getTracking({required TrackingQuery query});
}
