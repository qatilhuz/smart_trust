import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
// import '../../../../core/network/network_exceptions.dart';
import '../../../../core/network/api_result.dart';
import '../models/auth_response_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;

  AuthRemoteDatasource(this._dio);

  Future<ApiResult<AuthResponseModel>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.login,
        data: {'email': email, 'password': password},
      );
      return Success(
        AuthResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (exception) {
      return Failure(NetworkExceptions.getDioException(exception));
    }
  }

  Future<ApiResult<AuthResponseModel>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.signup,
        data: {
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        },
      );
      return Success(
        AuthResponseModel.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (exception) {
      return Failure(NetworkExceptions.getDioException(exception));
    }
  }
}
