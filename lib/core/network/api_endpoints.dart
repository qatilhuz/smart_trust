class ApiEndpoints {
  ApiEndpoints._();
  static const authBase='/api/v1/auth';
  static const registerInit='$authBase/register/init';
  static const verifyOtp='$authBase/verify-otp';
  static const resendOtp='$authBase/register/resend-otp';
  static const selectRole='$authBase/select-role';
  static const login='$authBase/login';
  static const refresh='$authBase/refresh';
  static const logout='$authBase/logout';
  static const forgotPasswordInit='$authBase/forgot-password/init';
  static const forgotPasswordReset='$authBase/forgot-password/reset';
  static const health='$authBase/health';
  static const currentUser='/auth/me';
  static const customerJobRequests='/customer/job-requests';
  static const providerJobAcceptances='/provider/job-acceptances';
  static String jobQuotations(String jobId)=>'/jobs/$jobId/quotations';
  static String jobReviews(String jobId)=>'/jobs/$jobId/reviews';
  static const providerRegistration='/provider/registration';
  static const providerJobFeed='/provider/job-feed';
  static const providerEarnings='/provider/earnings';
  static const chatMessages='/chat/messages';
  static const notifications='/notifications';
  static const reviews='/reviews';
}