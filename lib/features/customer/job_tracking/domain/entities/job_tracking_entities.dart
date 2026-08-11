import '../../../provider_matching/domain/entities/provider_matching_entities.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';

enum JobTrackingStatus {
  requestCreated,
  providerSelected,
  providerAccepted,
  providerDeclined,
  providerOnTheWay,
  providerArrived,
  serviceInProgress,
  serviceCompleted,
}

class TrackingEvent {
  final JobTrackingStatus status;
  final String titleKey;
  final String descriptionKey;
  final String timeKey;
  final bool isCompleted;
  final bool isCurrent;

  const TrackingEvent({
    required this.status,
    required this.titleKey,
    required this.descriptionKey,
    required this.timeKey,
    required this.isCompleted,
    required this.isCurrent,
  });
}

class JobTrackingData {
  final String requestId;
  final String service;
  final String location;
  final JobTrackingStatus currentStatus;
  final MatchedProvider provider;
  final String providerArea;
  final String eta;
  final String distance;
  final String lastUpdated;
  final List<TrackingEvent> timeline;
  final QuotationStatus? quotationStatus;

  const JobTrackingData({
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
}

class TrackingQuery {
  final String requestId;
  final String providerId;
  final String? service;
  final String? location;

  const TrackingQuery({required this.requestId, required this.providerId, this.service, this.location});

  @override
  bool operator ==(Object other) =>
      other is TrackingQuery &&
      other.requestId == requestId &&
      other.providerId == providerId &&
      other.service == service &&
      other.location == location;

  @override
  int get hashCode => Object.hash(requestId, providerId, service, location);
}

enum TrackingFailureCode {
  invalidRequest,
  requestNotFound,
  providerUnavailable,
  unknown,
}

class TrackingException implements Exception {
  final TrackingFailureCode code;

  const TrackingException(this.code);
}
