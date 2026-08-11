enum ProviderMatchingFailureCode {
  invalidRequest,
  noProviders,
  providerUnavailable,
  unknown,
}

class ProviderMatchingException implements Exception {
  final ProviderMatchingFailureCode code;

  const ProviderMatchingException(this.code);
}
