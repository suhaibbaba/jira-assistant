# Changelog — Refactor & Upgrade (2026-07-06)

All five tasks delivered on top of `4a82a28`. Visuals are pixel-identical
except where a task explicitly changes behavior (1 and 4). The read-only
Jira guarantee is untouched: the app still calls only the two GET endpoints
(`/rest/api/3/search/jql`, `/rest/api/3/issue/{key}`); `jira_service.dart`
request logic was not modified.

---

## 1. Notification/alert system removed

- **Deleted** `lib/services/notification_service.dart` and the
  `local_notifier` dependency (pubspec + lockfile).
- `lib/main.dart` — no more `NotificationService.init()`.
- `lib/state/app_state.dart` — removed the new-high-priority alert loop in
  `_onSyncSuccess`, `_maybeSendMorningDigest()` (and its call), and
  `sendTestNotification()`.
- `lib/screens/settings_screen.dart` — removed the "Notifications / Send
  test" row.
- `lib/models/settings.dart` — removed the now-dead `notifyPriorities`
  field (`notifyP` JSON key). Old saved settings still load; the extra key
  is ignored.
- **Kept** (as specified): aging logic (`agingTickets`, per-status
  `agingRules`), the Digest screen, and the `morningDigestTime` /
  `morningDigestEnabled` settings (the time is still shown in Settings).

## 2. Single source of truth for the app name

- **New** `lib/config/app_info.dart` → `AppInfo.appNameShort` ("Xngage"),
  `AppInfo.appNameFull` ("Xngage — Jira Assistance"),
  `AppInfo.appVersion` ("1.6.0", mirrors pubspec).
- Replaced hardcoded names in `main.dart` (MaterialApp title),
  `board_screen.dart` (toolbar), `connect_screen.dart` (header).
