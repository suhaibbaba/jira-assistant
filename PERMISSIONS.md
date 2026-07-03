# Platform permissions for Jarvis (voice + AI)

Flutter creates the native `macos/` and `windows/` folders the first time you run
`flutter create .` or `flutter run`. After that, add the permissions below so the
microphone and network work. (These files don't exist yet in this zip because the
native folders are generated on your machine — do this once after the first build.)

## macOS

1. **Microphone usage description** — in `macos/Runner/Info.plist`, add inside `<dict>`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>Triage uses the microphone so Jarvis can hear your voice commands.</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>Triage uses speech recognition to understand your voice commands.</string>
```

2. **Network + microphone entitlements** — in BOTH
   `macos/Runner/DebugProfile.entitlements` and
   `macos/Runner/Release.entitlements`, add:

```xml
<key>com.apple.security.network.client</key>
<true/>
<key>com.apple.security.device.audio-input</key>
<true/>
```

(The network client entitlement is also what lets the app reach Jira and, if you
enable it, the Claude API.)

## Windows

Windows desktop apps get microphone and network access without manifest changes
for locally-run builds. If you later publish via MSIX, the `capabilities:` line in
`pubspec.yaml` (already set to `internetClient microphone`) covers it.

## Quick start after unzipping

```bash
cd triage
flutter create .          # generates macos/ and windows/ native folders
# then apply the macOS plist/entitlement edits above
flutter pub get
flutter run -d macos      # or -d windows
```
