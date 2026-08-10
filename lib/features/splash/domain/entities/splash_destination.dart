/// A semantic launch decision, deliberately independent of GoRouter paths.
///
/// Route strings belong to presentation/router code, not to the domain layer.
enum SplashDestination {
  onboarding,
  login,
  customerHome,
  providerFeed,
  adminVerification,
}
