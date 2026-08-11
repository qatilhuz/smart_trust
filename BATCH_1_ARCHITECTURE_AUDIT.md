# SmartTrust — Batch 1 Repository Audit

**Audit scope:** repository state at `1d72fb7` / branch `arena/019ff16d-smart-trust`
**Audit date:** 2026-08-11
**Batch boundary:** audit only; no screens, UI redesign, feature implementation, or architectural refactor was performed.

## Source/document availability

The checkout contains `README.md`, `deps.txt`, `pubspec.yaml`, and platform/project configuration, but no proposal, R&D, database schema, requirements document, PDF, DOCX, or backend contract file. `README.md` is still the Flutter template README and contains no SmartTrust business requirements. Therefore requirement comparison below is limited to the requirements represented by the current repository and the requested two-role mobile scope; a definitive proposal/database comparison remains blocked until those documents are present.

## 1. Current architecture status

**Overall:** a partial Feature-First Clean Architecture scaffold exists, but most feature slices are presentation-only demos/placeholders. The intended dependency direction is visible in the auth and splash slices:

`presentation provider -> domain repository contract -> data repository -> datasource -> Dio/storage`

### Structured slices that currently exist

- **Auth:** domain entity and repository contract; data model, repository implementation, datasource; Riverpod presentation notifier and screens.
- **Splash:** domain destination entity/repository contract; local datasource and repository implementation; presentation providers, route mapper, animated screen/widgets.
- **Other features:** generally only `presentation/` screens, with no domain/data contracts.
- **Core:** router, theme, constants, networking, storage, locale provider, utilities, and generic widgets.

### Positive baseline findings

- Auth and splash do not make API calls from widgets.
- `Dio` is constructed in `core/network/dio_client.dart`; the auth datasource receives it through DI.
- Splash has a useful semantic domain destination and presentation-only route mapper.
- `MaterialApp.router`, Riverpod, GoRouter, and generated localization delegates are wired in `app.dart`.

### Significant baseline risks

- There is no centralized route guard/redirect. All GoRouter routes are public.
- There are no application use-case classes. Providers call repository methods directly; most screens/providers have no repository at all.
- `lib/core/network/api_result.dart` and `lib/core/network/network_exceptions.dart` both define `ApiResult`, `Success`, `Failure`, and failure classes. The latter is currently unused and is a duplicate abstraction.
- `LocalStorageService` has an unimplemented provider and is not wired in `main.dart`; screens call `SharedPreferences.getInstance()` directly in at least role selection.
- Auth/session storage keys are inconsistent: auth uses `SMARTTRUST_ACCESS_TOKEN` via `SecureStorageService`, while splash reads `access_token`; splash reads `onboarding_seen`, while `LocalStorageService` uses `onboardingCompleted`. This can make launch resolution disagree with login state.
- `SplashDestination.adminVerification` and `/admin/verification` are present even though Admin is explicitly not a mobile role; the route is not registered in `app_router.dart` and should be removed or converted to an invalid/unsupported state in a later safe refactor.
- No Flutter SDK is installed in this environment, so `flutter analyze` could not run (`flutter: command not found`). Static inspection was completed instead.

## 2. Feature and screen inventory

### Existing feature directories

- `splash`: animated launch experience, local launch decision.
- `onboarding`: language selection, intro/onboarding carousel, role selection.
- `auth`: login, signup, OTP, customer/provider role selector.
- `customer`: home, dashboard placeholder, job request, provider selection, job tracking, quotations, chat, reviews, complaints, profile, settings.
- `provider`: registration, home/verification placeholder, job feed, quotation, earnings.
- `notifications`: notifications screen.
- `ai_assistant`: image-assessment demo screen.
- `voice_assistant`: simulated voice command demo screen.

### Routes currently registered

Splash, onboarding, language, role, login, signup, OTP; customer home/job request/provider selection/job tracking/quotations/chat/reviews/complaints/profile/settings/notifications; provider registration/verification/feed/job-feed/quotation/earnings/profile/settings; AI and voice assistant.

