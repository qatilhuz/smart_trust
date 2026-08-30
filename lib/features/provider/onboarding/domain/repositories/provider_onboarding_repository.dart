import '../../../../../core/network/api_result.dart';
import '../entities/provider_onboarding_entities.dart';

abstract class ProviderOnboardingRepository {
  Future<ApiResult<void>> submitProfile({
    required String fullName,
    required int categoryId,
    required int experienceYears,
    required List<String> skills,
    required String bio,
    required String address,
    required String city,
  });

  Future<ApiResult<ProviderVerificationEntity>> uploadDocuments({
    required String selfiePath,
    required String cnicFrontPath,
    required String cnicBackPath,
  });

  Future<ApiResult<ProviderVerificationEntity>> fetchDocumentsStatus();
}
