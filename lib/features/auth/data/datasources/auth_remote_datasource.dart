import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_result.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  const AuthRemoteDatasource(this._dio);

  Future<ApiResult<OtpSentResponseModel>> registerInit({
    required String phone,
    required String email,
    required String password,
    required String fullName,
  }) => _postOtp(ApiEndpoints.registerInit, {
        'phone': phone,
        'email': email,
        'password': password,
        'fullName': fullName,
      });

  Future<ApiResult<OtpSentResponseModel>> resendOtp({required String phone}) =>
      _postOtp(ApiEndpoints.resendOtp, {'phone': phone});

  Future<ApiResult<AuthResponseModel>> verifyOtp({
    required String phone,
    required String otp,
  }) => _postAuth(ApiEndpoints.verifyOtp, {'phone': phone, 'otp': otp});

  Future<ApiResult<AuthResponseModel>> selectRole({required String role}) =>
      _postAuth(ApiEndpoints.selectRole, {'role': role});

  Future<ApiResult<AuthResponseModel>> login({
    required String phone,
    required String password,
  }) => _postAuth(ApiEndpoints.login, {
        'phone': phone,
        'password': password,
      });

  Future<ApiResult<AuthResponseModel>> refresh({required String refreshToken}) =>
      _postAuth(ApiEndpoints.refresh, {'refreshToken': refreshToken});

  Future<ApiResult<void>> logout({required String refreshToken}) async {
    try {
      // The contract returns 204 with no body.
      await _dio.post(ApiEndpoints.logout, data: {'refreshToken': refreshToken});
      return const ApiResult.success(null);
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }

  Future<ApiResult<OtpSentResponseModel>> forgotPasswordInit({
    required String phone,
  }) => _postOtp(ApiEndpoints.forgotPasswordInit, {'phone': phone});

  Future<ApiResult<void>> forgotPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(ApiEndpoints.forgotPasswordReset, data: {
        'phone': phone,
        'otp': otp,
        'newPassword': newPassword,
      });
      return const ApiResult.success(null);
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }

  Future<ApiResult<OtpSentResponseModel>> _postOtp(
    String path,
    Map<String, String> data,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResult.success(OtpSentResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ));
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }

  Future<ApiResult<AuthResponseModel>> _postAuth(
    String path,
    Map<String, String> data,
  ) async {
    try {
      final response = await _dio.post(path, data: data);
      return ApiResult.success(AuthResponseModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      ));
    } on DioException catch (error) {
      return ApiResult.failure(NetworkExceptions.getDioException(error));
    }
  }
}
