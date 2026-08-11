import '../../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../domain/entities/provider_request_entities.dart';
import '../models/provider_request_models.dart';

abstract interface class ProviderRequestDataSource {
  Future<List<ProviderRequestModel>> getIncomingRequests({required String providerId});

  Future<ProviderRequestModel> getRequest({required String requestId, required String providerId});

  Future<ProviderRequestActionResult> updateRequest({
    required String requestId,
    required String providerId,
    required ProviderRequestAction action,
  });
}

class ProviderRequestLocalDataSource implements ProviderRequestDataSource {
  final CustomerRequestRuntimeStore _store;

  const ProviderRequestLocalDataSource(this._store);

  @override
  Future<List<ProviderRequestModel>> getIncomingRequests({required String providerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 480));
    return _store.all
        .where((record) => record.providerId == providerId && record.status == RequestLifecycleStatus.providerSelected)
        .map(_toModel)
        .toList(growable: false);
  }

  @override
  Future<ProviderRequestModel> getRequest({required String requestId, required String providerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    final record = _store.get(requestId);
    if (record == null) {
      throw const ProviderRequestException(ProviderRequestFailureCode.requestUnavailable);
    }
    if (record.providerId != providerId) {
      throw const ProviderRequestException(ProviderRequestFailureCode.unauthorizedProvider);
    }
    return _toModel(record);
  }

  @override
  Future<ProviderRequestActionResult> updateRequest({
    required String requestId,
    required String providerId,
    required ProviderRequestAction action,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 520));
    final record = _store.get(requestId);
    if (record == null) {
      throw const ProviderRequestException(ProviderRequestFailureCode.requestUnavailable);
    }
    if (record.providerId != providerId) {
      throw const ProviderRequestException(ProviderRequestFailureCode.unauthorizedProvider);
    }
    if (record.status != RequestLifecycleStatus.providerSelected) {
      throw const ProviderRequestException(ProviderRequestFailureCode.alreadyProcessed);
    }

    final status = action == ProviderRequestAction.accepted
        ? RequestLifecycleStatus.accepted
        : RequestLifecycleStatus.declined;
    final updated = _store.updateStatus(
      requestId: requestId,
      providerId: providerId,
      status: status,
    );
    if (!updated) {
      throw const ProviderRequestException(ProviderRequestFailureCode.alreadyProcessed);
    }
    return ProviderRequestActionResult(
      requestId: requestId,
      providerId: providerId,
      action: action,
      status: status,
    );
  }

  ProviderRequestModel _toModel(LocalCustomerRequestRecord record) {
    final provider = _providerSnapshot(record.providerId!);
    return ProviderRequestModel(
      requestId: record.requestId,
      providerId: record.providerId!,
      providerName: provider.$1,
      providerProfession: provider.$2,
      providerRating: provider.$3,
      providerVerified: provider.$4,
      categoryNameKey: record.category.nameKey,
      categoryDescriptionKey: record.category.descriptionKey,
      description: record.description,
      location: record.location.address,
      attachmentCount: record.attachmentCount,
      status: record.status,
    );
  }

  (String, String, double, bool) _providerSnapshot(String providerId) {
    switch (providerId) {
      case 'provider-sara-ahmed':
        return ('Sara Ahmed', 'Home Service Professional', 4.8, true);
      case 'provider-usman-khan':
        return ('Usman Khan', 'Maintenance Specialist', 4.7, true);
      case 'provider-ali-hussain':
      default:
        return ('Ali Hussain', 'HVAC Specialist', 4.9, true);
    }
  }
}
