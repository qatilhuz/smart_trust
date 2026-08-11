import '../entities/quotation_entities.dart';
import '../repositories/quotation_repository.dart';

class CreateQuotation {
  final QuotationRepository _repository;
  const CreateQuotation(this._repository);
  Future<Quotation> call(QuotationDraft draft) => _repository.create(draft);
}

class GetQuotation {
  final QuotationRepository _repository;
  const GetQuotation(this._repository);
  Future<Quotation> call({required String requestId, required String providerId}) {
    return _repository.get(requestId: requestId, providerId: providerId);
  }
}

class AcceptCustomerQuotation {
  final QuotationRepository _repository;
  const AcceptCustomerQuotation(this._repository);
  Future<QuotationActionResult> call({required String requestId, required String providerId}) {
    return _repository.accept(requestId: requestId, providerId: providerId);
  }
}

class DeclineCustomerQuotation {
  final QuotationRepository _repository;
  const DeclineCustomerQuotation(this._repository);
  Future<QuotationActionResult> call({required String requestId, required String providerId}) {
    return _repository.decline(requestId: requestId, providerId: providerId);
  }
}

class RequestQuotationNegotiation {
  final QuotationRepository _repository;
  const RequestQuotationNegotiation(this._repository);
  Future<QuotationActionResult> call({required String requestId, required String providerId, required double proposedTotal, required String note}) {
    return _repository.requestNegotiation(requestId: requestId, providerId: providerId, proposedTotal: proposedTotal, note: note);
  }
}

class RespondToQuotationNegotiation {
  final QuotationRepository _repository;
  const RespondToQuotationNegotiation(this._repository);
  Future<QuotationActionResult> call({required String requestId, required String providerId, required bool acceptProposal, required double? counterTotal, required String note}) {
    return _repository.respondToNegotiation(requestId: requestId, providerId: providerId, acceptProposal: acceptProposal, counterTotal: counterTotal, note: note);
  }
}
