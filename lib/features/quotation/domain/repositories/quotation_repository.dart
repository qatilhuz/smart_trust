import '../entities/quotation_entities.dart';

abstract interface class QuotationRepository {
  Future<Quotation> create(QuotationDraft draft);

  Future<Quotation> get({required String requestId, required String providerId});

  Future<QuotationActionResult> accept({required String requestId, required String providerId});

  Future<QuotationActionResult> decline({required String requestId, required String providerId});

  Future<QuotationActionResult> requestNegotiation({
    required String requestId,
    required String providerId,
    required double proposedTotal,
    required String note,
  });

  Future<QuotationActionResult> respondToNegotiation({
    required String requestId,
    required String providerId,
    required bool acceptProposal,
    required double? counterTotal,
    required String note,
  });
}
