enum QuotationStatus {
  submitted,
  accepted,
  negotiationRequested,
  counterOffered,
  declined,
}

class QuotationHistoryEntry {
  final QuotationStatus status;
  final double totalAmount;
  final String note;
  final DateTime createdAt;

  const QuotationHistoryEntry({
    required this.status,
    required this.totalAmount,
    required this.note,
    required this.createdAt,
  });
}

class NegotiationRequest {
  final double proposedTotal;
  final String note;
  final bool fromCustomer;
  final DateTime createdAt;

  const NegotiationRequest({
    required this.proposedTotal,
    required this.note,
    required this.fromCustomer,
    required this.createdAt,
  });
}

class Quotation {
  final String quotationId;
  final String requestId;
  final String providerId;
  final String providerName;
  final String providerProfession;
  final double providerRating;
  final bool providerVerified;
  final double laborAmount;
  final double materialsAmount;
  final double additionalAmount;
  final String estimatedDuration;
  final String note;
  final double? negotiatedTotal;
  final QuotationStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final NegotiationRequest? negotiation;
  final List<QuotationHistoryEntry> history;

  const Quotation({
    required this.quotationId,
    required this.requestId,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.providerRating,
    required this.providerVerified,
    required this.laborAmount,
    required this.materialsAmount,
    required this.additionalAmount,
    required this.estimatedDuration,
    required this.note,
    this.negotiatedTotal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.negotiation,
    required this.history,
  });

  double get totalAmount => negotiatedTotal ?? (laborAmount + materialsAmount + additionalAmount);
}

class QuotationDraft {
  final String requestId;
  final String providerId;
  final String providerName;
  final String providerProfession;
  final double providerRating;
  final bool providerVerified;
  final double laborAmount;
  final double materialsAmount;
  final double additionalAmount;
  final String estimatedDuration;
  final String note;

  const QuotationDraft({
    required this.requestId,
    required this.providerId,
    required this.providerName,
    required this.providerProfession,
    required this.providerRating,
    required this.providerVerified,
    required this.laborAmount,
    required this.materialsAmount,
    required this.additionalAmount,
    required this.estimatedDuration,
    required this.note,
  });

  double get totalAmount => laborAmount + materialsAmount + additionalAmount;
}

enum QuotationAction {
  accepted,
  declined,
  negotiationRequested,
  counterOffered,
}

enum QuotationFailureCode {
  invalidRequest,
  unauthorized,
  requestNotAccepted,
  quotationNotFound,
  alreadyProcessed,
  invalidAmount,
  unknown,
}

class QuotationException implements Exception {
  final QuotationFailureCode code;

  const QuotationException(this.code);
}

class QuotationActionResult {
  final Quotation quotation;
  final QuotationAction action;

  const QuotationActionResult({required this.quotation, required this.action});
}
