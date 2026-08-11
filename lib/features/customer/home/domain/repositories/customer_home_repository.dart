import '../entities/customer_home_data.dart';

abstract interface class CustomerHomeRepository {
  Future<CustomerHomeData> fetchHome();
}
