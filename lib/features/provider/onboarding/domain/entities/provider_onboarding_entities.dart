/// Verification domain for the Service Provider onboarding flow.
enum ProviderVerificationStatus {
  /// Backend status APPROVED — full access granted.
  approved,

  /// Any non-APPROVED backend status (e.g. PENDING_REVIEW) — the provider is
  /// held on the animated review screen and blocked from the home surfaces.
  pendingReview,

  /// The GET documents lookup found no profile/documents yet (404) — the
  /// provider must complete the profile form first.
  missingProfile,

  /// Profile submitted (step 1 done) but documents not uploaded yet — the
  /// provider must complete the document upload step. Derived in-session
  /// because the documents lookup cannot distinguish the two 404 cases.
  missingDocuments,
}

class ProviderVerificationEntity {
  final ProviderVerificationStatus status;

  /// Raw backend value (e.g. "PENDING_REVIEW"), kept for diagnostics.
  final String? rawStatus;

  const ProviderVerificationEntity({
    required this.status,
    this.rawStatus,
  });

  /// Anything other than "APPROVED" is treated as pending review, per the
  /// onboarding contract.
  static ProviderVerificationEntity fromRaw(String? raw) {
    final value = raw?.trim() ?? '';
    return ProviderVerificationEntity(
      status: value.toUpperCase() == 'APPROVED'
          ? ProviderVerificationStatus.approved
          : ProviderVerificationStatus.pendingReview,
      rawStatus: value.isEmpty ? null : value,
    );
  }

  /// Status used when the documents lookup returns 404 (no profile yet).
  static const ProviderVerificationEntity missingProfile =
      ProviderVerificationEntity(status: ProviderVerificationStatus.missingProfile);
}
