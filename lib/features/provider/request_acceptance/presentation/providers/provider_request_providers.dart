import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/provider_request_repository_impl.dart';
import '../../domain/entities/provider_request_entities.dart';
import '../../domain/usecases/provider_request_usecases.dart';

final localProviderIdProvider = Provider<String>((ref) => 'provider-ali-hussain');

final getIncomingProviderRequestsProvider = Provider<GetIncomingProviderRequests>((ref) => GetIncomingProviderRequests(ref.watch(providerRequestRepositoryProvider)));
final getProviderRequestProvider = Provider<GetProviderRequest>((ref) => GetProviderRequest(ref.watch(providerRequestRepositoryProvider)));
final acceptProviderRequestProvider = Provider<AcceptProviderRequest>((ref) => AcceptProviderRequest(ref.watch(providerRequestRepositoryProvider)));
final declineProviderRequestProvider = Provider<DeclineProviderRequest>((ref) => DeclineProviderRequest(ref.watch(providerRequestRepositoryProvider)));
final providerIncomingRequestsProvider = FutureProvider.autoDispose.family<List<ProviderRequest>, String>((ref, providerId) => ref.watch(getIncomingProviderRequestsProvider).call(providerId: providerId));
final providerRequestDetailsProvider = FutureProvider.autoDispose.family<ProviderRequest, ({String requestId, String providerId})>((ref, query) => ref.watch(getProviderRequestProvider).call(requestId: query.requestId, providerId: query.providerId));