`RouteNames` additionally declares unused `intro` and `unauthorized`, duplicate provider feed names (`providerFeed`, `providerJobFeed`), and an admin-verification path that is not registered.

### Providers

- `localeProvider` / `LocaleNotifier`.
- `authStateProvider` / `AuthStateNotifier`.
- `customerHomeProvider` (a `FutureProvider<List<dynamic>>` returning inline demo maps).
- Splash DI providers and `splashDestinationProvider`.
- Core Dio, secure storage, and an unimplemented local-storage provider.

No provider exists for customer jobs, providers, quotations, chat, notifications, reviews, complaints, AI, voice, or provider flows.

### Data/domain inventory

- **Repositories:** `AuthRepository`/`AuthRepositoryImpl`; `SplashRepository`/`SplashRepositoryImpl`.
- **Datasources:** `AuthRemoteDatasource` (currently mock delay/response); `SplashLocalDataSource`.
- **Models:** `AuthResponseModel` only.
- **Entities:** `UserEntity`, `SplashDestination` only.
- **Use cases:** none.
- **API abstraction:** Dio client, endpoints, result/failure types, exception mapping; only auth wiring consumes the abstraction and does not currently issue real Dio requests.

## 3. Constants and theme inventory

Files: `app_colors.dart`, `app_text_styles.dart`, `app_spacing.dart`, `app_sizes.dart`, `app_font_size.dart` (`AppFonts`), `app_assets.dart`, `app_strings.dart`, `app_icons.dart`, `app_constants.dart`, `constant.dart` barrel export; theme in `core/theme/app_theme.dart`.

- `AppColors` is the most consistently used token source, but screens still use `Colors.white`, `Colors.red`, `Colors.green`, opacity variants, gradients, and inline colors.
- `AppTextStyles` is used by the theme, but many screens use inline `TextStyle` and font sizes.
- `AppSpacing` and `AppSizes` are defined but almost entirely bypassed by literal `EdgeInsets`, `SizedBox`, widths, heights, and radii.
- `AppFonts` duplicates typography values represented in `AppTextStyles`; it is unused.
- `AppConstants.appName` is stale (`My App`) and is unused; `AppConstants` is otherwise unused.
- `AppStrings` covers a small auth/request vocabulary and is used only by some auth screens. It duplicates the purpose of localization and is not Urdu-aware.
- `constant.dart` is a broad barrel; retain for compatibility until usage is mapped, then narrow/replace deliberately.
- `AppAssets` points to five image files, but no `assets/` directory is present in the checkout and `pubspec.yaml` has no asset declaration. These are currently unresolved asset references if rendered.
- `AppTheme` defines only a light theme, declares Poppins without a font asset registration, and contains duplicated/inline values.

**Batch 2 centralization candidates:** spacing/radii/sizes, semantic colors/status colors, typography, button/input dimensions, animation timing, app name, and storage keys. Do not delete current classes until references and compatibility are mapped.

## 4. Localization inventory

- Configuration is correct in shape: `l10n.yaml`, `flutter: generate: true`, `lib/l10n/app_en.arb`, `app_ur.arb`, and generated `app_localizations*.dart` exist.
- English and Urdu ARBs contain only four keys: login, signup, email, password.
- `MaterialApp` supports `en` and `ur`, supplies Flutter and app delegates, and uses the locale provider.
- Locale persistence exists via `SharedPreferences` and defaults to English.
- Most UI bypasses l10n: auth screens use `AppStrings` or literals; onboarding, customer/provider, notifications, chat, OTP, splash, AI, and voice screens contain hardcoded English.
- Urdu is implemented ad hoc with `isUrdu ? Urdu : English` in customer home, AI, and voice screens. Urdu strings are also absent from the generated ARB API.
- Hardcoded examples include `Hello`, `Categories`, `Nearby Providers`, `Notifications`, `Chat`, `Verification`, `Enter OTP`, `Invalid code. Try again.`, splash status copy, job/provider demo content, and provider labels.

