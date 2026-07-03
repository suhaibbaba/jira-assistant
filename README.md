# Triage — Jira ticket triage app (Mac & Windows)

A native desktop app that pulls your Jira tickets read-only, groups them by status,
orders them by priority (with manual drag-to-reorder), surfaces aging tickets every
morning, lets you watch teammates, opens any ticket in the browser by clicking its
key or link icon, and includes **Jarvis** — a voice/text assistant that organizes
your day, manages personal lists, and logs your time. **It never writes anything
back to Jira.**

## Jarvis assistant (new)
- **Click the mic** to talk, click again to stop; or type commands.
- Works **fully offline** for structured commands — no AI, nothing leaves your machine:
  - "Organize my day" / "What did I forget?" → local rules rank your tickets
  - "Add XSD-1 for estimates" / "Dismiss XSD-2" / "Follow up XSD-3" / "Priority watch XSD-4"
  - "Show my Follow Up list"
  - "Log 2 hours on XSD-1 for development"
  - "What have I logged today?"
- **Optional AI** (Settings → Jarvis AI key): only open-ended questions call Claude,
  and only compact one-line ticket summaries are sent (key, priority, status, age,
  project) — never descriptions. Leave the key blank to stay 100% offline.

## Personal lists (local only)
Estimates Needed · Follow Up · Dismissed · Priority Watch. Managed by Jarvis or click.

## Time tracking
Manual entry (ticket + hours + work type) and voice logging. End-of-day summary with
per-ticket totals, copy/export as text. Logs older than 30 days auto-delete silently.

> ⚠️ Voice + AI need one-time platform permissions — see **PERMISSIONS.md**.

---

## What you need (one-time, ~15 min)

1. **Install Flutter** — https://docs.flutter.dev/get-started/install
   - On **Mac**: also install Xcode from the App Store.
   - On **Windows**: also install Visual Studio (Community edition) with the
     "Desktop development with C++" workload.
2. **Get a Jira API token** — https://id.atlassian.com/manage-profile/security/api-tokens
   Click "Create API token", copy it. You'll paste it on the app's login screen.

Verify Flutter is ready:

```bash
flutter doctor
```

Fix anything it flags with a ✗ before continuing.

---

## Run the app

From inside this `triage/` folder:

```bash
flutter pub get          # download dependencies (first time only)

# then run on your platform:
flutter run -d macos     # on a Mac
flutter run -d windows   # on Windows
```

The first build takes a few minutes. After that it's fast.

On first launch, enter:
- **Jira domain** — e.g. `yourcompany.atlassian.net`
- **Email** — your Atlassian login email
- **API token** — the one you created above
- **JQL filter** — optional; leave blank to see tickets assigned to or reported by you

---

## Build a standalone app (to share / keep)

```bash
flutter build macos      # → build/macos/Build/Products/Release/triage.app
flutter build windows    # → build/windows/x64/runner/Release/  (triage.exe + dlls)
```

On Mac you can drag `triage.app` into Applications.
On Windows, zip the whole `Release` folder and run `triage.exe`.

> Note: distributing to other Macs without security warnings needs an Apple Developer
> account ($99/yr) for code-signing. For your own machine it runs as-is.

---

## How it works (quick map of the code)

```
lib/
  main.dart                     app entry, routing (connect ↔ board)
  models/
    ticket.dart                 Jira issue + aging / business-day math
    settings.dart               all persisted settings + credentials
  services/
    jira_service.dart           Jira REST calls (typed success/error result)
    storage_service.dart        Keychain token + prefs + offline cache
    notification_service.dart   native Mac/Windows notifications
  state/
    app_state.dart              the brain: sync, retry backoff, grouping, actions
  theme/
    app_theme.dart              Apple-style colors, status/priority palettes
  widgets/
    sidebar.dart                scope toggle, status checkboxes, projects, team
    ticket_card.dart            card with clickable key + link icon
    ticket_detail_dialog.dart   popup shown when a card is tapped
  screens/
    connect_screen.dart         login
    board_screen.dart           main board + toolbar + sync button
    digest_screen.dart          morning digest (aging + new)
    settings_screen.dart        aging rules, team, intervals
```

### Key behaviors
- **Read-only**: the app only ever GETs from Jira. No write endpoints are called.
- **Sync button** (top-right) with "Synced Xm ago"; auto-polls every 5/15/30 min.
- **Offline / token errors**: keeps showing cached data, shows a bar, auto-retries
  with backoff (30s → 1m → 2m → 5m). Auth errors stop retrying and ask to reconnect.
- **Status grouping**, priority ordering, drag-to-reorder saved locally by ticket key.
- **Aging** is per-status (New alerts after 1 day; In Progress never), business-days
  by default.
- **Team** members added manually by name/email; toggle each on/off.
- **Open in browser**: click the ticket key OR the link icon on any card.
- **Estimate Requested**: add any ticket by key via the ＋ button in the toolbar.

---

## Customizing
- **Accent color / palette**: `lib/theme/app_theme.dart`
- **Default aging thresholds**: `AppSettings._defaultAgingRules()` in `lib/models/settings.dart`
- **Status names**: if your Jira uses different status names (e.g. "To Do" instead of
  "New"), update the keys in `AppColors.status` (theme) and the default
  `visibleStatuses` / aging rules so they match your workflow exactly.
