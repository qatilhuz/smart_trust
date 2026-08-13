class CustomerHomeData {
  final ActiveCustomerJob? activeJob;
  final List<ServiceCategory> categories;
  final List<NearbyProvider> nearbyProviders;

  const CustomerHomeData({
    required this.activeJob,
    required this.categories,
    required this.nearbyProviders,
  });
}

class ActiveCustomerJob {
  final String requestId;
  final String providerId;
  final String service;
  final String location;
  final String providerName;
  final String status;
  final String eta;
  final double progress;

  const ActiveCustomerJob({
    required this.requestId,
    required this.providerId,
    required this.service,
    required this.location,
    required this.providerName,
    required this.status,
    required this.eta,
    required this.progress,
  });
}

class ServiceCategory {
  final String id;
  final String name;
  final String shortLabel;
  final int iconCodePoint;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.shortLabel,
    required this.iconCodePoint,
  });
}

class NearbyProvider {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double distanceKm;
  final bool isRecommended;
  final bool isAvailable;

  const NearbyProvider({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distanceKm,
    required this.isRecommended,
    required this.isAvailable,
  });
}
