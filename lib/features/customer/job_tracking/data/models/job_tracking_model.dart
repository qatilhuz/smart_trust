import '../../../provider_matching/domain/entities/provider_matching_entities.dart';
import '../../domain/entities/job_tracking_entities.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';

class TrackingEventModel {
  final JobTrackingStatus status;
  final String titleKey;
  final String descriptionKey;
  final String timeKey;

  const TrackingEventModel({
    required this.status,
    required this.titleKey,
    required this.descriptionKey,
    required this.timeKey,
  });

  TrackingEvent toEntity({required bool completed, required bool current}) {
    return TrackingEvent(
      status: status,
      titleKey: titleKey,
      descriptionKey: descriptionKey,
      timeKey: timeKey,
      isCompleted: completed,
      isCurrent: current,
    );
  }
}

class JobTrackingModel {
  final String requestId;
  final String service;
  final String location;
  final JobTrackingStatus currentStatus;
  final MatchedProvider provider;
  final String providerArea;
  final String eta;
  final String distance;
  final String lastUpdated;
  final List<TrackingEventModel> timeline;
  final QuotationStatus? quotationStatus;

  const JobTrackingModel({
    required this.requestId,
    required this.service,
    required this.location,
    required this.currentStatus,
    required this.provider,
    required this.providerArea,
    required this.eta,
    required this.distance,
    required this.lastUpdated,
    required this.timeline,
    required this.quotationStatus,
  });

  JobTrackingData toEntity() {
    final currentIndex = JobTrackingStatus.values.indexOf(currentStatus);
    return JobTrackingData(
      requestId: requestId,
      service: service,
      location: location,
      currentStatus: currentStatus,
      provider: provider,
      providerArea: providerArea,
      eta: eta,
      distance: distance,
      lastUpdated: lastUpdated,
      quotationStatus: quotationStatus,
      timeline: timeline
          .map(
            (event) => event.toEntity(
              completed: JobTrackingStatus.values.indexOf(event.status) < currentIndex,
              current: event.status == currentStatus,
            ),
          )
          .toList(growable: false),
    );
  }
}
