import '../../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../../../quotation/data/stores/quotation_runtime_store.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';
import '../../domain/entities/service_completion_entities.dart';
import '../models/service_completion_model.dart';

abstract interface class ServiceCompletionDataSource {
  Future<ServiceCompletionModel> complete({required String requestId, required String providerId});
}

class ServiceCompletionLocalDataSource implements ServiceCompletionDataSource {
  final CustomerRequestRuntimeStore _requestStore;
  final QuotationRuntimeStore _quotationStore;
  const ServiceCompletionLocalDataSource(this._requestStore, this._quotationStore);

  @override
  Future<ServiceCompletionModel> complete({required String requestId, required String providerId}) async {
    final request = _requestStore.get(requestId);
    if (request == null) throw const CompletionException(CompletionFailureCode.requestUnavailable);
    if (request.providerId != providerId) throw const CompletionException(CompletionFailureCode.unauthorizedProvider);
    if (request.status == RequestLifecycleStatus.serviceCompleted) throw const CompletionException(CompletionFailureCode.alreadyCompleted);
    if (request.status != RequestLifecycleStatus.accepted) throw const CompletionException(CompletionFailureCode.requestUnavailable);
    final quotation = _getAcceptedQuotation(requestId, providerId);
    if (quotation == null) throw const CompletionException(CompletionFailureCode.quotationNotAccepted);
    await Future<void>.delayed(const Duration(milliseconds: 520));
    if (!_requestStore.completeService(requestId: requestId, providerId: providerId)) throw const CompletionException(CompletionFailureCode.alreadyCompleted);
    return ServiceCompletionModel(requestId: requestId, providerId: providerId, status: RequestLifecycleStatus.serviceCompleted, completedAt: DateTime.now());
  }

  Quotation? _getAcceptedQuotation(String requestId, String providerId) {
    try {
      final quotation = _quotationStore.get(requestId: requestId, providerId: providerId);
      return quotation.status == QuotationStatus.accepted ? quotation : null;
    } on QuotationException {
      return null;
    }
  }
}
