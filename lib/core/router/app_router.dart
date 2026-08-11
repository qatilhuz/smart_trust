import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/customer/home/presentation/customer_home_screen.dart';
import '../../features/customer/job_request/presentation/job_request_screen.dart';
import '../../features/customer/provider_matching/presentation/provider_matching_screen.dart';
import '../../features/customer/provider_matching/presentation/provider_details_screen.dart';
import '../../features/customer/job_tracking/presentation/job_tracking_screen.dart';
import '../../features/customer/quotation/presentation/customer_quotation_screen.dart';
import '../../features/customer/reviews/presentation/review_screen.dart';
import '../../features/customer/complaints/presentation/complaint_screen.dart';
import '../../features/customer/profile/presentation/profile_screen.dart';
import '../../features/customer/settings/presentation/settings_screen.dart';
import '../../features/provider/registration/presentation/provider_registration_screen.dart';
import '../../features/provider/home/presentation/provider_home_screen.dart';
import '../../features/provider/job_feed/presentation/provider_job_feed_screen.dart';
import '../../features/provider/request_acceptance/presentation/provider_request_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/domain/entities/chat_entities.dart';
import '../../features/provider/quotation/presentation/provider_quotation_screen.dart';
import '../../features/provider/service_completion/presentation/service_completion_screen.dart';
import '../../features/provider/reviews/presentation/provider_reviews_screen.dart';
import '../../features/provider/complaints/presentation/provider_complaint_screen.dart';
import '../../features/provider/earnings/presentation/earnings_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/ai_assistant/presentation/ai_assistant_screen.dart';
import '../../features/voice_assistant/presentation/voice_assistant_screen.dart';
import 'route_names.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RouteNames.languageSelection,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.roleSelection,
        builder: (context, state) => const AuthRoleSelectionScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: RouteNames.otp,
        builder: (context, state) => const OtpScreen(),
      ),
      // Customer
      GoRoute(
        path: RouteNames.customerHome,
        builder: (context, state) => const CustomerHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.customerJobRequest,
        builder: (context, state) => const JobRequestScreen(),
      ),
      GoRoute(
        path: RouteNames.customerProviderMatching,
        builder: (context, state) => ProviderMatchingScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          service: state.uri.queryParameters['service'],
          location: state.uri.queryParameters['location'],
        ),
      ),
      GoRoute(
        path: RouteNames.customerProviderSelection,
        builder: (context, state) => ProviderSelectionScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          service: state.uri.queryParameters['service'],
          location: state.uri.queryParameters['location'],
        ),
      ),
      GoRoute(
        path: RouteNames.customerProviderDetails,
        builder: (context, state) => ProviderDetailsScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          service: state.uri.queryParameters['service'],
          location: state.uri.queryParameters['location'],
        ),
      ),
      GoRoute(
        path: RouteNames.customerJobTracking,
        builder: (context, state) => JobTrackingScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          service: state.uri.queryParameters['service'],
          location: state.uri.queryParameters['location'],
        ),
      ),
      GoRoute(
        path: RouteNames.customerQuotations,
        builder: (context, state) => CustomerQuotationScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.customerChat,
        builder: (context, state) => ChatScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          conversationId: state.uri.queryParameters['conversationId'],
          role: ChatParticipantRole.customer,
        ),
      ),
      GoRoute(
        path: RouteNames.customerReviews,
        builder: (context, state) => CustomerReviewScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          providerName: state.uri.queryParameters['providerName'],
          service: state.uri.queryParameters['service'],
        ),
      ),
      GoRoute(
        path: RouteNames.customerComplaints,
        builder: (context, state) => ComplaintScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          providerName: state.uri.queryParameters['providerName'],
          service: state.uri.queryParameters['service'],
        ),
      ),
      GoRoute(
        path: RouteNames.customerProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.customerSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.customerNotifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      // Provider
      GoRoute(
        path: RouteNames.providerRegistration,
        builder: (context, state) => const ProviderRegistrationScreen(),
      ),
      GoRoute(
        path: RouteNames.providerVerification,
        builder: (context, state) => const ProviderHomeScreen(),
      ),
      GoRoute(
        path: RouteNames.providerFeed,
        builder: (context, state) => const ProviderJobFeedScreen(),
      ),
      GoRoute(
        path: RouteNames.providerJobFeed,
        builder: (context, state) => const ProviderJobFeedScreen(),
      ),
      GoRoute(
        path: RouteNames.providerRequestDetails,
        builder: (context, state) => ProviderRequestScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.providerChat,
        builder: (context, state) => ChatScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
          conversationId: state.uri.queryParameters['conversationId'],
          role: ChatParticipantRole.provider,
        ),
      ),
      GoRoute(
        path: RouteNames.providerQuotation,
        builder: (context, state) => ProviderQuotationScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.providerServiceCompletion,
        builder: (context, state) => ServiceCompletionScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.providerEarnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: RouteNames.providerProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.providerSettings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.providerReviews,
        builder: (context, state) => ProviderReviewsScreen(
          providerId: state.uri.queryParameters['providerId'] ?? '',
        ),
      ),
      GoRoute(
        path: RouteNames.providerComplaintDetails,
        builder: (context, state) => ProviderComplaintScreen(
          requestId: state.uri.queryParameters['requestId'] ?? '',
          providerId: state.uri.queryParameters['providerId'] ?? '',
        ),
      ),
      // Shared
      GoRoute(
        path: RouteNames.aiAssistant,
        builder: (context, state) => const AiAssistantScreen(),
      ),
      GoRoute(
        path: RouteNames.voiceAssistant,
        builder: (context, state) => const VoiceAssistantScreen(),
      ),
    ],
  );
});
