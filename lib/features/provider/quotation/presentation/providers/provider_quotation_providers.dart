import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../quotation/data/repositories/quotation_repository_impl.dart';
import '../../../../quotation/domain/entities/quotation_entities.dart';
import '../../../../quotation/domain/usecases/quotation_usecases.dart';

final createQuotationProvider = Provider<CreateQuotation>((ref) {
  return CreateQuotation(ref.watch(quotationRepositoryProvider));
});

final providerQuotationByRequestProvider = FutureProvider.autoDispose
    .family<Quotation, ({String requestId, String providerId})>((ref, query) {
  return GetQuotation(ref.watch(quotationRepositoryProvider)).call(
        requestId: query.requestId,
        providerId: query.providerId,
      );
});

final respondToNegotiationProvider = Provider<RespondToQuotationNegotiation>((ref) {
  return RespondToQuotationNegotiation(ref.watch(quotationRepositoryProvider));
});
