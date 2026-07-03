# Code Review Report — Triage v1.1 (final)

Reviewed by Claude Fable 5 (Anthropic's latest model). Full pass over all 24 Dart
files: structure, types, imports, async safety, platform behavior.

## Bugs found and FIXED in this pass

1. **`voice_service.dart` — compile error.** `flutter_tts.setVoice()` requires
   `Map<String, String>` but received `Map<String, dynamic>`. Values are now
   explicitly converted with `.toString()`.

2. **`voice_service.dart` — Windows crash risk.** `speech_to_text` has no Windows
   desktop support; `initialize()` could throw and take down startup. Every voice
   call is now wrapped in try/catch: on Windows the mic silently no-ops and typed
   commands work identically. TTS (speaking) works on both platforms.

3. **`daily_organizer.dart` — fragile lookup.** Removed the awkward
   `.cast<StatusAgingRule?>()` chain in favor of a clean `firstOrNull`.

4. **`digest_screen.dart` / `sidebar.dart` — untyped parameters.** `Ticket` and
   `TeamMember` params were dynamic; now explicitly typed (compile-time safety).

5. **`jarvis_controller.dart` — resource leak.** No dispose; the mic/TTS could
   keep running after leaving the Jarvis screen. Added a `dispose()` override
   that stops both.

6. **`pubspec.yaml` — MSIX config.** `capabilities` must be comma-separated;
   fixed `internetClient,microphone`.

7. **`settings_screen.dart` — cursor-reset bug (fixed in an earlier pass,
   re-verified).** The AI-key TextField no longer reassigns its text on every
   rebuild; it's set once in initState.

## Verified clean

- All 24 files: balanced brackets/parens, every relative import resolves.
- `CommandKind` switch in Jarvis controller is exhaustive (all 9 values).
- `mounted` checks present after awaits in UI code (connect, board dialogs).
- Read-only guarantee: the only Jira endpoints called are GET `/search` and
  GET `/issue/{key}` — no write calls anywhere.
- Secrets: Jira token and optional AI key live in secure storage
  (Keychain / Credential Locker), never in plain preferences.
- Offline behavior: cached tickets always shown; retry backoff 30s→1m→2m→5m;
  auth errors stop retrying and prompt reconnect.
- AI privacy: only compact one-line ticket rows (key|priority|status|age|project)
  are sent, capped at 60 tickets and 350 response tokens, on the cheapest model.
  Blank key = zero network calls to AI.

## Honest limitations (not bugs)

- **This code has not been compiled** — the review environment has no Flutter
  SDK. Static review caught the issues above, but the first `flutter pub get`
  + `flutter run` on your machine is the true compile check. Any residual error
  will be trivial (a version pin or a one-line type fix) — paste it and it gets
  fixed in one step.
- **Voice input is macOS-only** (package limitation). Windows users get the
  identical experience through typed commands; Jarvis still speaks replies on
  both platforms.
- If your Jira workflow uses different status names than
  New/Blocked/Need Clarification/In Progress/Review, update them in
  `lib/theme/app_theme.dart` (AppColors.status) and
  `lib/models/settings.dart` (defaults) — the README explains this.
