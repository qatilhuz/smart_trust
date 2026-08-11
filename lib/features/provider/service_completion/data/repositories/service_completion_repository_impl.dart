import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../../../quotation/data/stores/quotation_runtime_store.dart';
import '../../domain/entities/service_completion_entities.dart';
import '../../domain/repositories/service_completion_repository.dart';
import '../datasources/service_completion_datasource.dart';

final serviceCompletionRepositoryProvider = Provider<ServiceCompletionRepository>((ref) {
  return ServiceCompletionRepositoryImpl(ServiceCompletionLocalDataSource(CustomerRequestRuntimeStore.instance, QuotationRuntimeStore.instance));
});

class ServiceCompletionRepositoryImpl implements ServiceCompletionRepository {
  final ServiceCompletionDataSource _dataSource;
  const ServiceCompletionRepositoryImpl(this._dataSource);
  @override
  Future<ServiceCompletion> complete({required String requestId, required String providerId}) async => (await _dataSource.complete(requestId: requestId, providerId: providerId)).toEntity();
}
