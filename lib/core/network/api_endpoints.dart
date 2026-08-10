class ApiEndpoints {
  ApiEndpoints._();

  static const login = '/auth/login';
  static const signup = '/auth/signup';
  static const currentUser = '/auth/me';
  static const customerJobRequests = '/customer/job-requests';
  static const providerJobAcceptances = '/provider/job-acceptances';
  static String jobQuotations(String jobId) => '/jobs/$jobId/quotations';
  static String jobReviews(String jobId) => '/jobs/$jobId/reviews';

  // TODO: Confirm backend contracts for additional routes.
  static const providerRegistration = '/provider/registration';
  static const providerJobFeed = '/provider/job-feed';
  static const providerEarnings = '/provider/earnings';
  static const chatMessages = '/chat/messages';
  static const notifications = '/notifications';
  static const reviews = '/reviews';
}
