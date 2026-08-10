class AppStrings {
  AppStrings._();

  // Common
  static const appTitle = 'SmartTrust';
  static const loading = 'Loading...';
  static const unknownError = 'Something went wrong. Please try again.';

  // Authentication
  static const loginTitle = 'Welcome back';
  static const loginSubtitle = 'Sign in to continue to SmartTrust.';
  static const signupTitle = 'Create your account';
  static const signupSubtitle = 'Register to request trusted home services.';
  static const email = 'Email';
  static const password = 'Password';
  static const confirmPassword = 'Confirm password';
  static const loginButton = 'Login';
  static const signupButton = 'Sign up';
  static const logoutButton = 'Logout';
  static const selectRole = 'Select your role';
  static const customerRole = 'Customer';
  static const providerRole = 'Service Provider';

  // Customer flows
  static const newJobRequest = 'New service request';
  static const preferredDate = 'Preferred date';
  static const preferredTime = 'Preferred time';
  static const requestAddress = 'Address';
  static const requestDescription = 'Describe your issue';

  // Provider flows
  static const providerRegistration = 'Provider registration';
  static const uploadDocuments = 'Upload verification documents';
  static const jobFeed = 'Job feed';
  static const earnings = 'Earnings';

  // Shared
  static const chat = 'Chat';
  static const notifications = 'Notifications';
  static const reviews = 'Reviews';

  // Errors
  static const requiredField = 'This field is required.';
  static const invalidEmail = 'Enter a valid email address.';
  static const invalidPassword = 'Password must be at least 8 characters.';
  static const invalidPhone = 'Enter a valid phone number.';
  static const invalidCnic = 'Enter a valid CNIC number.';
}
