import '../../domain/entities/quotation_entities.dart';
import '../models/quotation_model.dart';
import '../stores/quotation_runtime_store.dart';

abstract interface class QuotationDataSource {
  Future<QuotationModel> create(QuotationDraft draft);
  Future<QuotationModel> get({required String requestId, required String providerId});
  Future<QuotationModel> accept({required String requestId, required String providerId});
  Future<QuotationModel> decline({required String requestId, required String providerId});
  Future<QuotationModel> requestNegotiation({required String requestId, required String providerId, required double proposedTotal, required String note});
  Future<QuotationModel> respondToNegotiation({required String requestId, required String providerId, required bool acceptProposal, required double? counterTotal, required String note});
}

class QuotationLocalDataSource implements QuotationDataSource {
  final QuotationRuntimeStore _store;

  const QuotationLocalDataSource(this._store);

  @override
  Future<QuotationModel> create(QuotationDraft draft) async {
    await Future<void>.delayed(const Duration(milliseconds: 550));
    return QuotationModel.fromEntity(_store.create(draft));
  }

  @override
  Future<QuotationModel> get({required String requestId, required String providerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 260));
    return QuotationModel.fromEntity(_store.get(requestId: requestId, providerId: providerId));
  }

  @override
  Future<QuotationModel> accept({required String requestId, required String providerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return QuotationModel.fromEntity(_store.accept(requestId: requestId, providerId: providerId));
  }

  @override
  Future<QuotationModel> decline({required String requestId, required String providerId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return QuotationModel.fromEntity(_store.decline(requestId: requestId, providerId: providerId));
  }

  @override
  Future<QuotationModel> requestNegotiation({required String requestId, required String providerId, required double proposedTotal, required String note}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return QuotationModel.fromEntity(_store.requestNegotiation(requestId: requestId, providerId: providerId, proposedTotal: proposedTotal, note: note));
  }

  @override
  Future<QuotationModel> respondToNegotiation({required String requestId, required String providerId, required bool acceptProposal, required double? counterTotal, required String note}) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    return QuotationModel.fromEntity(_store.respondToNegotiation(requestId: requestId, providerId: providerId, acceptProposal: acceptProposal, counterTotal: counterTotal, note: note));
  }
}
