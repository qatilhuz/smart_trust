import '../../../job_request/data/stores/customer_request_runtime_store.dart';
import '../../../job_request/domain/entities/job_request_entities.dart';
import '../../../provider_matching/domain/entities/provider_matching_entities.dart';
import '../../../../quotation/data/stores/quotation_runtime_store.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';
import '../../domain/entities/job_tracking_entities.dart';
import '../models/job_tracking_model.dart';

abstract interface class JobTrackingDataSource {
  Future<JobTrackingModel> getTracking({required TrackingQuery query});
}

class JobTrackingLocalDataSource implements JobTrackingDataSource {
  @override
  Future<JobTrackingModel> getTracking({required TrackingQuery query}) async {
    if (query.requestId.trim().isEmpty) {
      throw const TrackingException(TrackingFailureCode.invalidRequest);
    }
    if (!query.requestId.startsWith('local-request-')) {
      throw const TrackingException(TrackingFailureCode.requestNotFound);
    }

    final record = CustomerRequestRuntimeStore.instance.get(query.requestId);
    if (record == null) {
      throw const TrackingException(TrackingFailureCode.requestNotFound);
    }
    if (record.providerId != query.providerId) {
      throw const TrackingException(TrackingFailureCode.providerUnavailable);
    }

    final provider = _providerFor(query.providerId);
    if (provider == null) {
      throw const TrackingException(TrackingFailureCode.providerUnavailable);
    }

    await Future<void>.delayed(const Duration(milliseconds: 620));
    Quotation? quotation;
    try {
      quotation = QuotationRuntimeStore.instance.get(requestId: query.requestId, providerId: query.providerId);
    } on QuotationException {
      quotation = null;
    }
    final currentStatus = _trackingStatus(record.status);
    return JobTrackingModel(
      requestId: query.requestId,
      service: query.service ?? 'Requested home service',
      location: query.location ?? record.location.address,
      currentStatus: currentStatus,
      provider: provider,
      providerArea: 'Lahore',
      eta: currentStatus == JobTrackingStatus.providerOnTheWay ? '18 min' : '—',
      distance: '2.0 km',
      lastUpdated: 'trackingNow',
      quotationStatus: quotation?.status,
      timeline: _timelineFor(currentStatus),
    );
  }

  JobTrackingStatus _trackingStatus(RequestLifecycleStatus status) {
    switch (status) {
      case RequestLifecycleStatus.created:
        return JobTrackingStatus.requestCreated;
      case RequestLifecycleStatus.providerSelected:
        return JobTrackingStatus.providerSelected;
      case RequestLifecycleStatus.accepted:
        return JobTrackingStatus.providerAccepted;
      case RequestLifecycleStatus.declined:
        return JobTrackingStatus.providerDeclined;
      case RequestLifecycleStatus.serviceCompleted:
        return JobTrackingStatus.serviceCompleted;
    }
  }

  List<TrackingEventModel> _timelineFor(JobTrackingStatus current) {
    final events = <TrackingEventModel>[
      const TrackingEventModel(status: JobTrackingStatus.requestCreated, titleKey: 'statusRequestCreated', descriptionKey: 'statusRequestCreatedDescription', timeKey: 'trackingEarlier'),
      const TrackingEventModel(status: JobTrackingStatus.providerSelected, titleKey: 'statusProviderSelected', descriptionKey: 'statusProviderSelectedDescription', timeKey: 'trackingMomentAgo'),
    ];
    if (current == JobTrackingStatus.providerDeclined) {
      events.add(const TrackingEventModel(status: JobTrackingStatus.providerDeclined, titleKey: 'statusProviderDeclined', descriptionKey: 'statusProviderDeclinedDescription', timeKey: 'trackingNow'));
      return events;
    }
    if (current == JobTrackingStatus.providerAccepted) {
      events.add(const TrackingEventModel(status: JobTrackingStatus.providerAccepted, titleKey: 'statusProviderAccepted', descriptionKey: 'statusProviderAcceptedDescription', timeKey: 'trackingNow'));
      return events;
    }
    if (current == JobTrackingStatus.providerSelected) return events;
    events.addAll(const [
      TrackingEventModel(status: JobTrackingStatus.providerAccepted, titleKey: 'statusProviderAccepted', descriptionKey: 'statusProviderAcceptedDescription', timeKey: 'trackingEarlier'),
      TrackingEventModel(status: JobTrackingStatus.providerOnTheWay, titleKey: 'statusOnTheWay', descriptionKey: 'statusOnTheWayDescription', timeKey: 'trackingNow'),
      TrackingEventModel(status: JobTrackingStatus.providerArrived, titleKey: 'statusArrived', descriptionKey: 'statusArrivedDescription', timeKey: 'trackingUpcoming'),
      TrackingEventModel(status: JobTrackingStatus.serviceInProgress, titleKey: 'statusInProgress', descriptionKey: 'statusInProgressDescription', timeKey: 'trackingUpcoming'),
      TrackingEventModel(status: JobTrackingStatus.serviceCompleted, titleKey: 'statusCompleted', descriptionKey: 'statusCompletedDescription', timeKey: 'trackingUpcoming'),
    ]);
    return events;
  }

  MatchedProvider? _providerFor(String id) {
    switch (id) {
      case 'provider-ali-hussain':
        return const MatchedProvider(id: 'provider-ali-hussain', name: 'Ali Hussain', profession: 'HVAC Specialist', bio: 'Experienced in residential cooling and air-conditioning repairs.', rating: 4.9, completedJobs: 184, distanceKm: 2, estimatedArrival: '18 min', services: ['HVAC', 'AC repair', 'Cooling systems'], isAvailable: true, isVerified: true);
      case 'provider-sara-ahmed':
        return const MatchedProvider(id: 'provider-sara-ahmed', name: 'Sara Ahmed', profession: 'Home Service Professional', bio: 'Reliable home maintenance specialist with a careful, clean approach.', rating: 4.8, completedJobs: 126, distanceKm: 3, estimatedArrival: '25 min', services: ['Plumbing', 'Maintenance', 'Repairs'], isAvailable: true, isVerified: true);
      case 'provider-usman-khan':
        return const MatchedProvider(id: 'provider-usman-khan', name: 'Usman Khan', profession: 'Maintenance Specialist', bio: 'Trusted for practical home repairs and dependable service.', rating: 4.7, completedJobs: 98, distanceKm: 4.2, estimatedArrival: '32 min', services: ['Electrical', 'General repairs'], isAvailable: true, isVerified: true);
      default:
        return null;
    }
  }
}
