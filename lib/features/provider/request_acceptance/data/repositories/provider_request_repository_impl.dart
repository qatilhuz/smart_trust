import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../domain/entities/provider_request_entities.dart';
import '../../domain/repositories/provider_request_repository.dart';
import '../datasources/provider_request_datasource.dart';

final providerRequestRepositoryProvider = Provider<ProviderRequestRepository>((ref) {
  return ProviderRequestRepositoryImpl(
    ProviderRequestLocalDataSource(CustomerRequestRuntimeStore.instance),
  );
});

class ProviderRequestRepositoryImpl implements ProviderRequestRepository {
  final ProviderRequestDataSource _dataSource;

  const ProviderRequestRepositoryImpl(this._dataSource);

  @override
  Future<List<ProviderRequest>> getIncomingRequests({required String providerId}) async {
    final models = await _dataSource.getIncomingRequests(providerId: providerId);
    return models.map((model) => model.toEntity()).toList(growable: false);
  }

  @override
  Future<ProviderRequest> getRequest({required String requestId, required String providerId}) async {
    final model = await _dataSource.getRequest(requestId: requestId, providerId: providerId);
    return model.toEntity();
  }

  @override
  Future<ProviderRequestActionResult> accept({required String requestId, required String providerId}) {
    return _dataSource.updateRequest(
      requestId: requestId,
      providerId: providerId,
      action: ProviderRequestAction.accepted,
    );
  }

  @override
  Future<ProviderRequestActionResult> decline({required String requestId, required String providerId}) {
    return _dataSource.updateRequest(
      requestId: requestId,
      providerId: providerId,
      action: ProviderRequestAction.declined,
    );
  }
}