**Required later:** one source of truth (ARB/generated `AppLocalizations`), complete key coverage, removal of `AppStrings` UI duplication or a deliberate domain-only split, and no locale conditionals in widgets.

## 5. RTL/LTR status

`MaterialApp` supplies `GlobalWidgetsLocalizations` and locale `ur`, so the framework can select RTL. However, no explicit `Directionality`/text-direction policy is present and layout correctness is not established.

Observed risks:

- Rows use `Alignment.centerLeft/centerRight`, `crossAxisAlignment.start`, fixed leading/trailing assumptions, and literal `Icons.arrow_back`, `arrow_forward`, `chevron_right`, and send icons without auditing RTL semantics.
- Several screens use fixed `TextAlign`, padding, widths, and manual horizontal placement.
- Chat bubbles and customer-home greeting/quick actions are based on physical left/right rather than directional layout semantics.
- Navigation has no RTL-aware transition/icon policy.
- Because much of the UI is still hardcoded English, Urdu behavior cannot be considered complete.

**Batch 4 targets:** verify app-level direction, replace physical edge assumptions with directional APIs, audit icons and alignment, and test every form/card/navigation surface in both locales.

## 6. Reusable UI candidates

Already reusable in `core/widgets`: `AppTextField`, `PrimaryButton`, `AuthenticationPrompt`, `ErrorView`, `LoadingIndicator`.

Candidates for later extraction (not created in this batch):

- Auth form field/password field and validation/error presentation: duplicated in login/signup and currently lacks a reusable password visibility control.
- Primary/secondary buttons and loading button state: inline `ElevatedButton` styling is repeated across auth, OTP, customer, provider, AI, and onboarding.
- Page/screen padding container and section header: repeated `Padding`, `SizedBox`, headings in customer/provider/settings screens.
- Service/provider card: local `_ProviderCard` implementations exist in customer home and provider selection with overlapping concepts.
- Chat bubble/message composer: local `_Bubble`, repeated message input styling, and future chat states belong to the customer chat slice first; extract to core only if role-neutral.
- Status/badge/chip: onboarding role cards, customer categories, splash status chips, rating/status labels overlap but may need feature-specific variants.
- Empty/error/loading states: `ErrorView` and `LoadingIndicator` exist but inline equivalents remain; localize their action labels later.
- Avatar/profile summary and confirmation/auth dialogs: profile/settings/provider surfaces are natural candidates once behavior is real.

Do not move domain-specific provider/job cards into core merely because their visual shape is similar.

## 7. Animation status

Animation is concentrated in splash and customer home:

- Splash uses `AnimationController`, `AnimatedBuilder`, `CustomPainter`, `CustomClipper`, `Transform`, opacity/scale effects, status reveal, particles, glow, grid, and a reusable-looking SmartTrust mark.
- Customer home uses an `AnimationController` and several `AnimatedContainer` children.
- OTP boxes use `AnimatedContainer`; voice uses `AnimatedScale`.
- Other feature screens have little or no animation.

There is no shared animation utility/system. Durations are scattered (200ms, 250ms, 300ms, 800ms, 900ms, 1400ms, 2s), with mixed curves and no tokens. Splash has the strongest reusable material, but its widgets remain feature-specific until a later design-system decision. No excessive animation problem was identified; the bigger issue is inconsistent coverage/timing and simulated delays mixed with UX animation.

**Later animation system:** centralize motion durations/curves and provide narrowly scoped entrance/press/loading primitives; do not add random `AnimatedContainer`s.

## 8. Routing status

Routing is nominally centralized in `core/router/app_router.dart` and names in `route_names.dart`, which is good. It is not access-controlled or fully coherent:

