import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ur'),
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signup.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signup;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'SmartTrust'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get unknownError;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to SmartTrust.'**
  String get loginSubtitle;

  /// No description provided for @signupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your account'**
  String get signupTitle;

  /// No description provided for @signupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register to request trusted home services.'**
  String get signupSubtitle;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select your role'**
  String get selectRole;

  /// No description provided for @customerRole.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerRole;

  /// No description provided for @providerRole.
  ///
  /// In en, this message translates to:
  /// **'Service Provider'**
  String get providerRole;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required.'**
  String get requiredField;

  /// No description provided for @invalidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get invalidEmail;

  /// No description provided for @invalidPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 8 characters.'**
  String get invalidPassword;

  /// No description provided for @invalidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number.'**
  String get invalidPhone;

  /// No description provided for @invalidCnic.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid CNIC number.'**
  String get invalidCnic;

  /// No description provided for @verification.
  ///
  /// In en, this message translates to:
  /// **'Verification'**
  String get verification;

  /// No description provided for @enterOtp.
  ///
  /// In en, this message translates to:
  /// **'Enter OTP'**
  String get enterOtp;

  /// No description provided for @otpSent.
  ///
  /// In en, this message translates to:
  /// **'We sent a code to your email.'**
  String get otpSent;

  /// No description provided for @verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get verify;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Try again.'**
  String get invalidCode;

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @selectRoleShort.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get selectRoleShort;

  /// No description provided for @onboardingSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Your Language'**
  String get onboardingSelectLanguage;

  /// No description provided for @onboardingChooseRole.
  ///
  /// In en, this message translates to:
  /// **'Choose Your Role'**
  String get onboardingChooseRole;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageUrdu.
  ///
  /// In en, this message translates to:
  /// **'Urdu'**
  String get languageUrdu;

  /// No description provided for @customerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Find trusted professionals near you.'**
  String get customerRoleDescription;

  /// No description provided for @providerRoleDescription.
  ///
  /// In en, this message translates to:
  /// **'Grow your work and get discovered.'**
  String get providerRoleDescription;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello'**
  String get hello;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'What do you need today?'**
  String get greeting;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @nearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'Nearby Providers'**
  String get nearbyProviders;

  /// No description provided for @errorLoadingProviders.
  ///
  /// In en, this message translates to:
  /// **'Error loading providers'**
  String get errorLoadingProviders;

  /// No description provided for @aiAssistant.
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// No description provided for @voiceAssistant.
  ///
  /// In en, this message translates to:
  /// **'Voice'**
  String get voiceAssistant;

  /// No description provided for @newRequest.
  ///
  /// In en, this message translates to:
  /// **'New Request'**
  String get newRequest;

  /// No description provided for @request.
  ///
  /// In en, this message translates to:
  /// **'Request'**
  String get request;

  /// No description provided for @activeJob.
  ///
  /// In en, this message translates to:
  /// **'Active Job'**
  String get activeJob;

  /// No description provided for @providerOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Provider on the way'**
  String get providerOnTheWay;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get minutesShort;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @messageHint.
  ///
  /// In en, this message translates to:
  /// **'Message...'**
  String get messageHint;

  /// No description provided for @complaints.
  ///
  /// In en, this message translates to:
  /// **'Complaints'**
  String get complaints;

  /// No description provided for @noComplaints.
  ///
  /// In en, this message translates to:
  /// **'No complaints filed.'**
  String get noComplaints;

  /// No description provided for @fileComplaint.
  ///
  /// In en, this message translates to:
  /// **'File Complaint'**
  String get fileComplaint;

  /// No description provided for @complaintSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted'**
  String get complaintSubmitted;

  /// No description provided for @customerDashboard.
  ///
  /// In en, this message translates to:
  /// **'Customer Dashboard'**
  String get customerDashboard;

  /// No description provided for @dashboardPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Customer dashboard content placeholder'**
  String get dashboardPlaceholder;

  /// No description provided for @jobAccepted.
  ///
  /// In en, this message translates to:
  /// **'Job Accepted'**
  String get jobAccepted;

  /// No description provided for @quotationReceived.
  ///
  /// In en, this message translates to:
  /// **'Quotation Received'**
  String get quotationReceived;

  /// No description provided for @providerArrived.
  ///
  /// In en, this message translates to:
  /// **'Provider Arrived'**
  String get providerArrived;

  /// No description provided for @otpVerification.
  ///
  /// In en, this message translates to:
  /// **'OTP Verification'**
  String get otpVerification;

  /// No description provided for @uploadImage.
  ///
  /// In en, this message translates to:
  /// **'Upload Image'**
  String get uploadImage;

  /// No description provided for @createRequest.
  ///
  /// In en, this message translates to:
  /// **'Create Request'**
  String get createRequest;

  /// No description provided for @listening.
  ///
  /// In en, this message translates to:
  /// **'Listening...'**
  String get listening;

  /// No description provided for @tapToSpeak.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get tapToSpeak;

  /// No description provided for @speak.
  ///
  /// In en, this message translates to:
  /// **'Speak'**
  String get speak;

  /// No description provided for @voicePrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap to speak'**
  String get voicePrompt;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @tapToSwitch.
  ///
  /// In en, this message translates to:
  /// **'Tap to switch'**
  String get tapToSwitch;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @providerStatus.
  ///
  /// In en, this message translates to:
  /// **'Provider Status'**
  String get providerStatus;

  /// No description provided for @verificationStatus.
  ///
  /// In en, this message translates to:
  /// **'Verification Status'**
  String get verificationStatus;

  /// No description provided for @profileSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Profile Submitted'**
  String get profileSubmitted;

  /// No description provided for @cnicUploaded.
  ///
  /// In en, this message translates to:
  /// **'CNIC Uploaded'**
  String get cnicUploaded;

  /// No description provided for @tasdeeqVerification.
  ///
  /// In en, this message translates to:
  /// **'Tasdeeq Verification'**
  String get tasdeeqVerification;

  /// No description provided for @adminReview.
  ///
  /// In en, this message translates to:
  /// **'Admin Review'**
  String get adminReview;

  /// No description provided for @profileActive.
  ///
  /// In en, this message translates to:
  /// **'Profile Active'**
  String get profileActive;

  /// No description provided for @completeRegistration.
  ///
  /// In en, this message translates to:
  /// **'Complete Registration'**
  String get completeRegistration;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @todaysEarnings.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Earnings'**
  String get todaysEarnings;

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get totalEarnings;

  /// No description provided for @recentJobs.
  ///
  /// In en, this message translates to:
  /// **'Recent Jobs'**
  String get recentJobs;

  /// No description provided for @incomingRequests.
  ///
  /// In en, this message translates to:
  /// **'Incoming Requests'**
  String get incomingRequests;

  /// No description provided for @feed.
  ///
  /// In en, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @customerRequest.
  ///
  /// In en, this message translates to:
  /// **'Customer Request #{number}'**
  String customerRequest(int number);

  /// No description provided for @serviceCategoryHvac.
  ///
  /// In en, this message translates to:
  /// **'HVAC'**
  String get serviceCategoryHvac;

  /// No description provided for @acNotCooling.
  ///
  /// In en, this message translates to:
  /// **'AC not cooling. Water leaking from indoor unit.'**
  String get acNotCooling;

  /// No description provided for @distanceLocation.
  ///
  /// In en, this message translates to:
  /// **'{distance} • {location}'**
  String distanceLocation(String distance, String location);

  /// No description provided for @visitingCharge.
  ///
  /// In en, this message translates to:
  /// **'Visiting Charge (PKR)'**
  String get visitingCharge;

  /// No description provided for @requestAccepted.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get requestAccepted;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @createQuotation.
  ///
  /// In en, this message translates to:
  /// **'Create quotation'**
  String get createQuotation;

  /// No description provided for @diagnosis.
  ///
  /// In en, this message translates to:
  /// **'Diagnosis / Problem Found'**
  String get diagnosis;

  /// No description provided for @labourCharge.
  ///
  /// In en, this message translates to:
  /// **'Labour Charge'**
  String get labourCharge;

  /// No description provided for @partsCost.
  ///
  /// In en, this message translates to:
  /// **'Parts Cost'**
  String get partsCost;

  /// No description provided for @totalEstimatedCost.
  ///
  /// In en, this message translates to:
  /// **'Total Estimated Cost'**
  String get totalEstimatedCost;

  /// No description provided for @quotationSent.
  ///
  /// In en, this message translates to:
  /// **'Quotation sent'**
  String get quotationSent;

  /// No description provided for @sendQuotation.
  ///
  /// In en, this message translates to:
  /// **'Send Quotation'**
  String get sendQuotation;

  /// No description provided for @providerRegistration.
  ///
  /// In en, this message translates to:
  /// **'Provider Registration'**
  String get providerRegistration;

  /// No description provided for @submitForReview.
  ///
  /// In en, this message translates to:
  /// **'Submit for Review'**
  String get submitForReview;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Info'**
  String get basicInfo;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Info'**
  String get personalInfo;

  /// No description provided for @phoneCnic.
  ///
  /// In en, this message translates to:
  /// **'Phone / CNIC'**
  String get phoneCnic;

  /// No description provided for @uploadCnicFront.
  ///
  /// In en, this message translates to:
  /// **'Upload CNIC Front Image'**
  String get uploadCnicFront;

  /// No description provided for @uploadCnicBack.
  ///
  /// In en, this message translates to:
  /// **'Upload CNIC Back Image'**
  String get uploadCnicBack;

  /// No description provided for @skillsAreas.
  ///
  /// In en, this message translates to:
  /// **'Skills & Areas'**
  String get skillsAreas;

  /// No description provided for @primarySkill.
  ///
  /// In en, this message translates to:
  /// **'Primary Skill'**
  String get primarySkill;

  /// No description provided for @verifiedStatus.
  ///
  /// In en, this message translates to:
  /// **'VERIFIED'**
  String get verifiedStatus;

  /// No description provided for @hyperlocalStatus.
  ///
  /// In en, this message translates to:
  /// **'HYPERLOCAL'**
  String get hyperlocalStatus;

  /// No description provided for @reliableStatus.
  ///
  /// In en, this message translates to:
  /// **'RELIABLE'**
  String get reliableStatus;

  /// No description provided for @splashPreparing.
  ///
  /// In en, this message translates to:
  /// **'Preparing your trusted home network'**
  String get splashPreparing;

  /// No description provided for @splashBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'Trusted services. Connected locally.'**
  String get splashBrandTagline;

  /// No description provided for @reviews.
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// No description provided for @requestAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get requestAddress;

  /// No description provided for @preferredDate.
  ///
  /// In en, this message translates to:
  /// **'Preferred date'**
  String get preferredDate;

  /// No description provided for @preferredTime.
  ///
  /// In en, this message translates to:
  /// **'Preferred time'**
  String get preferredTime;

  /// No description provided for @requestDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe your issue'**
  String get requestDescription;

  /// No description provided for @newJobRequest.
  ///
  /// In en, this message translates to:
  /// **'New service request'**
  String get newJobRequest;

  /// No description provided for @uploadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload verification documents'**
  String get uploadDocuments;

  /// No description provided for @jobFeed.
  ///
  /// In en, this message translates to:
  /// **'Job feed'**
  String get jobFeed;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available.'**
  String get noData;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @verifiedProfessionals.
  ///
  /// In en, this message translates to:
  /// **'Verified Professionals'**
  String get verifiedProfessionals;

  /// No description provided for @introDescription.
  ///
  /// In en, this message translates to:
  /// **'SmartTrust connects you with verified service providers. Request, compare, and track with confidence.'**
  String get introDescription;

  /// No description provided for @trusted.
  ///
  /// In en, this message translates to:
  /// **'Trusted'**
  String get trusted;

  /// No description provided for @nearby.
  ///
  /// In en, this message translates to:
  /// **'Nearby'**
  String get nearby;

  /// No description provided for @transparent.
  ///
  /// In en, this message translates to:
  /// **'Transparent'**
  String get transparent;

  /// No description provided for @signUpPrompt.
  ///
  /// In en, this message translates to:
  /// **'New to SmartTrust?'**
  String get signUpPrompt;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @chooseAccountRole.
  ///
  /// In en, this message translates to:
  /// **'Choose how you will use SmartTrust'**
  String get chooseAccountRole;

  /// No description provided for @signupRoleLabel.
  ///
  /// In en, this message translates to:
  /// **'Creating account as'**
  String get signupRoleLabel;

  /// No description provided for @changeRole.
  ///
  /// In en, this message translates to:
  /// **'Change role'**
  String get changeRole;

  /// No description provided for @otpSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your email.'**
  String get otpSubtitle;

  /// No description provided for @otpRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter the verification code.'**
  String get otpRequired;

  /// No description provided for @resendIn.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendIn(int seconds);

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'We could not sign you in. Please try again.'**
  String get loginError;

  /// No description provided for @signupError.
  ///
  /// In en, this message translates to:
  /// **'We could not create your account. Please try again.'**
  String get signupError;

  /// No description provided for @verificationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Verification successful'**
  String get verificationSuccess;

  /// No description provided for @helloUser.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloUser(String name);

  /// No description provided for @activeJobSummary.
  ///
  /// In en, this message translates to:
  /// **'{service} · {location} · {eta}'**
  String activeJobSummary(String service, String location, String eta);

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get viewDetails;

  /// No description provided for @noActiveJob.
  ///
  /// In en, this message translates to:
  /// **'No active service request'**
  String get noActiveJob;

  /// No description provided for @startRequest.
  ///
  /// In en, this message translates to:
  /// **'When you need help, your next trusted service starts here.'**
  String get startRequest;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'We could not load your home data. Please try again.'**
  String get homeLoadError;

  /// No description provided for @noNearbyProviders.
  ///
  /// In en, this message translates to:
  /// **'No nearby providers are available right now.'**
  String get noNearbyProviders;

  /// No description provided for @recommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get recommended;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @customerOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'This area is available for customer accounts.'**
  String get customerOnlyMessage;

  /// No description provided for @distanceKm.
  ///
  /// In en, this message translates to:
  /// **'{distance} km'**
  String distanceKm(String distance);

  /// No description provided for @availableNow.
  ///
  /// In en, this message translates to:
  /// **'Available now'**
  String get availableNow;

  /// No description provided for @selectServiceCategory.
  ///
  /// In en, this message translates to:
  /// **'What do you need help with?'**
  String get selectServiceCategory;

  /// No description provided for @categoryHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose a service so we can understand your request.'**
  String get categoryHelper;

  /// No description provided for @describeProblem.
  ///
  /// In en, this message translates to:
  /// **'Tell us about the problem'**
  String get describeProblem;

  /// No description provided for @problemHelper.
  ///
  /// In en, this message translates to:
  /// **'A few details help the right professional prepare.'**
  String get problemHelper;

  /// No description provided for @problemHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what needs attention...'**
  String get problemHint;

  /// No description provided for @characters.
  ///
  /// In en, this message translates to:
  /// **'{count}/{max} characters'**
  String characters(int count, int max);

  /// No description provided for @addImages.
  ///
  /// In en, this message translates to:
  /// **'Add photos'**
  String get addImages;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addImage;

  /// No description provided for @removeImage.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removeImage;

  /// No description provided for @imagesOptional.
  ///
  /// In en, this message translates to:
  /// **'Optional · Up to {count} photos'**
  String imagesOptional(int count);

  /// No description provided for @location.
  ///
  /// In en, this message translates to:
  /// **'Service location'**
  String get location;

  /// No description provided for @locationHelper.
  ///
  /// In en, this message translates to:
  /// **'Where should the professional come?'**
  String get locationHelper;

  /// No description provided for @useCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use current location'**
  String get useCurrentLocation;

  /// No description provided for @confirmLocation.
  ///
  /// In en, this message translates to:
  /// **'Confirm location'**
  String get confirmLocation;

  /// No description provided for @changeLocation.
  ///
  /// In en, this message translates to:
  /// **'Change location'**
  String get changeLocation;

  /// No description provided for @manualAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter address manually'**
  String get manualAddress;

  /// No description provided for @manualAddressHint.
  ///
  /// In en, this message translates to:
  /// **'Street, area, and city'**
  String get manualAddressHint;

  /// No description provided for @locationPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access was denied. You can enter the address manually.'**
  String get locationPermissionDenied;

  /// No description provided for @locationPermissionPermanentlyDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access is turned off. Enable it in Settings or enter the address manually.'**
  String get locationPermissionPermanentlyDenied;

  /// No description provided for @locationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Location is unavailable. Please try again.'**
  String get locationUnavailable;

  /// No description provided for @locationLoading.
  ///
  /// In en, this message translates to:
  /// **'Finding your location...'**
  String get locationLoading;

  /// No description provided for @reviewRequest.
  ///
  /// In en, this message translates to:
  /// **'Review your request'**
  String get reviewRequest;

  /// No description provided for @reviewHelper.
  ///
  /// In en, this message translates to:
  /// **'Everything look right? You can edit any section before submitting.'**
  String get reviewHelper;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @problem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get problem;

  /// No description provided for @attachments.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get attachments;

  /// No description provided for @noImages.
  ///
  /// In en, this message translates to:
  /// **'No photos added'**
  String get noImages;

  /// No description provided for @submitRequest.
  ///
  /// In en, this message translates to:
  /// **'Submit request'**
  String get submitRequest;

  /// No description provided for @requestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created'**
  String get requestCreated;

  /// No description provided for @requestCreatedHelper.
  ///
  /// In en, this message translates to:
  /// **'Your request is ready. Trusted providers can respond next.'**
  String get requestCreatedHelper;

  /// No description provided for @backHome.
  ///
  /// In en, this message translates to:
  /// **'Back to home'**
  String get backHome;

  /// No description provided for @viewRequest.
  ///
  /// In en, this message translates to:
  /// **'View request'**
  String get viewRequest;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a service category to continue.'**
  String get categoryRequired;

  /// No description provided for @descriptionRequired.
  ///
  /// In en, this message translates to:
  /// **'Please describe the problem.'**
  String get descriptionRequired;

  /// No description provided for @locationRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your location to continue.'**
  String get locationRequired;

  /// No description provided for @mediaLimit.
  ///
  /// In en, this message translates to:
  /// **'You can add up to {count} photos.'**
  String mediaLimit(int count);

  /// No description provided for @requestSubmitError.
  ///
  /// In en, this message translates to:
  /// **'We could not create your request. Please try again.'**
  String get requestSubmitError;

  /// No description provided for @stepService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get stepService;

  /// No description provided for @stepProblem.
  ///
  /// In en, this message translates to:
  /// **'Problem'**
  String get stepProblem;

  /// No description provided for @stepMedia.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get stepMedia;

  /// No description provided for @stepLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get stepLocation;

  /// No description provided for @stepReview.
  ///
  /// In en, this message translates to:
  /// **'Review'**
  String get stepReview;

  /// No description provided for @permissionSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get permissionSettings;

  /// No description provided for @locationConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Location confirmed'**
  String get locationConfirmed;

  /// No description provided for @categoryElectrical.
  ///
  /// In en, this message translates to:
  /// **'Electrical'**
  String get categoryElectrical;

  /// No description provided for @categoryElectricalDescription.
  ///
  /// In en, this message translates to:
  /// **'Power, wiring, and electrical repairs.'**
  String get categoryElectricalDescription;

  /// No description provided for @categoryPlumbing.
  ///
  /// In en, this message translates to:
  /// **'Plumbing'**
  String get categoryPlumbing;

  /// No description provided for @categoryPlumbingDescription.
  ///
  /// In en, this message translates to:
  /// **'Leaks, pipes, and water systems.'**
  String get categoryPlumbingDescription;

  /// No description provided for @categoryPainting.
  ///
  /// In en, this message translates to:
  /// **'Painting'**
  String get categoryPainting;

  /// No description provided for @categoryPaintingDescription.
  ///
  /// In en, this message translates to:
  /// **'Refresh rooms and surfaces.'**
  String get categoryPaintingDescription;

  /// No description provided for @categoryCleaning.
  ///
  /// In en, this message translates to:
  /// **'Cleaning'**
  String get categoryCleaning;

  /// No description provided for @categoryCleaningDescription.
  ///
  /// In en, this message translates to:
  /// **'A cleaner, more comfortable space.'**
  String get categoryCleaningDescription;

  /// No description provided for @categoryHvacDescription.
  ///
  /// In en, this message translates to:
  /// **'Climate control, cooling, and air-conditioning services.'**
  String get categoryHvacDescription;

  /// No description provided for @findProviders.
  ///
  /// In en, this message translates to:
  /// **'Find providers'**
  String get findProviders;

  /// No description provided for @findingProviders.
  ///
  /// In en, this message translates to:
  /// **'Finding trusted providers'**
  String get findingProviders;

  /// No description provided for @matchingProvidersHelper.
  ///
  /// In en, this message translates to:
  /// **'We are looking for professionals who fit this request.'**
  String get matchingProvidersHelper;

  /// No description provided for @providersFound.
  ///
  /// In en, this message translates to:
  /// **'{count} providers found'**
  String providersFound(int count);

  /// No description provided for @availableProviders.
  ///
  /// In en, this message translates to:
  /// **'Available providers'**
  String get availableProviders;

  /// No description provided for @providerSelectionHelper.
  ///
  /// In en, this message translates to:
  /// **'Choose the professional you would like to work with for this request.'**
  String get providerSelectionHelper;

  /// No description provided for @completedJobs.
  ///
  /// In en, this message translates to:
  /// **'Completed jobs'**
  String get completedJobs;

  /// No description provided for @estimatedArrival.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get estimatedArrival;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @unavailable.
  ///
  /// In en, this message translates to:
  /// **'Currently unavailable'**
  String get unavailable;

  /// No description provided for @selectProvider.
  ///
  /// In en, this message translates to:
  /// **'Select provider'**
  String get selectProvider;

  /// No description provided for @providerDetails.
  ///
  /// In en, this message translates to:
  /// **'Provider details'**
  String get providerDetails;

  /// No description provided for @confirmProvider.
  ///
  /// In en, this message translates to:
  /// **'Confirm provider'**
  String get confirmProvider;

  /// No description provided for @confirmProviderQuestion.
  ///
  /// In en, this message translates to:
  /// **'Select {name} for this request?'**
  String confirmProviderQuestion(String name);

  /// No description provided for @providerSelected.
  ///
  /// In en, this message translates to:
  /// **'Provider selected'**
  String get providerSelected;

  /// No description provided for @providerSelectedHelper.
  ///
  /// In en, this message translates to:
  /// **'{name} has been selected for your request.'**
  String providerSelectedHelper(String name);

  /// No description provided for @returnToRequest.
  ///
  /// In en, this message translates to:
  /// **'Return to request'**
  String get returnToRequest;

  /// No description provided for @noProvidersFound.
  ///
  /// In en, this message translates to:
  /// **'No providers match this request yet.'**
  String get noProvidersFound;

  /// No description provided for @matchingError.
  ///
  /// In en, this message translates to:
  /// **'We could not find providers right now. Please try again.'**
  String get matchingError;

  /// No description provided for @providerSelectionError.
  ///
  /// In en, this message translates to:
  /// **'This provider could not be selected. Please choose another provider.'**
  String get providerSelectionError;

  /// No description provided for @requestContext.
  ///
  /// In en, this message translates to:
  /// **'For this request'**
  String get requestContext;

  /// No description provided for @requestReference.
  ///
  /// In en, this message translates to:
  /// **'Request {id}'**
  String requestReference(String id);

  /// No description provided for @requestService.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get requestService;

  /// No description provided for @requestLocation.
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get requestLocation;

  /// No description provided for @requestUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This request is no longer available.'**
  String get requestUnavailable;

  /// No description provided for @providerNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'This provider is no longer available.'**
  String get providerNotAvailable;

  /// No description provided for @matchForRequest.
  ///
  /// In en, this message translates to:
  /// **'Matching for your request'**
  String get matchForRequest;

  /// No description provided for @providerBio.
  ///
  /// In en, this message translates to:
  /// **'About this provider'**
  String get providerBio;

  /// No description provided for @services.
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @ratingLabel.
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get ratingLabel;

  /// No description provided for @jobsCompletedLabel.
  ///
  /// In en, this message translates to:
  /// **'Jobs completed'**
  String get jobsCompletedLabel;

  /// No description provided for @providerSnapshot.
  ///
  /// In en, this message translates to:
  /// **'{profession} · {rating} ★'**
  String providerSnapshot(String profession, String rating);

  /// No description provided for @jobTracking.
  ///
  /// In en, this message translates to:
  /// **'Job tracking'**
  String get jobTracking;

  /// No description provided for @trackingForRequest.
  ///
  /// In en, this message translates to:
  /// **'Tracking for this request'**
  String get trackingForRequest;

  /// No description provided for @currentStatus.
  ///
  /// In en, this message translates to:
  /// **'Current status'**
  String get currentStatus;

  /// No description provided for @statusRequestCreated.
  ///
  /// In en, this message translates to:
  /// **'Request created'**
  String get statusRequestCreated;

  /// No description provided for @statusRequestCreatedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your request has been created and is ready for the next step.'**
  String get statusRequestCreatedDescription;

  /// No description provided for @statusProviderSelected.
  ///
  /// In en, this message translates to:
  /// **'Provider selected'**
  String get statusProviderSelected;

  /// No description provided for @statusProviderSelectedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your selected professional is connected to this request.'**
  String get statusProviderSelectedDescription;

  /// No description provided for @statusOnTheWay.
  ///
  /// In en, this message translates to:
  /// **'Provider on the way'**
  String get statusOnTheWay;

  /// No description provided for @statusOnTheWayDescription.
  ///
  /// In en, this message translates to:
  /// **'Your provider is preparing to reach the service location.'**
  String get statusOnTheWayDescription;

  /// No description provided for @statusArrived.
  ///
  /// In en, this message translates to:
  /// **'Provider arrived'**
  String get statusArrived;

  /// No description provided for @statusArrivedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your provider has reached the service location.'**
  String get statusArrivedDescription;

  /// No description provided for @statusInProgress.
  ///
  /// In en, this message translates to:
  /// **'Service in progress'**
  String get statusInProgress;

  /// No description provided for @statusInProgressDescription.
  ///
  /// In en, this message translates to:
  /// **'The service is currently being completed.'**
  String get statusInProgressDescription;

  /// No description provided for @statusCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service completed'**
  String get statusCompleted;

  /// No description provided for @statusCompletedDescription.
  ///
  /// In en, this message translates to:
  /// **'This service request has been completed.'**
  String get statusCompletedDescription;

  /// No description provided for @trackingProvider.
  ///
  /// In en, this message translates to:
  /// **'Selected provider'**
  String get trackingProvider;

  /// No description provided for @providerArea.
  ///
  /// In en, this message translates to:
  /// **'Service area'**
  String get providerArea;

  /// No description provided for @eta.
  ///
  /// In en, this message translates to:
  /// **'Estimated arrival'**
  String get eta;

  /// No description provided for @liveLocationNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Live location is not available in this demo.'**
  String get liveLocationNotAvailable;

  /// No description provided for @demoLocationNote.
  ///
  /// In en, this message translates to:
  /// **'Status updates are shown from the local tracking service.'**
  String get demoLocationNote;

  /// No description provided for @trackingUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Tracking is not available for this request.'**
  String get trackingUnavailable;

  /// No description provided for @trackingError.
  ///
  /// In en, this message translates to:
  /// **'We could not load tracking right now. Please try again.'**
  String get trackingError;

  /// No description provided for @requestNotFound.
  ///
  /// In en, this message translates to:
  /// **'This request could not be found.'**
  String get requestNotFound;

  /// No description provided for @providerNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'The selected provider is no longer available.'**
  String get providerNoLongerAvailable;

  /// No description provided for @refreshStatus.
  ///
  /// In en, this message translates to:
  /// **'Refresh status'**
  String get refreshStatus;

  /// No description provided for @lastUpdated.
  ///
  /// In en, this message translates to:
  /// **'Last updated'**
  String get lastUpdated;

  /// No description provided for @trackJob.
  ///
  /// In en, this message translates to:
  /// **'Track job'**
  String get trackJob;

  /// No description provided for @trackingEarlier.
  ///
  /// In en, this message translates to:
  /// **'Earlier'**
  String get trackingEarlier;

  /// No description provided for @trackingMomentAgo.
  ///
  /// In en, this message translates to:
  /// **'A moment ago'**
  String get trackingMomentAgo;

  /// No description provided for @trackingNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get trackingNow;

  /// No description provided for @trackingUpcoming.
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get trackingUpcoming;

  /// No description provided for @statusProviderAccepted.
  ///
  /// In en, this message translates to:
  /// **'Provider accepted'**
  String get statusProviderAccepted;

  /// No description provided for @statusProviderAcceptedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your selected provider has confirmed the request.'**
  String get statusProviderAcceptedDescription;

  /// No description provided for @statusProviderDeclined.
  ///
  /// In en, this message translates to:
  /// **'Provider declined'**
  String get statusProviderDeclined;

  /// No description provided for @statusProviderDeclinedDescription.
  ///
  /// In en, this message translates to:
  /// **'Your selected provider could not accept this request.'**
  String get statusProviderDeclinedDescription;

  /// No description provided for @providerRequestDetails.
  ///
  /// In en, this message translates to:
  /// **'Request details'**
  String get providerRequestDetails;

  /// No description provided for @incomingRequestHelper.
  ///
  /// In en, this message translates to:
  /// **'Review the request details before choosing an action.'**
  String get incomingRequestHelper;

  /// No description provided for @acceptRequest.
  ///
  /// In en, this message translates to:
  /// **'Accept request'**
  String get acceptRequest;

  /// No description provided for @declineRequest.
  ///
  /// In en, this message translates to:
  /// **'Decline request'**
  String get declineRequest;

  /// No description provided for @acceptRequestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept this request for {name}?'**
  String acceptRequestQuestion(String name);

  /// No description provided for @declineRequestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Decline this request?'**
  String get declineRequestQuestion;

  /// No description provided for @requestDeclined.
  ///
  /// In en, this message translates to:
  /// **'Request declined'**
  String get requestDeclined;

  /// No description provided for @requestAcceptedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Request accepted'**
  String get requestAcceptedSuccess;

  /// No description provided for @declinedRequestHelper.
  ///
  /// In en, this message translates to:
  /// **'The request was declined and remains available for a future decision.'**
  String get declinedRequestHelper;

  /// No description provided for @acceptedRequestHelper.
  ///
  /// In en, this message translates to:
  /// **'The request is now confirmed for you.'**
  String get acceptedRequestHelper;

  /// No description provided for @noIncomingRequests.
  ///
  /// In en, this message translates to:
  /// **'No incoming requests right now.'**
  String get noIncomingRequests;

  /// No description provided for @providerOnlyMessage.
  ///
  /// In en, this message translates to:
  /// **'This area is available for service provider accounts.'**
  String get providerOnlyMessage;

  /// No description provided for @requestPending.
  ///
  /// In en, this message translates to:
  /// **'Pending response'**
  String get requestPending;

  /// No description provided for @alreadyProcessed.
  ///
  /// In en, this message translates to:
  /// **'This request has already been processed.'**
  String get alreadyProcessed;

  /// No description provided for @requestActionError.
  ///
  /// In en, this message translates to:
  /// **'We could not update this request. Please try again.'**
  String get requestActionError;

  /// No description provided for @openRequest.
  ///
  /// In en, this message translates to:
  /// **'Open request'**
  String get openRequest;

  /// No description provided for @selectedForRequest.
  ///
  /// In en, this message translates to:
  /// **'Selected for this request'**
  String get selectedForRequest;

  /// No description provided for @requestAttachmentsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos attached'**
  String requestAttachmentsCount(int count);

  /// No description provided for @providerRequestStatus.
  ///
  /// In en, this message translates to:
  /// **'Request status'**
  String get providerRequestStatus;

  /// No description provided for @acceptThisRequestQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept this selected request?'**
  String get acceptThisRequestQuestion;

  /// No description provided for @viewQuotation.
  ///
  /// In en, this message translates to:
  /// **'View quotation'**
  String get viewQuotation;

  /// No description provided for @pricingBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Pricing breakdown'**
  String get pricingBreakdown;

  /// No description provided for @laborCharge.
  ///
  /// In en, this message translates to:
  /// **'Labor/service charge'**
  String get laborCharge;

  /// No description provided for @materialsCharge.
  ///
  /// In en, this message translates to:
  /// **'Materials/parts charge'**
  String get materialsCharge;

  /// No description provided for @additionalCharge.
  ///
  /// In en, this message translates to:
  /// **'Additional charges'**
  String get additionalCharge;

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total amount'**
  String get totalAmount;

  /// No description provided for @estimatedDuration.
  ///
  /// In en, this message translates to:
  /// **'Estimated duration'**
  String get estimatedDuration;

  /// No description provided for @quotationNote.
  ///
  /// In en, this message translates to:
  /// **'Quotation note'**
  String get quotationNote;

  /// No description provided for @quotationNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Add a short note for the customer...'**
  String get quotationNoteHint;

  /// No description provided for @submitQuotation.
  ///
  /// In en, this message translates to:
  /// **'Submit quotation'**
  String get submitQuotation;

  /// No description provided for @quotationSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Quotation submitted'**
  String get quotationSubmitted;

  /// No description provided for @quotationAccepted.
  ///
  /// In en, this message translates to:
  /// **'Quotation accepted'**
  String get quotationAccepted;

  /// No description provided for @quotationDeclined.
  ///
  /// In en, this message translates to:
  /// **'Quotation declined'**
  String get quotationDeclined;

  /// No description provided for @quotationStatus.
  ///
  /// In en, this message translates to:
  /// **'Quotation status'**
  String get quotationStatus;

  /// No description provided for @acceptQuotation.
  ///
  /// In en, this message translates to:
  /// **'Accept quotation'**
  String get acceptQuotation;

  /// No description provided for @declineQuotation.
  ///
  /// In en, this message translates to:
  /// **'Decline quotation'**
  String get declineQuotation;

  /// No description provided for @negotiateQuotation.
  ///
  /// In en, this message translates to:
  /// **'Negotiate'**
  String get negotiateQuotation;

  /// No description provided for @acceptQuotationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Accept this quotation?'**
  String get acceptQuotationQuestion;

  /// No description provided for @declineQuotationQuestion.
  ///
  /// In en, this message translates to:
  /// **'Decline this quotation?'**
  String get declineQuotationQuestion;

  /// No description provided for @negotiationAmount.
  ///
  /// In en, this message translates to:
  /// **'Your proposed amount'**
  String get negotiationAmount;

  /// No description provided for @negotiationNote.
  ///
  /// In en, this message translates to:
  /// **'Negotiation note'**
  String get negotiationNote;

  /// No description provided for @negotiationNoteHint.
  ///
  /// In en, this message translates to:
  /// **'Explain what you would like to adjust...'**
  String get negotiationNoteHint;

  /// No description provided for @submitNegotiation.
  ///
  /// In en, this message translates to:
  /// **'Send negotiation request'**
  String get submitNegotiation;

  /// No description provided for @negotiationReceived.
  ///
  /// In en, this message translates to:
  /// **'Negotiation request received'**
  String get negotiationReceived;

  /// No description provided for @counterOfferAmount.
  ///
  /// In en, this message translates to:
  /// **'Counter-offer amount'**
  String get counterOfferAmount;

  /// No description provided for @acceptProposal.
  ///
  /// In en, this message translates to:
  /// **'Accept proposal'**
  String get acceptProposal;

  /// No description provided for @sendCounterOffer.
  ///
  /// In en, this message translates to:
  /// **'Send counter-offer'**
  String get sendCounterOffer;

  /// No description provided for @requestNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'This request is not ready for a quotation.'**
  String get requestNotAccepted;

  /// No description provided for @quotationNotFound.
  ///
  /// In en, this message translates to:
  /// **'No quotation is available for this request yet.'**
  String get quotationNotFound;

  /// No description provided for @providerIdentity.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get providerIdentity;

  /// No description provided for @quotationHistory.
  ///
  /// In en, this message translates to:
  /// **'Quotation history'**
  String get quotationHistory;

  /// No description provided for @quotationCreated.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get quotationCreated;

  /// No description provided for @quotationUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get quotationUpdated;

  /// No description provided for @quoteAmount.
  ///
  /// In en, this message translates to:
  /// **'Quoted amount'**
  String get quoteAmount;

  /// No description provided for @invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter valid non-negative amounts.'**
  String get invalidAmount;

  /// No description provided for @durationRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an estimated service duration.'**
  String get durationRequired;

  /// No description provided for @quotationNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a quotation note.'**
  String get quotationNoteRequired;

  /// No description provided for @negotiationAmountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a proposed amount.'**
  String get negotiationAmountRequired;

  /// No description provided for @negotiationNoteRequired.
  ///
  /// In en, this message translates to:
  /// **'Add a negotiation note.'**
  String get negotiationNoteRequired;

  /// No description provided for @quotationActionError.
  ///
  /// In en, this message translates to:
  /// **'We could not update this quotation. Please try again.'**
  String get quotationActionError;

  /// No description provided for @quotationContext.
  ///
  /// In en, this message translates to:
  /// **'For this request'**
  String get quotationContext;

  /// No description provided for @statusSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get statusSubmitted;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusNegotiationRequested.
  ///
  /// In en, this message translates to:
  /// **'Negotiation requested'**
  String get statusNegotiationRequested;

  /// No description provided for @statusCounterOffered.
  ///
  /// In en, this message translates to:
  /// **'Counter-offer sent'**
  String get statusCounterOffered;

  /// No description provided for @statusDeclined.
  ///
  /// In en, this message translates to:
  /// **'Declined'**
  String get statusDeclined;

  /// No description provided for @currencyAmount.
  ///
  /// In en, this message translates to:
  /// **'{amount} PKR'**
  String currencyAmount(String amount);

  /// No description provided for @chatTitle.
  ///
  /// In en, this message translates to:
  /// **'Conversation'**
  String get chatTitle;

  /// No description provided for @chatContext.
  ///
  /// In en, this message translates to:
  /// **'Request conversation'**
  String get chatContext;

  /// No description provided for @sendMessage.
  ///
  /// In en, this message translates to:
  /// **'Send message'**
  String get sendMessage;

  /// No description provided for @emptyConversation.
  ///
  /// In en, this message translates to:
  /// **'No messages yet'**
  String get emptyConversation;

  /// No description provided for @startConversation.
  ///
  /// In en, this message translates to:
  /// **'Start the conversation with a clear update.'**
  String get startConversation;

  /// No description provided for @chatLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading conversation...'**
  String get chatLoading;

  /// No description provided for @chatError.
  ///
  /// In en, this message translates to:
  /// **'We could not load this conversation. Please try again.'**
  String get chatError;

  /// No description provided for @chatAccessDenied.
  ///
  /// In en, this message translates to:
  /// **'This conversation is not available for your account.'**
  String get chatAccessDenied;

  /// No description provided for @conversationUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This conversation is unavailable.'**
  String get conversationUnavailable;

  /// No description provided for @messageRequired.
  ///
  /// In en, this message translates to:
  /// **'Write a message first.'**
  String get messageRequired;

  /// No description provided for @messageSendError.
  ///
  /// In en, this message translates to:
  /// **'Your message could not be sent. Please try again.'**
  String get messageSendError;

  /// No description provided for @sendingMessage.
  ///
  /// In en, this message translates to:
  /// **'Sending...'**
  String get sendingMessage;

  /// No description provided for @conversationClosed.
  ///
  /// In en, this message translates to:
  /// **'This conversation is closed.'**
  String get conversationClosed;

  /// No description provided for @customerParticipant.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerParticipant;

  /// No description provided for @providerParticipant.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get providerParticipant;

  /// No description provided for @chatConnected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get chatConnected;

  /// No description provided for @chatConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get chatConnecting;

  /// No description provided for @chatReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get chatReconnecting;

  /// No description provided for @chatDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get chatDisconnected;

  /// No description provided for @chatReconnect.
  ///
  /// In en, this message translates to:
  /// **'Reconnect'**
  String get chatReconnect;

  /// No description provided for @typingIndicator.
  ///
  /// In en, this message translates to:
  /// **'{name} is typing...'**
  String typingIndicator(String name);

  /// No description provided for @markServiceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Mark service completed'**
  String get markServiceCompleted;

  /// No description provided for @markServiceCompletedQuestion.
  ///
  /// In en, this message translates to:
  /// **'Confirm that this service is complete?'**
  String get markServiceCompletedQuestion;

  /// No description provided for @serviceCompleted.
  ///
  /// In en, this message translates to:
  /// **'Service completed'**
  String get serviceCompleted;

  /// No description provided for @serviceCompletedHelper.
  ///
  /// In en, this message translates to:
  /// **'This service is now marked complete. The customer can leave a review.'**
  String get serviceCompletedHelper;

  /// No description provided for @completionUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This service cannot be completed yet.'**
  String get completionUnavailable;

  /// No description provided for @quotationNotAccepted.
  ///
  /// In en, this message translates to:
  /// **'An accepted quotation is required before completion.'**
  String get quotationNotAccepted;

  /// No description provided for @alreadyCompleted.
  ///
  /// In en, this message translates to:
  /// **'This service has already been completed.'**
  String get alreadyCompleted;

  /// No description provided for @completionError.
  ///
  /// In en, this message translates to:
  /// **'We could not mark this service complete. Please try again.'**
  String get completionError;

  /// No description provided for @reviewProvider.
  ///
  /// In en, this message translates to:
  /// **'Review provider'**
  String get reviewProvider;

  /// No description provided for @reviewProviderHelper.
  ///
  /// In en, this message translates to:
  /// **'Share your experience with this completed service.'**
  String get reviewProviderHelper;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @writeReview.
  ///
  /// In en, this message translates to:
  /// **'Write a review'**
  String get writeReview;

  /// No description provided for @optionalReview.
  ///
  /// In en, this message translates to:
  /// **'Optional review text'**
  String get optionalReview;

  /// No description provided for @reviewHint.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your experience...'**
  String get reviewHint;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @reviewSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Review submitted'**
  String get reviewSubmitted;

  /// No description provided for @reviewSubmittedHelper.
  ///
  /// In en, this message translates to:
  /// **'Thank you for sharing your experience.'**
  String get reviewSubmittedHelper;

  /// No description provided for @alreadyReviewed.
  ///
  /// In en, this message translates to:
  /// **'You have already reviewed this completed service.'**
  String get alreadyReviewed;

  /// No description provided for @reviewUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This review is not available.'**
  String get reviewUnavailable;

  /// No description provided for @reviewRequired.
  ///
  /// In en, this message translates to:
  /// **'Choose a rating before submitting.'**
  String get reviewRequired;

  /// No description provided for @reviewError.
  ///
  /// In en, this message translates to:
  /// **'We could not submit your review. Please try again.'**
  String get reviewError;

  /// No description provided for @noReviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet.'**
  String get noReviews;

  /// No description provided for @reviewHistory.
  ///
  /// In en, this message translates to:
  /// **'Review history'**
  String get reviewHistory;

  /// No description provided for @averageRating.
  ///
  /// In en, this message translates to:
  /// **'Average rating'**
  String get averageRating;

  /// No description provided for @totalReviews.
  ///
  /// In en, this message translates to:
  /// **'Total reviews'**
  String get totalReviews;

  /// No description provided for @ratingDistribution.
  ///
  /// In en, this message translates to:
  /// **'Rating distribution'**
  String get ratingDistribution;

  /// No description provided for @leaveReview.
  ///
  /// In en, this message translates to:
  /// **'Leave review'**
  String get leaveReview;

  /// No description provided for @reviewPendingCompletion.
  ///
  /// In en, this message translates to:
  /// **'Reviews become available after service completion.'**
  String get reviewPendingCompletion;

  /// No description provided for @requestCompletedContext.
  ///
  /// In en, this message translates to:
  /// **'Completed service request'**
  String get requestCompletedContext;

  /// No description provided for @providerReviews.
  ///
  /// In en, this message translates to:
  /// **'Provider reviews'**
  String get providerReviews;

  /// No description provided for @reviewForRequest.
  ///
  /// In en, this message translates to:
  /// **'Review for request'**
  String get reviewForRequest;

  /// No description provided for @reportIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportIssue;

  /// No description provided for @complaint.
  ///
  /// In en, this message translates to:
  /// **'Complaint'**
  String get complaint;

  /// No description provided for @complaintCategory.
  ///
  /// In en, this message translates to:
  /// **'Complaint category'**
  String get complaintCategory;

  /// No description provided for @serviceQuality.
  ///
  /// In en, this message translates to:
  /// **'Service quality'**
  String get serviceQuality;

  /// No description provided for @providerBehavior.
  ///
  /// In en, this message translates to:
  /// **'Provider behavior'**
  String get providerBehavior;

  /// No description provided for @pricingIssue.
  ///
  /// In en, this message translates to:
  /// **'Pricing issue'**
  String get pricingIssue;

  /// No description provided for @incompleteService.
  ///
  /// In en, this message translates to:
  /// **'Incomplete service'**
  String get incompleteService;

  /// No description provided for @damageOrLoss.
  ///
  /// In en, this message translates to:
  /// **'Damage or loss'**
  String get damageOrLoss;

  /// No description provided for @otherComplaint.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get otherComplaint;

  /// No description provided for @complaintDescription.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue'**
  String get complaintDescription;

  /// No description provided for @evidencePhotos.
  ///
  /// In en, this message translates to:
  /// **'Evidence photos'**
  String get evidencePhotos;

  /// No description provided for @addEvidence.
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get addEvidence;

  /// No description provided for @removeEvidence.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removeEvidence;

  /// No description provided for @reviewComplaint.
  ///
  /// In en, this message translates to:
  /// **'Review complaint'**
  String get reviewComplaint;

  /// No description provided for @submitComplaint.
  ///
  /// In en, this message translates to:
  /// **'Submit complaint'**
  String get submitComplaint;

  /// No description provided for @complaintSubmittedTitle.
  ///
  /// In en, this message translates to:
  /// **'Complaint submitted'**
  String get complaintSubmittedTitle;

  /// No description provided for @complaintSubmittedHelper.
  ///
  /// In en, this message translates to:
  /// **'Your complaint has been recorded for this completed service.'**
  String get complaintSubmittedHelper;

  /// No description provided for @complaintDetails.
  ///
  /// In en, this message translates to:
  /// **'Complaint details'**
  String get complaintDetails;

  /// No description provided for @complaintReference.
  ///
  /// In en, this message translates to:
  /// **'Complaint {id}'**
  String complaintReference(String id);

  /// No description provided for @complaintStatus.
  ///
  /// In en, this message translates to:
  /// **'Complaint status'**
  String get complaintStatus;

  /// No description provided for @complaintSubmittedStatus.
  ///
  /// In en, this message translates to:
  /// **'Submitted'**
  String get complaintSubmittedStatus;

  /// No description provided for @complaintUnderReview.
  ///
  /// In en, this message translates to:
  /// **'Under review'**
  String get complaintUnderReview;

  /// No description provided for @complaintResolved.
  ///
  /// In en, this message translates to:
  /// **'Resolved'**
  String get complaintResolved;

  /// No description provided for @complaintRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get complaintRejected;

  /// No description provided for @complaintUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This complaint is unavailable.'**
  String get complaintUnavailable;

  /// No description provided for @complaintAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'A complaint already exists for this request.'**
  String get complaintAlreadyExists;

  /// No description provided for @complaintRequired.
  ///
  /// In en, this message translates to:
  /// **'Describe the issue before submitting.'**
  String get complaintRequired;

  /// No description provided for @complaintError.
  ///
  /// In en, this message translates to:
  /// **'We could not submit the complaint. Please try again.'**
  String get complaintError;

  /// No description provided for @complaintAttachmentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} photos attached'**
  String complaintAttachmentCount(int count);

  /// No description provided for @complaintRequestContext.
  ///
  /// In en, this message translates to:
  /// **'Completed service request'**
  String get complaintRequestContext;

  /// No description provided for @profileCompletion.
  ///
  /// In en, this message translates to:
  /// **'Complete your profile'**
  String get profileCompletion;

  /// No description provided for @profileCompletionHelper.
  ///
  /// In en, this message translates to:
  /// **'A complete profile helps SmartTrust keep every service experience trusted.'**
  String get profileCompletionHelper;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @profilePhoto.
  ///
  /// In en, this message translates to:
  /// **'Profile photo'**
  String get profilePhoto;

  /// No description provided for @addressLine.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get addressLine;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @area.
  ///
  /// In en, this message translates to:
  /// **'Area'**
  String get area;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete profile'**
  String get saveProfile;

  /// No description provided for @profileCompleted.
  ///
  /// In en, this message translates to:
  /// **'Profile completed'**
  String get profileCompleted;

  /// No description provided for @customerProfile.
  ///
  /// In en, this message translates to:
  /// **'Customer profile'**
  String get customerProfile;

  /// No description provided for @providerProfile.
  ///
  /// In en, this message translates to:
  /// **'Provider profile'**
  String get providerProfile;

  /// No description provided for @cnicNumber.
  ///
  /// In en, this message translates to:
  /// **'CNIC number'**
  String get cnicNumber;

  /// No description provided for @cnicFront.
  ///
  /// In en, this message translates to:
  /// **'CNIC front image'**
  String get cnicFront;

  /// No description provided for @cnicBack.
  ///
  /// In en, this message translates to:
  /// **'CNIC back image'**
  String get cnicBack;

  /// No description provided for @shopLocation.
  ///
  /// In en, this message translates to:
  /// **'Shop location'**
  String get shopLocation;

  /// No description provided for @yearsExperience.
  ///
  /// In en, this message translates to:
  /// **'Years of experience'**
  String get yearsExperience;

  /// No description provided for @verificationPending.
  ///
  /// In en, this message translates to:
  /// **'Verification pending'**
  String get verificationPending;

  /// No description provided for @notSubmitted.
  ///
  /// In en, this message translates to:
  /// **'Not submitted'**
  String get notSubmitted;

  /// No description provided for @trustTier.
  ///
  /// In en, this message translates to:
  /// **'Trust tier'**
  String get trustTier;

  /// No description provided for @trustScore.
  ///
  /// In en, this message translates to:
  /// **'Trust score'**
  String get trustScore;

  /// No description provided for @profileLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading profile...'**
  String get profileLoading;

  /// No description provided for @profileError.
  ///
  /// In en, this message translates to:
  /// **'We could not load your profile. Please try again.'**
  String get profileError;

  /// No description provided for @profileRequired.
  ///
  /// In en, this message translates to:
  /// **'Complete all required fields.'**
  String get profileRequired;

  /// No description provided for @profilePhotoAdd.
  ///
  /// In en, this message translates to:
  /// **'Add profile photo'**
  String get profilePhotoAdd;

  /// No description provided for @profilePhotoChange.
  ///
  /// In en, this message translates to:
  /// **'Change profile photo'**
  String get profilePhotoChange;

  /// No description provided for @profilePhotoRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove profile photo'**
  String get profilePhotoRemove;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as guest'**
  String get continueAsGuest;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone number'**
  String get phone;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @guestTitle.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestTitle;

  /// No description provided for @customerSupport.
  ///
  /// In en, this message translates to:
  /// **'Customer Support'**
  String get customerSupport;

  /// No description provided for @termsAndConditions.
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// No description provided for @inviteFriendsEarnCash.
  ///
  /// In en, this message translates to:
  /// **'Invite Friends and Earn Cash'**
  String get inviteFriendsEarnCash;

  /// No description provided for @joinAsProfessionalFree.
  ///
  /// In en, this message translates to:
  /// **'Join as a Professional for Free'**
  String get joinAsProfessionalFree;

  /// No description provided for @loginAsProfessional.
  ///
  /// In en, this message translates to:
  /// **'Login as a Professional'**
  String get loginAsProfessional;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'App Version: {version}'**
  String appVersionLabel(String version);

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset your password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number and we'll send you a 6-digit code.'**
  String get forgotPasswordSubtitle;

  /// No description provided for @sendResetCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendResetCode;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Set a new password'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to your phone and choose a new password.'**
  String get resetPasswordSubtitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @resetPassword.
  ///
  /// In en, this message translates to:
  /// **'Reset password'**
  String get resetPassword;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset successful'**
  String get passwordResetSuccess;

  /// No description provided for @forgotPasswordError.
  ///
  /// In en, this message translates to:
  /// **'We could not find an account with that phone number. Please try again.'**
  String get forgotPasswordError;


}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
