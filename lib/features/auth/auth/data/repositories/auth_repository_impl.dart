import 'package:flutter_riverpod/flutter_riverpod.dart';
import "package:shared_preferences/shared_preferences.dart";

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepositoryImpl(
    AuthRemoteDatasource(dio),
    ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SecureStorageService _storageService;

  AuthRepositoryImpl(this._remoteDatasource, this._storageService);

  @override
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  }) async {
    final result = await _remoteDatasource.login(
      email: email,
      password: password,
    );
    return result.when(
      success: (model) async {
        await _saveTokens(model);
        return ApiResult.success(model.toEntity());
      },
      failure: ApiResult.failure,
    );
  }

  @override
  Future<ApiResult<UserEntity>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final result = await _remoteDatasource.signup(
      name: name,
      email: email,
      password: password,
      role: role,
    );
    return result.when(
      success: (model) async {
        await _saveTokens(model);
        return ApiResult.success(model.toEntity());
      },
      failure: ApiResult.failure,
    );
  }

  @override
  Future<ApiResult<UserEntity>> getCurrentUser() async {
    // TODO: Implement current user fetch once backend endpoint is confirmed.
    return const ApiResult.failure(
      ApiFailure.unknown('Current user endpoint not implemented.'),
    );
  }

  @override
  Future<void> logout() async {
    await _storageService.clearTokens();
  }

  Future<void> _saveTokens(AuthResponseModel model) async {
    await _storageService.saveAccessToken(model.accessToken);
    await _storageService.saveRefreshToken(model.refreshToken);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', model.role);
  }
}
