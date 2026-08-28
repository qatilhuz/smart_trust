class OtpSentEntity {
  final String userId;
  final String phone;
  final String? maskedEmail;
  final String message;
  final DateTime? otpExpiresAt;
  final DateTime? resendAvailableAt;

  const OtpSentEntity({
    required this.userId,
    required this.phone,
    this.maskedEmail,
    required this.message,
    this.otpExpiresAt,
    this.resendAvailableAt,
  });
}

/// Backwards-compatible name used by the existing auth presentation layer.
typedef RegisterInitEntity = OtpSentEntity;

class PendingRegistration {
  final String phone;
  const PendingRegistration({required this.phone});
}
