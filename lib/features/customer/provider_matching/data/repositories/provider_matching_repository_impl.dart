import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/provider_matching_entities.dart';
import '../../domain/repositories/provider_matching_repositories.dart';
import '../datasources/provider_matching_datasource.dart';

final providerMatchingRepositoryProvider = Provider<ProviderMatchingRepository>((ref) {
  return ProviderMatchingRepositoryImpl(ProviderMatchingLocalDataSource());
});

class ProviderMatchingRepositoryImpl implements ProviderMatchingRepository {
  final ProviderMatchingDataSource _dataSource;

  const ProviderMatchingRepositoryImpl(this._dataSource);

  @override
  Future<ProviderMatchResult> findProviders({required String requestId}) async {
    final model = await _dataSource.findProviders(requestId: requestId);
    return model.toEntity();
  }

  @override
  Future<ProviderSelection> selectProvider({
    required String requestId,
    required String providerId,
  }) async {
    final model = await _dataSource.selectProvider(
      requestId: requestId,
      providerId: providerId,
    );
    final provider = model.toEntity();
    return ProviderSelection(
      requestId: requestId,
      providerId: providerId,
      provider: provider,
    );
  }
}
