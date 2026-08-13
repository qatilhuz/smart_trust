import '../../domain/entities/provider_matching_entities.dart';

class MatchedProviderModel {
  final String id;
  final String name;
  final String profession;
  final String bio;
  final double rating;
  final int completedJobs;
  final double distanceKm;
  final String estimatedArrival;
  final List<String> services;
  final bool isAvailable;
  final bool isVerified;

  const MatchedProviderModel({
    required this.id,
    required this.name,
    required this.profession,
    required this.bio,
    required this.rating,
    required this.completedJobs,
    required this.distanceKm,
    required this.estimatedArrival,
    required this.services,
    required this.isAvailable,
    required this.isVerified,
  });

  MatchedProvider toEntity() => MatchedProvider(
        id: id,
        name: name,
        profession: profession,
        bio: bio,
        rating: rating,
        completedJobs: completedJobs,
        distanceKm: distanceKm,
        estimatedArrival: estimatedArrival,
        services: List.unmodifiable(services),
        isAvailable: isAvailable,
        isVerified: isVerified,
      );
}

class ProviderMatchResultModel {
  final String requestId;
  final String service;
  final String location;
  final String summary;
  final List<MatchedProviderModel> providers;

  const ProviderMatchResultModel({
    required this.requestId,
    required this.service,
    required this.location,
    required this.summary,
    required this.providers,
  });

  ProviderMatchResult toEntity() => ProviderMatchResult(
        request: ProviderMatchRequest(
          requestId: requestId,
          service: service,
          location: location,
          summary: summary,
        ),
        providers: providers.map((provider) => provider.toEntity()).toList(growable: false),
      );
}
