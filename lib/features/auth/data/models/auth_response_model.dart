import '../../domain/entities/user_entity.dart';

/// Simple manual model used during early development to avoid build_runner.
class AuthResponseModel {
  final String accessToken;
  final String refreshToken;
  final String userId;
  final String name;
  final String email;
  final String role;

  AuthResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      accessToken: json['accessToken'] as String? ?? '',
      refreshToken: json['refreshToken'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  UserEntity toEntity() {
    return UserEntity(id: userId, name: name, email: email, role: role);
  }
}