- No `redirect`, auth refresh/listenable, unauthorized route implementation, role guard, or guest policy exists.
- Every registered route can be deep-linked by a guest.
- Splash makes a route decision itself and then calls `context.go`; route paths are duplicated in its mapper instead of using `RouteNames`.
- Screens perform navigation directly, so flow knowledge is distributed across presentation.
- OTP always navigates to customer home, even when a provider role was selected.
- Provider profile/settings route shared customer screens, and provider verification maps to a provider home placeholder.
- Duplicate provider feed routes and dead names exist.

## 9. Guest mode status

There is an `AuthenticationPrompt` widget, but no route guard and no evidence it is used by protected screens. Current guests can directly navigate to customer, provider, notifications, AI, voice, chat, profile, settings, job, and quotation routes. Protected actions are not consistently gated. Login/signup are demo flows, and a token/role may be fabricated from mock auth. Guest mode is therefore not safe; later work must define public routes, protected routes, role gates, and action-level prompts without relying on UI hiding alone.

## 10. API/data-layer status

The intended API stack exists but is mostly unused:

- `Env.apiBaseUrl` uses `String.fromEnvironment` with a placeholder `https://api.smarttrust.local` default.
- Dio has timeouts, JSON headers, auth header injection, logging, and a refresh-on-401 attempt.
- Endpoint constants cover auth, jobs, quotations, reviews, provider registration/feed/earnings, chat, and notifications, but contracts are unconfirmed.
- Auth datasource accepts Dio but never calls it; it returns hardcoded demo tokens/users after delays.
- Customer home returns inline `List<dynamic>` maps after a delay; no entity/model/repository/datasource/use case exists.
- Most feature screens contain inline static data and callbacks that only show a snackbar or do nothing.
- `network_exceptions.dart` duplicates the result/failure hierarchy in `api_result.dart`.

The UI cannot currently be switched to Spring Boot by replacing datasource implementation alone for customer/provider features; repositories, domain models/use cases, and providers are missing. Auth is closest to replaceable, but current mock responses and `getCurrentUser()` TODO must be resolved.

## 11. Customer/provider separation

There are separate directory trees and separate route prefixes for customer and provider flows, and signup/onboarding expose `customer`/`provider` roles. This is a useful shell separation.

It is incomplete/unsafe:

- No role guard prevents cross-role deep links.
- OTP hardcodes customer destination.
- Provider profile/settings reuse customer screens.
- `providerVerification` renders provider home rather than a verification domain flow.
- Provider registration is a presentation stepper without data/domain layers.
- Customer home provider and all provider screens use demo/static data.
- Admin appears in splash domain routing despite the mobile scope explicitly excluding it.

## 12. Hardcoded values categorized

### A — centralize in theme/constants

Inline `EdgeInsets`/`SizedBox` values, radii (12/14/16/20/24/99), button padding, icon/avatar dimensions, font sizes/weights, repeated white/red/green colors, status colors, animation durations/curves, and app identity (`My App` vs `SmartTrust`).

### B — localize through l10n

All visible copy in onboarding/auth/OTP/customer/provider/notifications/chat/AI/voice/splash, validation/error/snackbar labels, role labels, category names, status labels, and accessibility labels. Remove `isUrdu ? ... : ...` from widgets.

### C — remain feature/domain data

Demo provider names, categories, ratings, distances, AC repair/Lahore job details, chat messages, notification records, and other sample records should become typed feature/domain data or fixtures, not global constants.

### D — remain networking configuration

`API_BASE_URL`, timeout values, endpoint paths, auth refresh behavior, headers, and environment/flavor configuration. The default local URL is configuration, not UI data, but must not be treated as production.

### E — legitimate one-offs

Canvas geometry, splash particle math, shield path percentages, perspective-grid calculations, and tightly scoped decorative opacity values can remain local if they are part of the animation implementation and not repeated design tokens.

## 13. Architecture violations/findings

