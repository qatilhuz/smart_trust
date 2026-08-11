/// Legacy compatibility shell for non-localized application identifiers.
///
/// User-facing strings belong to generated [AppLocalizations] values. This
/// class is intentionally retained so old imports fail less noisily while the
/// remaining screen migrations are completed in later batches.
class AppStrings {
  AppStrings._();

  /// Stable product identity, not a translated sentence.
  static const appName = 'SmartTrust';
}
