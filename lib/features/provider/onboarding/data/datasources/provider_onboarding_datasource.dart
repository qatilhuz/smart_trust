import 'package:dio/dio.dart';

import '../../../../../core/network/api_endpoints.dart';
import '../../../../../core/network/api_result.dart';
import '../../../../../core/network/network_exceptions.dart';
import '../../domain/entities/provider_onboarding_entities.dart';

/// Backend contract for the two-step provider onboarding:
/// 1) POST /api/v1/providers/profile   (JSON)
/// 2) POST /api/v1/providers/documents (multipart/form-data)
/// plus GET /api/v1/providers/documents for the login-time status check.
abstract interface class ProviderOnboardingDataSource {
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

  /// Strict sequential onboarding resolution executed at login/auth-state
  /// initialization:
  ///   Step A: GET /providers/profile — 404/missing => missingProfile (stop).
  ///   Step B: GET /providers/documents — 404/missing => missingDocuments.
  ///   Step C: verificationStatus => pendingReview / approved.
  Future<ApiResult<ProviderVerificationEntity>> resolveOnboardingStatus();

  /// GET /api/v1/categories -> [{id, name, description}].
  Future<ApiResult<List<ProviderCategory>>> fetchCategories();
}

class ProviderOnboardingDataSourceImpl implements ProviderOnboardingDataSource {
  final Dio _dio;

  const ProviderOnboardingDataSourceImpl(this._dio);

  @override
  Future<ApiResult<void>> submitProfile({
    required String fullName,
    required int categoryId,
    required int experienceYears,
    required List<String> skills,
    required String bio,
    required String address,
    required String city,
  }) async {
    try {
      await _dio.post(
        ApiEndpoints.providerProfile,
        data: {
          'fullName': fullName,
          'categoryId': categoryId,
          'experienceYears': experienceYears,
          'skills': skills,
          'bio': bio,
          'address': address,
          'city': city,
        },
      );
      return const ApiResult.success(null);
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }

  @override
  Future<ApiResult<ProviderVerificationEntity>> uploadDocuments({
    required String selfiePath,
    required String cnicFrontPath,
    required String cnicBackPath,
  }) async {
    try {
      final form = FormData.fromMap({
        'selfie': await MultipartFile.fromFile(selfiePath),
        'cnicFront': await MultipartFile.fromFile(cnicFrontPath),
        'cnicBack': await MultipartFile.fromFile(cnicBackPath),
      });
      final response = await _dio.post(ApiEndpoints.providerDocuments, data: form);
      final raw = response.data is Map
          ? (response.data as Map)['verificationStatus']?.toString()
          : null;
      return ApiResult.success(ProviderVerificationEntity.fromRaw(raw));
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }

  @override
  Future<ApiResult<ProviderVerificationEntity>> resolveOnboardingStatus() async {
    // ---- Step A: does the provider profile exist? ------------------------
    try {
      await _dio.get(ApiEndpoints.providerProfile);
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        return const ApiResult.success(
          ProviderVerificationEntity.missingProfile,
        );
      }
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    } catch (_) {
      return const ApiResult.failure(
        const ApiFailure('Profile lookup failed.'),
      );
    }

    // ---- Step B + C: documents presence, then verification status --------
    try {
      final response = await _dio.get(ApiEndpoints.providerDocuments);
      final raw = response.data is Map
          ? (response.data as Map)['verificationStatus']?.toString()
          : null;
      return ApiResult.success(ProviderVerificationEntity.fromRaw(raw));
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) {
        // Profile exists (step A passed) but documents were never uploaded.
        return const ApiResult.success(
          ProviderVerificationEntity.missingDocumentsEntity,
        );
      }
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    } catch (_) {
      return const ApiResult.failure(
        const ApiFailure('Document status lookup failed.'),
      );
    }
  }

  @override
  Future<ApiResult<List<ProviderCategory>>> fetchCategories() async {
    try {
      final response = await _dio.get(ApiEndpoints.categories);
      final data = response.data;
      final list = data is List ? data : const [];
      return ApiResult.success(
        list
            .whereType<Map>()
            .map((item) => ProviderCategory.fromJson(
                  Map<String, dynamic>.from(item),
                ))
            .toList(growable: false),
      );
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }
}