1. **Missing use-case layer:** providers call repository methods directly; all non-auth/splash flows bypass the expected use-case/repository chain.
2. **Presentation business logic:** AI and voice simulate processing/commands in screen state; OTP verifies hardcoded `1234` and routes to customer; complaints submit a snackbar; customer home owns demo presentation data.
3. **Direct storage access from presentation:** role selection obtains `SharedPreferences` directly; locale persistence lives in a core notifier rather than an explicit storage abstraction.
4. **Direct route/flow logic in screens:** numerous `context.go/push` calls and role decisions are distributed across screens.
5. **Duplicated network result abstractions:** `api_result.dart` vs `network_exceptions.dart`.
6. **Inconsistent storage keys:** splash and auth/core storage cannot reliably share the same session/onboarding state.
7. **Feature-specific/demo logic is not modeled:** static customer/provider/chat/notification data is embedded in presentation.
8. **Localization bypass:** `AppStrings`, literals, and `isUrdu` conditionals bypass generated l10n.
9. **Core drift:** stale/unused constants, unimplemented local-storage provider, and a broad barrel export need cleanup only after reference mapping.
10. **Role boundary violation:** admin launch destination is represented in mobile code, and shared customer screens are used for provider routes.
11. **Asset configuration gap:** declared asset constants have no corresponding files/declaration in the checkout.
12. **Test gap:** the only test is the default counter smoke test and does not correspond to this app; it also pumps `App` without the required splash provider override.

No evidence was found of a presentation import directly invoking Dio or a datasource. The auth datasource’s Dio field is unused rather than incorrectly called by UI.

## 14. Requirements status from available repository material

Because no proposal/R&D/database documents exist in this checkout, this is a code-baseline status rather than a business-requirements signoff.

- **Implemented/represented:** two mobile role labels and route namespaces; onboarding language/role shell; splash decision shell; auth repository contract and mock auth flow; English/Urdu locale plumbing; customer/provider screen placeholders; networking/storage scaffolding; animated premium splash treatment.
- **Partially implemented:** authentication (mock only, no current-user validation/OTP backend); customer request flow (screens only); provider registration/verification (presentation stepper only); provider feed/quotations/earnings (demo UI); chat/notifications/reviews/complaints (static UI); AI/voice (simulated demo); RTL; localization; guest gating; route role separation.
- **Missing in implementation:** real API integration, typed domain/data layers for almost all features, use cases, access guards, reliable session restoration, backend-backed customer/provider workflows, and test coverage.
- **Represented incorrectly:** mobile admin destination exists despite Admin being out of scope; auth OTP routes every user to customer home; provider profile/settings point at customer screens; unresolved asset constants imply assets that are absent.

## 15. Exact recommendations for Batch 2 (constants/theme only)

1. Build a reference map for every constant class before changing or deleting anything.
2. Define the canonical token ownership: `AppColors`, typography, spacing, dimensions, radii, icon sizes, motion durations/curves, assets, and app metadata.
3. Remove stale `My App` metadata only after confirming no external flavor/build dependency; align it with SmartTrust.
4. Decide whether `AppFonts` is folded into typography tokens and whether `constant.dart` remains a compatibility barrel.
5. Replace repeated UI literals incrementally with tokens in existing screens; do not redesign screens or alter feature behavior.
6. Keep feature/domain sample content out of global constants.
7. Consolidate duplicate result types only in a later architecture-safe cleanup, not as an incidental theme change.
8. Verify/register actual assets before retaining `AppAssets` paths; do not invent image files.
9. Add token-level tests or static checks only if they do not require feature implementation.

Batch 2 should not begin localization, RTL, route guards, API integration, new screens, or animation-system implementation.

## Verification record

- Repository and all tracked Dart/config/document files were inspected by directory and implementation, not filename alone.
- `flutter analyze` was attempted but could not execute because the Flutter SDK is unavailable in the environment.
- No source files were modified for Batch 1 other than this audit report.
