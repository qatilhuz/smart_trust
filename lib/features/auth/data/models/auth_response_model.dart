import '../../domain/entities/auth_entities.dart';
import '../../domain/entities/user_entity.dart';

class OtpSentResponseModel {
  final String userId;
  final String phone;
  final String? maskedEmail;
  final String message;
  final DateTime? otpExpiresAt;
  final DateTime? resendAvailableAt;

  const OtpSentResponseModel({
    required this.userId,
    required this.phone,
    this.maskedEmail,
    required this.message,
    this.otpExpiresAt,
    this.resendAvailableAt,
  });

  factory OtpSentResponseModel.fromJson(Map<String, dynamic> json) {
    return OtpSentResponseModel(
      userId: json['userId']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      maskedEmail: json['maskedEmail']?.toString(),
      message: json['message']?.toString() ?? '',
      otpExpiresAt: _date(json['otpExpiresAt']),
      resendAvailableAt: _date(json['resendAvailableAt']),
    );
  }

  OtpSentEntity toEntity() => OtpSentEntity(
        userId: userId,
        phone: phone,
        maskedEmail: maskedEmail,
        message: message,
        otpExpiresAt: otpExpiresAt,
        resendAvailableAt: resendAvailableAt,
      );
}

/// Alias retained for existing callers while the API response is named
/// OtpSentResponse by the backend.
typedef RegisterInitResponseModel = OtpSentResponseModel;

class AuthResponseModel {
  final String userId;
  final String phone;
  final String? role;
  final String status;
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final DateTime? accessExpiresAt;
  final DateTime? refreshExpiresAt;

  const AuthResponseModel({
    required this.userId,
    required this.phone,
    required this.role,
    required this.status,
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    this.accessExpiresAt,
    this.refreshExpiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      userId: json['userId']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString(),
      status: json['status']?.toString() ?? '',
      accessToken: json['accessToken']?.toString() ?? '',
      refreshToken: json['refreshToken']?.toString() ?? '',
      expiresIn: (json['expiresIn'] as num?)?.toInt() ?? 0,
      accessExpiresAt: _date(json['accessExpiresAt']),
      refreshExpiresAt: _date(json['refreshExpiresAt']),
    );
  }

  UserEntity toEntity() => UserEntity(
        id: userId,
        name: phone,
        email: phone,
        phone: phone,
        // UserEntity is an existing non-nullable UI contract. Empty means the
        // backend has not selected a role yet; the API model remains nullable.
        role: _domainRole(role),
        status: status,
      );
}

DateTime? _date(Object? value) => value == null ? null : DateTime.tryParse(value.toString());

String _domainRole(String? value) {
  switch (value) {
    case 'SERVICE_PROVIDER':
      return 'provider';
    case 'CUSTOMER':
      return 'customer';
    default:
      return '';
  }
}