import '../../../../core/network/api_result.dart';
import '../entities/auth_entities.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<ApiResult<RegisterInitEntity>> registerInit({
    required String phone,
    required String email,
    required String password,
    required String fullName,
  });
  Future<ApiResult<RegisterInitEntity>> resendOtp({required String phone});
  Future<ApiResult<UserEntity>> verifyOtp({
    required String phone,
    required String otp,
  });
  Future<ApiResult<UserEntity>> selectRole({required String role});
  Future<ApiResult<UserEntity>> login({
    required String phone,
    required String password,
  });
  Future<ApiResult<UserEntity>> refresh({required String refreshToken});
  Future<void> logout();
  Future<ApiResult<RegisterInitEntity>> forgotPasswordInit({
    required String phone,
  });
  Future<ApiResult<void>> forgotPasswordReset({
    required String phone,
    required String otp,
    required String newPassword,
  });
  Future<ApiResult<UserEntity>> getCurrentUser();
}
