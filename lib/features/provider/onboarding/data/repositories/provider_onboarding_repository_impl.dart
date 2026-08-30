import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/dio_client.dart';
import '../../domain/entities/provider_onboarding_entities.dart';
import '../../domain/repositories/provider_onboarding_repository.dart';
import '../datasources/provider_onboarding_datasource.dart';

final providerOnboardingRepositoryProvider = Provider<ProviderOnboardingRepository>(
  (ref) => ProviderOnboardingRepositoryImpl(
    ProviderOnboardingDataSourceImpl(ref.watch(dioProvider)),
  ),
);

class ProviderOnboardingRepositoryImpl implements ProviderOnboardingRepository {
  final ProviderOnboardingDataSource _source;

  const ProviderOnboardingRepositoryImpl(this._source);

  @override
  Future<ApiResult<void>> submitProfile({
    required String fullName,
    required int categoryId,
    required int experienceYears,
    required List<String> skills,
    required String bio,
    required String address,
    required String city,
  }) =>
      _source.submitProfile(
        fullName: fullName,
        categoryId: categoryId,
        experienceYears: experienceYears,
        skills: skills,
        bio: bio,
        address: address,
        city: city,
      );

  @override
  Future<ApiResult<ProviderVerificationEntity>> uploadDocuments({
    required String selfiePath,
    required String cnicFrontPath,
    required String cnicBackPath,
  }) =>
      _source.uploadDocuments(
        selfiePath: selfiePath,
        cnicFrontPath: cnicFrontPath,
        cnicBackPath: cnicBackPath,
      );

  @override
  Future<ApiResult<ProviderVerificationEntity>> fetchDocumentsStatus() =>
      _source.fetchDocumentsStatus();
}
