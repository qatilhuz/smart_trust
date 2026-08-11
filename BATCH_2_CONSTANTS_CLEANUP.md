# SmartTrust — Batch 2 Constants Cleanup

## Completed

- Kept `AppColors` as the sole semantic color source and preserved the brand colors `#42A5F5` and `#0D2A4A`.
- Added the intentional `white70` semantic token used by existing dark-card text and replaced reusable raw white/red/green usages in affected screens with `AppColors` tokens.
- Consolidated `AppSpacing` aliases so named gaps and component padding resolve to the same scale values.
- Made `AppTextStyles` consume `AppFonts` metrics and added only the useful `input`, `navigation`, and `caption` aliases.
- Extended `AppSizes` with shared shape, border, and elevation tokens without creating a second dimensions system.
- Updated `AppTheme`, `AppTextField`, and `PrimaryButton` to consume spacing, size, radius, and border tokens.
- Corrected stale `AppConstants.appName` from `My App` to `SmartTrust`.
- Removed five unused `AppAssets` paths that pointed to a nonexistent `assets/` directory. No asset files were invented or downloaded.
- Updated affected existing feature references from raw semantic colors to `AppColors` without changing screen layouts or behavior.

## Intentionally unchanged/deferred

- `AppStrings` user-facing text remains in place temporarily; moving it to generated English/Urdu l10n is Batch 3.
- Remaining one-off decorative `Colors.white` opacity treatments and feature-local geometry were not blindly abstracted.
- Existing feature/domain data, routing, auth, API architecture, widgets, RTL behavior, and animations were not redesigned or implemented.
- The duplicate networking result abstractions identified in Batch 1 were not changed because they are outside the constants batch.
- No replacement assets were created; actual assets should be added only when supplied and declared in `pubspec.yaml`.

## Validation

- No raw `Color(...)` constructors remain outside `AppColors`.
- No unresolved `AppColors.white70` references remain; the token is declared centrally.
- No `AppAssets.*` references exist outside the empty compatibility class.
- `git diff --check` passed.
- Flutter/Dart validation could not run because the Flutter SDK is unavailable in the environment (`flutter: command not found`).
