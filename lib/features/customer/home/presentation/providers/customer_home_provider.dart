import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/customer_home_repository_impl.dart';
import '../../domain/entities/customer_home_data.dart';
import '../../domain/usecases/get_customer_home.dart';

final getCustomerHomeProvider = Provider<GetCustomerHome>((ref) {
  return GetCustomerHome(ref.watch(customerHomeRepositoryProvider));
});

final customerHomeProvider = FutureProvider.autoDispose<CustomerHomeData>((ref) {
  return ref.watch(getCustomerHomeProvider).call();
});
