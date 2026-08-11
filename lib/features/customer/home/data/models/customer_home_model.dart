import '../../domain/entities/customer_home_data.dart';

class CustomerHomeModel {
  final ActiveCustomerJobModel? activeJob;
  final List<ServiceCategoryModel> categories;
  final List<NearbyProviderModel> nearbyProviders;

  const CustomerHomeModel({
    required this.activeJob,
    required this.categories,
    required this.nearbyProviders,
  });

  CustomerHomeData toEntity() {
    return CustomerHomeData(
      activeJob: activeJob?.toEntity(),
      categories: categories.map((category) => category.toEntity()).toList(growable: false),
      nearbyProviders: nearbyProviders.map((provider) => provider.toEntity()).toList(growable: false),
    );
  }
}

class ActiveCustomerJobModel {
  final String requestId;
  final String providerId;
  final String service;
  final String location;
  final String providerName;
  final String status;
  final String eta;
  final double progress;

  const ActiveCustomerJobModel({
    required this.requestId,
    required this.providerId,
    required this.service,
    required this.location,
    required this.providerName,
    required this.status,
    required this.eta,
    required this.progress,
  });

  ActiveCustomerJob toEntity() => ActiveCustomerJob(
        requestId: requestId,
        providerId: providerId,
        service: service,
        location: location,
        providerName: providerName,
        status: status,
        eta: eta,
        progress: progress,
      );
}

class ServiceCategoryModel {
  final String id;
  final String name;
  final String shortLabel;
  final int iconCodePoint;

  const ServiceCategoryModel({
    required this.id,
    required this.name,
    required this.shortLabel,
    required this.iconCodePoint,
  });

  ServiceCategory toEntity() => ServiceCategory(
        id: id,
        name: name,
        shortLabel: shortLabel,
        iconCodePoint: iconCodePoint,
      );
}

class NearbyProviderModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final double distanceKm;
  final bool isRecommended;
  final bool isAvailable;

  const NearbyProviderModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.distanceKm,
    required this.isRecommended,
    required this.isAvailable,
  });

  NearbyProvider toEntity() => NearbyProvider(
        id: id,
        name: name,
        category: category,
        rating: rating,
        distanceKm: distanceKm,
        isRecommended: isRecommended,
        isAvailable: isAvailable,
      );
}
