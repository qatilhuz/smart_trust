# SmartTrust — Batch 3 Localization Foundation

## Existing structure verified

- `l10n.yaml` uses `lib/l10n`, `app_en.arb` as the template, generated class `AppLocalizations`, and generated file `app_localizations.dart`.
- `pubspec.yaml` enables Flutter l10n generation and includes `flutter_localizations`.
- `MaterialApp.router` already supplies `AppLocalizations.delegate`, Flutter material/widgets/cupertino delegates, and `en`/`ur` supported locales.
- `localeProvider` remains unchanged; locale switching and directionality are outside this batch.

## English source changes

The English ARB now contains **141 localization keys** covering the existing UI vocabulary across common actions, onboarding, authentication/OTP, customer screens, provider screens, chat, notifications, profile/settings, complaints, AI, voice, splash, validation, loading, and empty/error states.

Parameterized English messages were added for:

- `customerRequest(int number)`
- `distanceLocation(String distance, String location)`

No provider names, backend records, user-generated messages, prices, or other domain data were moved into l10n.

## Generated localization files

The generated interface and English implementation were updated to expose the ARB keys. The existing Urdu ARB was deliberately not populated with fake English or Urdu translations. The generated Urdu implementation temporarily delegates missing messages to the English source so the generated interface remains structurally valid; actual Urdu values are deferred to the Urdu localization batch.

## AppStrings migration

The user-facing `AppStrings` values were mapped into English ARB keys. Login and signup now consume `AppLocalizations` directly. `ErrorView` uses the localized retry label, and `AuthenticationPrompt` uses localized sign-in/login/create-account labels. `AppStrings` was retained as a compatibility shell containing only the stable non-sentence product identity; it is no longer a competing UI string source.

## Remaining work intentionally deferred

The following `isUrdu` and hardcoded bilingual screen areas were identified but not migrated in this batch, in line with the strict batch boundary:

- `features/ai_assistant/presentation/ai_assistant_screen.dart`
- `features/customer/home/presentation/customer_home_screen.dart`
- `features/customer/settings/presentation/settings_screen.dart`
- `features/onboarding/presentation/screens/onboarding_screen.dart`
- `features/onboarding/presentation/widgets/onboarding_page.dart`
- `features/voice_assistant/presentation/voice_assistant_screen.dart`

Additional hardcoded UI strings remain in customer/provider/splash/OTP screens and are covered by English ARB keys for later screen migration. This batch did not redesign screens or change layout, routing, authentication, API behavior, RTL, Urdu translation, or animation behavior.

## Validation

- Both ARB files were parsed successfully as JSON.
- English ARB keys were checked for duplicates.
- Generated interface methods were checked against both generated implementations; no missing or extra methods were found.
- Placeholder method signatures were checked for `customerRequest` and `distanceLocation`.
- Localization configuration and MaterialApp delegate wiring were inspected.
- `git diff --check` was run.
- Flutter generation/analyze could not run because the Flutter SDK is unavailable in this environment (`flutter: command not found`).
