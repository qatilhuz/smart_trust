import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/quotation_entities.dart';
import '../../domain/repositories/quotation_repository.dart';
import '../datasources/quotation_datasource.dart';
import '../stores/quotation_runtime_store.dart';

final quotationRepositoryProvider = Provider<QuotationRepository>((ref) {
  return QuotationRepositoryImpl(QuotationLocalDataSource(QuotationRuntimeStore.instance));
});

class QuotationRepositoryImpl implements QuotationRepository {
  final QuotationDataSource _dataSource;
  const QuotationRepositoryImpl(this._dataSource);

  @override
  Future<Quotation> create(QuotationDraft draft) async => (await _dataSource.create(draft)).toEntity();
  @override
  Future<Quotation> get({required String requestId, required String providerId}) async => (await _dataSource.get(requestId: requestId, providerId: providerId)).toEntity();
  @override
  Future<QuotationActionResult> accept({required String requestId, required String providerId}) async => QuotationActionResult(quotation: (await _dataSource.accept(requestId: requestId, providerId: providerId)).toEntity(), action: QuotationAction.accepted);
  @override
  Future<QuotationActionResult> decline({required String requestId, required String providerId}) async => QuotationActionResult(quotation: (await _dataSource.decline(requestId: requestId, providerId: providerId)).toEntity(), action: QuotationAction.declined);
  @override
  Future<QuotationActionResult> requestNegotiation({required String requestId, required String providerId, required double proposedTotal, required String note}) async => QuotationActionResult(quotation: (await _dataSource.requestNegotiation(requestId: requestId, providerId: providerId, proposedTotal: proposedTotal, note: note)).toEntity(), action: QuotationAction.negotiationRequested);
  @override
  Future<QuotationActionResult> respondToNegotiation({required String requestId, required String providerId, required bool acceptProposal, required double? counterTotal, required String note}) async => QuotationActionResult(quotation: (await _dataSource.respondToNegotiation(requestId: requestId, providerId: providerId, acceptProposal: acceptProposal, counterTotal: counterTotal, note: note)).toEntity(), action: acceptProposal ? QuotationAction.accepted : QuotationAction.counterOffered);
}
