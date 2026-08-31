import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/onboarding/presentation/screens/language_selection_screen.dart';
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_init_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
import '../../features/provider/onboarding/domain/entities/provider_onboarding_entities.dart';
import '../../features/provider/onboarding/presentation/providers/provider_onboarding_providers.dart';
import '../../features/provider/onboarding/presentation/screens/provider_documents_screen.dart';
import '../../features/provider/onboarding/presentation/screens/provider_pending_review_screen.dart';
import '../../features/provider/onboarding/presentation/screens/provider_profile_form_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/domain/entities/profile_entities.dart';
import '../../features/customer/home/presentation/customer_home_screen.dart';
import '../../features/customer/guest_home/presentation/guest_home_screen.dart';
import '../../features/customer/job_request/presentation/job_request_screen.dart';
import '../../features/customer/provider_matching/presentation/provider_matching_screen.dart';
import '../../features/customer/provider_matching/presentation/provider_details_screen.dart';
import '../../features/customer/job_tracking/presentation/job_tracking_screen.dart';
import '../../features/customer/quotation/presentation/customer_quotation_screen.dart';
import '../../features/customer/reviews/presentation/review_screen.dart';
import '../../features/customer/complaints/presentation/complaint_screen.dart';
import '../../features/customer/profile/presentation/customer_profile_screen.dart';
import '../../features/provider/profile/presentation/provider_profile_screen.dart';
import '../providers/profile_status_provider.dart';
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

/// Premium fade + subtle upward slide used by the forgot-password flow
/// so screen changes never feel abrupt.
CustomTransitionPage<void> _slideFadePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 380),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, .05), end: Offset.zero)
              .animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() => notifyListeners();
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refresh = _RouterRefreshNotifier();
  ref.onDispose(refresh.dispose);
  ref.listen(authStateProvider, (_, __) => refresh.refresh());
  ref.listen(profileStatusProvider, (_, __) => refresh.refresh());

  return GoRouter(
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    refreshListenable: refresh,
    redirect: (context, state) {
      final user = ref.read(authStateProvider).valueOrNull;
      final location = state.matchedLocation;

      // Authenticated users must pick a role before anything else.
      if (user != null &&
          user.role.isEmpty &&
          location != RouteNames.roleSelection) {
        return RouteNames.roleSelection;
      }

      // ------------------------------------------------------------------
      // Provider onboarding gate — strictly role-isolated (never applied to
      // customers or guests) and null-safe (guest transitions no longer
      // crash on user.role). Sequential steps with terminal-state checks:
      // every redirect verifies the current location is not already the
      // target, so GoRouter can never oscillate into a loop.
      // ------------------------------------------------------------------
      if (user != null &&
          user.role.isNotEmpty &&
          user.role.toLowerCase().contains('provider')) {
        // Sequentially resolved upstream (profile -> documents -> status).
        final status =
            ref.read(providerVerificationStatusProvider).valueOrNull?.status;

        if (status != null) {
          switch (status) {
            case ProviderVerificationStatus.missingProfile:
              // Profile missing -> step 1 form (unless already there).
              if (location != RouteNames.providerProfileForm) {
                return RouteNames.providerProfileForm;
              }
            case ProviderVerificationStatus.missingDocuments:
              // Profile exists, documents missing -> step 2 (unless there).
              if (location != RouteNames.providerDocumentsUpload) {
                return RouteNames.providerDocumentsUpload;
              }
            case ProviderVerificationStatus.pendingReview:
              // Uploaded, pending review -> review screen (unless there).
              if (location != RouteNames.providerPendingReview) {
                return RouteNames.providerPendingReview;
              }
            case ProviderVerificationStatus.approved:
              // Approved providers never sit on onboarding screens.
              const onboardingRoutes = {
                RouteNames.providerProfileForm,
                RouteNames.providerDocumentsUpload,
                RouteNames.providerPendingReview,
              };
              if (onboardingRoutes.contains(location)) {
                return RouteNames.providerFeed;
              }
          }
          // The onboarding gate supersedes the generic profile-completion
          // redirect: providers never fall through to it (that fall-through
          // was the pending-review <-> profile oscillation).
          return null;
        }
        // Status lookup not resolved yet: never guess. Explicit post-login /
        // post-signup navigation places the user, and this gate re-applies
        // on the next navigation once the lookup completes.
        return null;
      }

      // ------------------------------------------------------------------
      // Customer profile-completion gate (customers only — providers and
      // guests are fully handled above, so customers can never be routed
      // to /provider/* screens).
      // ------------------------------------------------------------------
      final profile = ref.read(profileStatusProvider);
      if (user == null ||
          !profile.hasValue ||
          profile.value == ProfileStatus.complete) {
        return null;
      }
      const profileRoute = RouteNames.customerProfile;
      const safeLocations = {
        RouteNames.splash,
        RouteNames.onboarding,
        RouteNames.languageSelection,
        RouteNames.login,
        RouteNames.signup,
        RouteNames.otp,
        RouteNames.roleSelection,
        profileRoute,
      };
      if (safeLocations.contains(location)) return null;
      return profileRoute;
    },
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
      GoRoute(
        path: RouteNames.forgotPassword,
        pageBuilder: (context, state) =>
            _slideFadePage(state, const ForgotPasswordInitScreen()),
      ),
      GoRoute(
        path: RouteNames.resetPassword,
        pageBuilder: (context, state) =>
            _slideFadePage(state, const ResetPasswordScreen()),
      ),
      // Customer
      GoRoute(
        path: RouteNames.customerHome,
        builder: (context, state) => ref.read(authStateProvider).valueOrNull == null
            ? const GuestHomeScreen()
            : const CustomerHomeScreen(),
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
        builder: (context, state) => const CustomerProfileScreen(),
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
        path: RouteNames.providerProfileForm,
        pageBuilder: (context, state) =>
            _slideFadePage(state, const ProviderProfileFormScreen()),
      ),
      GoRoute(
        path: RouteNames.providerDocumentsUpload,
        pageBuilder: (context, state) =>
            _slideFadePage(state, const ProviderDocumentsScreen()),
      ),
      GoRoute(
        path: RouteNames.providerPendingReview,
        pageBuilder: (context, state) =>
            _slideFadePage(state, const ProviderPendingReviewScreen()),
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
        builder: (context, state) => const ProviderProfileScreen(),
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