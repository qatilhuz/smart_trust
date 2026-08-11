import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/customer_home_data.dart';
import '../../domain/repositories/customer_home_repository.dart';
import '../datasources/customer_home_datasource.dart';

final customerHomeRepositoryProvider = Provider<CustomerHomeRepository>((ref) {
  return CustomerHomeRepositoryImpl(CustomerHomeLocalDataSource());
});

class CustomerHomeRepositoryImpl implements CustomerHomeRepository {
  final CustomerHomeDataSource _dataSource;

  const CustomerHomeRepositoryImpl(this._dataSource);

  @override
  Future<CustomerHomeData> fetchHome() async {
    final model = await _dataSource.fetchHome();
    return model.toEntity();
  }
}
