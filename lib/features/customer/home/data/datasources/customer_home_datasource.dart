import '../models/customer_home_model.dart';

abstract interface class CustomerHomeDataSource {
  Future<CustomerHomeModel> fetchHome();
}

/// Temporary local implementation for the current UI showcase.
///
/// The presentation layer only sees the domain entity through the repository
/// contract, so this can be replaced by the Spring Boot datasource
/// without changing the home screen.
class CustomerHomeLocalDataSource implements CustomerHomeDataSource {
  @override
  Future<CustomerHomeModel> fetchHome() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));

    return const CustomerHomeModel(
      activeJob: ActiveCustomerJobModel(
        requestId: 'local-request-demo',
        providerId: 'provider-ali-hussain',
        service: 'AC Repair',
        location: 'Lahore',
        providerName: 'Ali Hussain',
        status: 'Provider on the way',
        eta: '18 min',
        progress: .68,
      ),
      categories: [
        ServiceCategoryModel(id: 'hvac', name: 'HVAC', shortLabel: 'HVAC', iconCodePoint: 0xe1b0),
        ServiceCategoryModel(id: 'electrical', name: 'Electrical', shortLabel: 'Electrical', iconCodePoint: 0xe30d),
        ServiceCategoryModel(id: 'plumbing', name: 'Plumbing', shortLabel: 'Plumbing', iconCodePoint: 0xe80e),
        ServiceCategoryModel(id: 'painting', name: 'Painting', shortLabel: 'Painting', iconCodePoint: 0xe3b6),
        ServiceCategoryModel(id: 'cleaning', name: 'Cleaning', shortLabel: 'Cleaning', iconCodePoint: 0xe14f),
      ],
      nearbyProviders: [
        NearbyProviderModel(
          id: 'provider-1',
          name: 'Ali Hussain',
          category: 'HVAC',
          rating: 4.9,
          distanceKm: 2,
          isRecommended: true,
          isAvailable: true,
        ),
        NearbyProviderModel(
          id: 'provider-2',
          name: 'Sara Ahmed',
          category: 'Plumbing',
          rating: 4.8,
          distanceKm: 3,
          isRecommended: false,
          isAvailable: true,
        ),
      ],
    );
  }
}
