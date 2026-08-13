import '../entities/user_entity.dart';

import '../../../../core/network/api_result.dart';

abstract class AuthRepository {
  Future<ApiResult<UserEntity>> login({
    required String email,
    required String password,
  });

  Future<ApiResult<UserEntity>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  });

  Future<ApiResult<UserEntity>> getCurrentUser();
  Future<void> logout();
}
