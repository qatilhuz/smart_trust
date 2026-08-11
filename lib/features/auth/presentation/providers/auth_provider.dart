import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage_service.dart';

final authStateProvider =
    AsyncNotifierProvider<AuthStateNotifier, UserEntity?>(
  () => AuthStateNotifier(),
);

class AuthStateNotifier extends AsyncNotifier<UserEntity?> {
  late final AuthRepository _authRepository;

  @override
  Future<UserEntity?> build() async {
    _authRepository = ref.watch(authRepositoryProvider);
    try {
      final token = await ref.read(secureStorageServiceProvider).getAccessToken();
      if (token != null && token.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        final role = prefs.getString('user_role') ?? 'customer';
        return UserEntity(id: '1', name: 'Demo User', email: 'demo@smarttrust.com', role: role);
      }
    } catch (_) {}
    return null;
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();

    final result = await _authRepository.login(
      email: email,
      password: password,
    );

    state = await result.when(
      success: (user) {
        return AsyncValue<UserEntity?>.data(user);
      },
      failure: (failure) {
        return AsyncValue<UserEntity?>.error(
          failure,
          StackTrace.current,
        );
      },
    );
  }

  Future<void> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    state = const AsyncValue.loading();

    final result = await _authRepository.signup(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    state = await result.when(
      success: (user) {
        return AsyncValue<UserEntity?>.data(user);
      },
      failure: (failure) {
        return AsyncValue<UserEntity?>.error(
          failure,
          StackTrace.current,
        );
      },
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();

    state = const AsyncValue<UserEntity?>.data(null);
  }
}