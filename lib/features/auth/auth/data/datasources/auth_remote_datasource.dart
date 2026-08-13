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
    // Mock demo response for UI showcase; replace with real API when backend ready.
    await Future.delayed(const Duration(milliseconds: 800));
    return Success(AuthResponseModel(
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      userId: '1',
      name: 'Demo User',
      email: email,
      role: 'customer',
    ));
  }

  Future<ApiResult<AuthResponseModel>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return Success(AuthResponseModel(
      accessToken: 'demo_access_token',
      refreshToken: 'demo_refresh_token',
      userId: '2',
      name: name,
      email: email,
      role: role,
    ));
  }
}