- `pubspec.yaml` — comment on `msix_config.display_name` noting it must be
  kept in sync by hand (yaml can't read Dart constants).
- **⚠ One manual edit for you** (macos/ was not touched):
  `macos/Runner/Configs/AppInfo.xcconfig` →
  change `PRODUCT_NAME = triage` to `PRODUCT_NAME = Xngage`.

## 3. All user-facing strings externalized (l10n)

- **New** `l10n.yaml`, `lib/l10n/app_en.arb` (~110 keys, named by
  screen/purpose: `connectDomainLabel`, `settingsSavedToast`, …), generated
  `lib/l10n/gen/app_localizations*.dart` (checked in; regenerate with
  `flutter gen-l10n`).
- `pubspec.yaml` — added `flutter_localizations`, `generate: true`;
  `intl` bumped `^0.19.0` → `^0.20.2` (pinned by flutter_localizations).
- `MaterialApp` wired with `AppLocalizations.localizationsDelegates` /
  `supportedLocales`. **Adding Arabic later = drop in
  `lib/l10n/app_ar.arb` and run `flutter gen-l10n`.** Nothing else.
- Every screen/widget swept; strings are byte-identical to before.
- Deliberate scoping (flagged for honesty):
  - Jira **status names** ("New", "Blocked", …) and **priority names** are
    server data used as keys and display — not localized. The app-invented
    "Needs Attention" bucket has an l10n display key
    (`statusNeedsAttention`) while the internal key stays English.
  - `WorkType` labels: the dropdown/log rows use l10n via a widget-side
    mapping; the model keeps `.label` only for the clipboard export.
  - Strings generated in **models/services** are NOT in the .arb:
    `JiraService` error messages (shown in the connection bar),
    `Ticket.ageLabel`/`updatedLabel` ("3d", "5h"),
    `AttentionMeta.agoLabel` ("2d ago"), `Ticket` "(no summary)" fallback,
    and `TimeTracker.endOfDaySummary()` export text. These are the
    remaining English literals; they live outside widgets, which was the
    sweep's scope.
  - Pure glyphs (🎯, ⋮⋮, −, +, 🔒/⚠️ prefixes) stay inline — no language
    content.
  - Count strings ("{count} new tickets need attention") kept verbatim (no
    ICU plural forms) to honor pixel-identical output; converting them to
    plurals later is a one-line .arb change.

## 4. GitHub update check + release workflow

- **New** `lib/services/update_service.dart` — on launch, max once/day
  (`shared_preferences` date stamp), GET
  `api.github.com/repos/<OWNER>/<REPO>/releases/latest`, semver-compares
  `tag_name` to `AppInfo.appVersion`. Silent on any failure. Per-version
  dismissal persisted. **Fill in `<OWNER>`/`<REPO>` at the top of the
  file.** (While the placeholders are present the check is a no-op.)
- `lib/state/app_state.dart` — `availableUpdate`, `dismissUpdate()`,
  `openUpdatePage()`; check fired at the end of `bootstrap()`.
- `lib/screens/board_screen.dart` — new `_UpdateBar` strip under the
  toolbar: "v1.7.0 available — Download ↗", tap opens the release page,
  ✕ dismisses that version permanently.
- **New** `.github/workflows/release-macos.yml` — on `v*` tag push:
  analyze + test + `flutter build macos --release`, `ditto`-zip the .app,
  create a GitHub Release with the zip attached.
- **New** `test/update_service_test.dart` — unit tests for the semver
  comparison (newer / same / older / short / suffixed versions).

## 5. Design tokens (pixel-identical)

- `lib/theme/app_theme.dart` is now a barrel: `buildAppTheme()` + exports.
  Existing `import 'package:triage/theme/app_theme.dart'` lines all still
  work.
- **New** `lib/theme/app_colors.dart` — original palette preserved
  exactly; added semantic aliases (`surface`, `textPrimary/Secondary/
  Tertiary`, `success`, `warning`, `danger`), per-status/per-priority
  constants (`statusNew`, `priorityHighest`, …, maps built from them), and
  a name for every hex that used to be inline in screens
  (`connectGradientTop/Bottom`, `errorSurface/Border/Text`,
  `offlineBannerBg/Text`, `authBannerBg/Text`, `fieldBorder`, `fieldLabel`,
  `textBody`, `dragHandle`, `secondaryButtonBg`, `dangerGradientEnd`,
  `warningGradientEnd`, `noteChipBg`, `knobShadow`).
- **New** `lib/theme/app_dimens.dart` — `AppSpacing` (2-px scale so every
  hand-tuned padding maps 1:1) and `AppRadius` (r4–r16 + const
  `BorderRadius` values `br4`–`br16`).
- **New** `lib/theme/app_typography.dart` — heading, appBarTitle,
  sectionTitle, toolbarTitle, bannerTitle, dialogTitle, overline(-Small),
  detailLabel, body, cardSummary, bodyLong, rowLabel, bodySecondary,
  caption, rowHint, mono, buttonLabel(-Secondary).
- Promoted reused bespoke widgets into the ui kit (all exported from
  `ui.dart`):
  - **`AppStepper`** ← settings `_stepper`/`_stepBtn`
  - **`AppSegmentedControl`** ← settings `_segRow` internals + sidebar
    `_segmented` (one component, `expanded:` toggles the two layouts)
  - **`KeyChip`** ← ticket_card `_KeyChip` + the detail-dialog header chip
    (`large:` / `showOpenIcon:` cover both looks)
- Swept every screen/widget: raw `Color(0x…)` → tokens (also inside
  `lib/widgets/ui`), recurring `TextStyle`s → `AppTypography`, radii →
  `AppRadius`.
- **Acceptance met**: `grep -rn "Color(0x" lib/screens lib/widgets
  --include=*.dart` → zero hits (stricter than required — the ui kit is
  clean too).
- Honest note: unique one-off paddings/font sizes (e.g. `fromLTRB(9, 10,
  12, 10)` on cards, 9/15 px one-off font sizes) remain as literals inside
  otherwise token-based styles; forcing them onto a coarse scale would have
  changed pixels.

## 6. Comment strip (requested mid-task)

- All `//`, `///`, `/* */` comments removed across `lib/` (27 files) with
  a Dart-aware lexer; `// ignore:` / `// ignore_for_file:` directives kept;
  string contents (URLs, regexes, interpolations) untouched.
- `lib/l10n/gen/` excluded — Flutter regenerates those files with comments
  on every `gen-l10n` run, so stripping them would not stick.

## Other

- `test/widget_test.dart` — the stale template test referenced a
  nonexistent `MyApp` and `flutter_test` was missing from
  dev_dependencies, so tests could never run. Replaced with a real smoke
  test (unconfigured app → ConnectScreen) and added `flutter_test`.
- `macos/Flutter/GeneratedPluginRegistrant.swift`,
  `windows/flutter/generated_plugin*` — regenerated automatically by
  `flutter pub get` when local_notifier was removed (not hand-edited).

## Verification performed

- `flutter analyze` — 0 errors, 0 warnings (5 pre-existing info-level
  lints: two `DropdownButtonFormField.value` deprecations, one
  `ReorderableListView.onReorder` deprecation, one const-literal hint, one
  curly-braces hint).
- `flutter test` — 4/4 pass.
- `flutter gen-l10n` — generates cleanly.
- `flutter build macos --debug` — full compile (see final report).
- Acceptance grep for `Color(0x` — clean.

## Not verifiable without a release/tag

- The GitHub Actions workflow (needs a pushed `v*` tag to run).
- The update banner end-to-end (needs real OWNER/REPO with a published
  release; the semver logic is unit-tested, the banner renders from
  `AppState.availableUpdate`).
- macOS release signing/notarization behavior (Personal Team cert).
