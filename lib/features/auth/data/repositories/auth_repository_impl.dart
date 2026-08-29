import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/api_result.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    AuthRemoteDatasource(ref.watch(dioProvider)),
    ref.watch(secureStorageServiceProvider),
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource source;
  final SecureStorageService storage;

  const AuthRepositoryImpl(this.source, this.storage);

  Future<ApiResult<UserEntity>> _saveAuth(ApiResult<AuthResponseModel> result) async {
    return await result.when(
      success: (model) async {
        final user = model.toEntity();
        await storage.saveAccessToken(model.accessToken);
        await storage.saveRefreshToken(model.refreshToken);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_role', user.role);
        await prefs.setString('user_phone', user.phone);
        await prefs.setString('user_email', user.email);
        await prefs.setString('user_status', user.status);
        await prefs.setString('user_id', user.id);
        return ApiResult.success(user);
      },
      failure: ApiResult.failure,
    );
  }

  @override
  Future<ApiResult<RegisterInitEntity>> registerInit({
    required String phone,
    required String email,
    required String password,
    required String role,
    required String fullName,
  }) async => _otpResult(await source.registerInit(
        phone: phone,
        email: email,
        password: password,
        role: role,
        fullName: fullName,
      ));

  @override
  Future<ApiResult<RegisterInitEntity>> resendOtp({required String phone}) async =>
      _otpResult(await source.resendOtp(phone: phone));

  @override
  Future<ApiResult<UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  }) async => _saveAuth(await source.verifyOtp(phone: phone, otp: otp));

  @override
  Future<ApiResult<UserEntity>> selectRole({required String role}) async =>
      _saveAuth(await source.selectRole(role: role));

  @override
  Future<ApiResult<UserEntity>> login({
    required String phone,
    required String password,
  }) async => _saveAuth(await source.login(phone: phone, password: password));

  @override
  Future<ApiResult<UserEntity>> refresh({required String refreshToken}) async =>
      _saveAuth(await source.refresh(refreshToken: refreshToken));

  @override
  Future<void> logout() async {
    final refreshToken = await storage.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await source.logout(refreshToken: refreshToken);
    }
    await storage.clearTokens();
  }

  @override
  Future<ApiResult<RegisterInitEntity>> forgotPasswordInit({
    required String phone,
  }) async => _otpResult(await source.forgotPasswordInit(phone: phone));

  @override
  Future<ApiResult<void>> forgotPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  }) => source.forgotPasswordReset(
        phone: phone,
        otp: otp,
        newPassword: newPassword,
      );

  Future<ApiResult<RegisterInitEntity>> _otpResult(
    ApiResult<OtpSentResponseModel> result,
  ) async => await result.when(
        success: (model) => ApiResult.success(model.toEntity()),
        failure: ApiResult.failure,
      );

  @override
  Future<ApiResult<UserEntity>> getCurrentUser() async => const ApiResult.failure(
        ApiFailure.unknown('Current user endpoint is outside the Auth contract.'),
      );
}