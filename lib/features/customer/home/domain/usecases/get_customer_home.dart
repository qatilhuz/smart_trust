import '../entities/customer_home_data.dart';
import '../repositories/customer_home_repository.dart';

class GetCustomerHome {
  final CustomerHomeRepository _repository;

  const GetCustomerHome(this._repository);

  Future<CustomerHomeData> call() => _repository.fetchHome();
}
