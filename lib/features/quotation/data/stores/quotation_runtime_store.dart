import '../../../customer/job_request/data/stores/customer_request_runtime_store.dart';
import '../../../customer/job_request/domain/entities/job_request_entities.dart';
import '../../domain/entities/quotation_entities.dart';

class QuotationRuntimeStore {
  QuotationRuntimeStore._(this._requestStore);

  static final QuotationRuntimeStore instance = QuotationRuntimeStore._(CustomerRequestRuntimeStore.instance);
  final CustomerRequestRuntimeStore _requestStore;
  final Map<String, Quotation> _quotations = {};

  Quotation create(QuotationDraft draft) {
    _validateIdentity(draft.requestId, draft.providerId);
    final request = _requestStore.get(draft.requestId);
    if (request?.status != RequestLifecycleStatus.accepted) {
      throw const QuotationException(QuotationFailureCode.requestNotAccepted);
    }
    if (draft.laborAmount < 0 || draft.materialsAmount < 0 || draft.additionalAmount < 0) {
      throw const QuotationException(QuotationFailureCode.invalidAmount);
    }
    if (_quotations.containsKey(_key(draft.requestId, draft.providerId))) {
      throw const QuotationException(QuotationFailureCode.alreadyProcessed);
    }
    final now = DateTime.now();
    final quotation = Quotation(
      quotationId: 'local-quotation-${now.millisecondsSinceEpoch}',
      requestId: draft.requestId,
      providerId: draft.providerId,
      providerName: draft.providerName,
      providerProfession: draft.providerProfession,
      providerRating: draft.providerRating,
      providerVerified: draft.providerVerified,
      laborAmount: draft.laborAmount,
      materialsAmount: draft.materialsAmount,
      additionalAmount: draft.additionalAmount,
      estimatedDuration: draft.estimatedDuration,
      note: draft.note,
      status: QuotationStatus.submitted,
      createdAt: now,
      updatedAt: now,
      negotiation: null,
      history: [QuotationHistoryEntry(status: QuotationStatus.submitted, totalAmount: draft.totalAmount, note: draft.note, createdAt: now)],
    );
    _quotations[_key(draft.requestId, draft.providerId)] = quotation;
    return quotation;
  }

  Quotation get({required String requestId, required String providerId}) {
    _validateIdentity(requestId, providerId);
    final quotation = _quotations[_key(requestId, providerId)];
    if (quotation == null) throw const QuotationException(QuotationFailureCode.quotationNotFound);
    return quotation;
  }

  Quotation accept({required String requestId, required String providerId}) {
    final quotation = get(requestId: requestId, providerId: providerId);
    if (quotation.status != QuotationStatus.submitted && quotation.status != QuotationStatus.counterOffered) {
      throw const QuotationException(QuotationFailureCode.alreadyProcessed);
    }
    return _save(quotation, status: QuotationStatus.accepted, note: quotation.note);
  }

  Quotation decline({required String requestId, required String providerId}) {
    final quotation = get(requestId: requestId, providerId: providerId);
    if (quotation.status != QuotationStatus.submitted && quotation.status != QuotationStatus.counterOffered && quotation.status != QuotationStatus.negotiationRequested) {
      throw const QuotationException(QuotationFailureCode.alreadyProcessed);
    }
    return _save(quotation, status: QuotationStatus.declined, note: quotation.note);
  }

  Quotation requestNegotiation({required String requestId, required String providerId, required double proposedTotal, required String note}) {
    final quotation = get(requestId: requestId, providerId: providerId);
    if (proposedTotal < 0) throw const QuotationException(QuotationFailureCode.invalidAmount);
    if (quotation.status != QuotationStatus.submitted && quotation.status != QuotationStatus.counterOffered) {
      throw const QuotationException(QuotationFailureCode.alreadyProcessed);
    }
    final now = DateTime.now();
    return _save(
      quotation.copyWith(
        negotiation: NegotiationRequest(proposedTotal: proposedTotal, note: note.trim(), fromCustomer: true, createdAt: now),
        negotiatedTotal: proposedTotal,
      ),
      status: QuotationStatus.negotiationRequested,
      note: note,
    );
  }

  Quotation respondToNegotiation({required String requestId, required String providerId, required bool acceptProposal, required double? counterTotal, required String note}) {
    final quotation = get(requestId: requestId, providerId: providerId);
    if (quotation.status != QuotationStatus.negotiationRequested || quotation.negotiation == null) {
      throw const QuotationException(QuotationFailureCode.alreadyProcessed);
    }
    final total = acceptProposal ? quotation.negotiation!.proposedTotal : counterTotal;
    if (total == null || total < 0) throw const QuotationException(QuotationFailureCode.invalidAmount);
    final status = acceptProposal ? QuotationStatus.accepted : QuotationStatus.counterOffered;
    final now = DateTime.now();
    return _save(quotation.copyWith(negotiatedTotal: total, negotiation: NegotiationRequest(proposedTotal: total, note: note.trim(), fromCustomer: false, createdAt: now)), status: status, note: note);
  }

  String _key(String requestId, String providerId) => '$requestId::$providerId';

  void _validateIdentity(String requestId, String providerId) {
    if (requestId.trim().isEmpty || providerId.trim().isEmpty) throw const QuotationException(QuotationFailureCode.invalidRequest);
    final request = _requestStore.get(requestId);
    if (request == null) throw const QuotationException(QuotationFailureCode.invalidRequest);
    if (request.providerId != providerId) throw const QuotationException(QuotationFailureCode.unauthorized);
    if (request.status != RequestLifecycleStatus.accepted && request.status != RequestLifecycleStatus.serviceCompleted) {
      throw const QuotationException(QuotationFailureCode.requestNotAccepted);
    }
  }

  Quotation _save(Quotation quotation, {required QuotationStatus status, required String note}) {
    final now = DateTime.now();
    final updated = quotation.copyWith(status: status, updatedAt: now, history: [...quotation.history, QuotationHistoryEntry(status: status, totalAmount: quotation.totalAmount, note: note, createdAt: now)]);
    _quotations[_key(quotation.requestId, quotation.providerId)] = updated;
    return updated;
  }
}

extension on Quotation {
  Quotation copyWith({
    QuotationStatus? status,
    DateTime? updatedAt,
    NegotiationRequest? negotiation,
    List<QuotationHistoryEntry>? history,
    double? negotiatedTotal,
  }) {
    return Quotation(
      quotationId: quotationId,
      requestId: requestId,
      providerId: providerId,
      providerName: providerName,
      providerProfession: providerProfession,
      providerRating: providerRating,
      providerVerified: providerVerified,
      laborAmount: laborAmount,
      materialsAmount: materialsAmount,
      additionalAmount: additionalAmount,
      estimatedDuration: estimatedDuration,
      note: note,
      status: status ?? this.status,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      negotiation: negotiation ?? this.negotiation,
      history: history ?? this.history,
      negotiatedTotal: negotiatedTotal ?? this.negotiatedTotal,
    );
  }
}
