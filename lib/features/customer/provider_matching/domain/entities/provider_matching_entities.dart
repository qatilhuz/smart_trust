class ProviderMatchRequest {
  final String requestId;
  final String service;
  final String location;
  final String summary;

  const ProviderMatchRequest({
    required this.requestId,
    required this.service,
    required this.location,
    required this.summary,
  });
}

class MatchedProvider {
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

  const MatchedProvider({
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
}

class ProviderMatchResult {
  final ProviderMatchRequest request;
  final List<MatchedProvider> providers;

  const ProviderMatchResult({required this.request, required this.providers});
}

class ProviderSelection {
  final String requestId;
  final String providerId;
  final MatchedProvider provider;
  final String? service;
  final String? location;

  const ProviderSelection({
    required this.requestId,
    required this.providerId,
    required this.provider,
    this.service,
    this.location,
  });
}
