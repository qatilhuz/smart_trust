import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../quotation/data/repositories/quotation_repository_impl.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';
import '../../../../quotation/domain/usecases/quotation_usecases.dart';

final customerQuotationProvider = FutureProvider.autoDispose
    .family<Quotation, ({String requestId, String providerId})>((ref, query) {
  return GetQuotation(ref.watch(quotationRepositoryProvider)).call(
        requestId: query.requestId,
        providerId: query.providerId,
      );
});

final acceptQuotationProvider = Provider<AcceptCustomerQuotation>((ref) {
  return AcceptCustomerQuotation(ref.watch(quotationRepositoryProvider));
});

final declineQuotationProvider = Provider<DeclineCustomerQuotation>((ref) {
  return DeclineCustomerQuotation(ref.watch(quotationRepositoryProvider));
});

final requestNegotiationProvider = Provider<RequestQuotationNegotiation>((ref) {
  return RequestQuotationNegotiation(ref.watch(quotationRepositoryProvider));
});
