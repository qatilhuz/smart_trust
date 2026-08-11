import '../../domain/entities/provider_matching_entities.dart';
import '../../domain/entities/provider_matching_failures.dart';
import '../models/provider_matching_models.dart';
import '../../../job_request/data/stores/customer_request_runtime_store.dart';

abstract interface class ProviderMatchingDataSource {
  Future<ProviderMatchResultModel> findProviders({required String requestId});

  Future<MatchedProviderModel> selectProvider({
    required String requestId,
    required String providerId,
  });
}

class ProviderMatchingLocalDataSource implements ProviderMatchingDataSource {
  static const _providers = <MatchedProviderModel>[
    MatchedProviderModel(
      id: 'provider-ali-hussain',
      name: 'Ali Hussain',
      profession: 'HVAC Specialist',
      bio: 'Experienced in residential cooling and air-conditioning repairs.',
      rating: 4.9,
      completedJobs: 184,
      distanceKm: 2.0,
      estimatedArrival: '18 min',
      services: ['HVAC', 'AC repair', 'Cooling systems'],
      isAvailable: true,
      isVerified: true,
    ),
    MatchedProviderModel(
      id: 'provider-sara-ahmed',
      name: 'Sara Ahmed',
      profession: 'Home Service Professional',
      bio: 'Reliable home maintenance specialist with a careful, clean approach.',
      rating: 4.8,
      completedJobs: 126,
      distanceKm: 3.0,
      estimatedArrival: '25 min',
      services: ['Plumbing', 'Maintenance', 'Repairs'],
      isAvailable: true,
      isVerified: true,
    ),
    MatchedProviderModel(
      id: 'provider-usman-khan',
      name: 'Usman Khan',
      profession: 'Maintenance Specialist',
      bio: 'Trusted for practical home repairs and dependable service.',
      rating: 4.7,
      completedJobs: 98,
      distanceKm: 4.2,
      estimatedArrival: '32 min',
      services: ['Electrical', 'General repairs'],
      isAvailable: true,
      isVerified: true,
    ),
  ];

  @override
  Future<ProviderMatchResultModel> findProviders({required String requestId}) async {
    if (requestId.trim().isEmpty) {
      throw const ProviderMatchingException(ProviderMatchingFailureCode.invalidRequest);
    }
    await Future<void>.delayed(const Duration(milliseconds: 950));
    if (_providers.isEmpty) {
      throw const ProviderMatchingException(ProviderMatchingFailureCode.noProviders);
    }
    return ProviderMatchResultModel(
      requestId: requestId,
      service: 'Requested home service',
      location: 'Confirmed service location',
      summary: 'Professionals matched to your request',
      providers: _providers,
    );
  }

  @override
  Future<MatchedProviderModel> selectProvider({
    required String requestId,
    required String providerId,
  }) async {
    if (requestId.trim().isEmpty) {
      throw const ProviderMatchingException(ProviderMatchingFailureCode.invalidRequest);
    }
    await Future<void>.delayed(const Duration(milliseconds: 420));
    try {
      final provider = _providers.firstWhere(
        (candidate) => candidate.id == providerId && candidate.isAvailable,
      );
      final assigned = CustomerRequestRuntimeStore.instance.assignProvider(
        requestId: requestId,
        providerId: providerId,
      );
      if (!assigned) {
        throw const ProviderMatchingException(ProviderMatchingFailureCode.invalidRequest);
      }
      return provider;
    } catch (error) {
      if (error is ProviderMatchingException) rethrow;
      throw const ProviderMatchingException(ProviderMatchingFailureCode.providerUnavailable);
    }
  }
}
