# How to turn Xngage-Jira into a real installed app (Mac & Windows)

**You build it once. After that it's a normal app — open it from Launchpad
(Mac) or the Start Menu (Windows). No terminal, no modules, ever again.**

The command-line steps below happen **one time** to produce the app. The app
itself, once installed, has nothing to do with Flutter or the terminal — just
like any other program on your computer.

It's completely **free** for your own machines. (Paying Apple/Microsoft is only
needed if you want to publish on their stores or hand it to strangers without a
security prompt — not needed for you.)

---

## One-time setup (per machine)

You only need this to *build*. Skip if already installed.

**Mac**
1. Install Flutter: https://docs.flutter.dev/get-started/install/macos
2. Install Xcode from the App Store (needed to compile Mac apps).

**Windows**
1. Install Flutter: https://docs.flutter.dev/get-started/install/windows
2. Install Visual Studio (Community — free) with the
   **"Desktop development with C++"** workload checked.

Check everything is ready:
```
flutter doctor
```

---

## Easiest: let GitHub build both

Bump `version:` in `pubspec.yaml` (and `AppInfo.appVersion`) and push to
`main` — or push a tag like `v1.8.0`, or click **Run workflow** on the
*Release* action. GitHub builds on real Mac and Windows machines and attaches
these to the release:

| File | What it is |
|---|---|
| `Xngage-vX.Y.Z-macos.dmg` | Mac installer — open it, drag the app to Applications |
| `Xngage-vX.Y.Z-macos.zip` | The bare Mac `.app`, zipped |
| `Xngage-vX.Y.Z-windows-setup.exe` | Windows installer — Start Menu entry, optional desktop icon, uninstaller |
| `Xngage-vX.Y.Z-windows-portable.zip` | Unzip anywhere and run `triage.exe`, no install |

## Build it yourself

### On a Mac
```bash
bash build_mac.sh
```
Puts the `.dmg` and `.zip` in `dist/`.

### On Windows
Also install **Inno Setup 6** (free): https://jrsoftware.org/isdl.php — then
double-click `build_windows.bat`. Puts `Setup.exe` and the portable `.zip`
in `dist\`.

## Important: build on the matching OS

A Mac app can only be built on a Mac; a Windows app only on Windows.
Since you have both, run `build_mac.sh` on the Mac and `build_windows.bat`
on the Windows PC. Each produces the installer for that system.

---

## If a build fails

Run `flutter doctor` — it lists exactly what's missing and how to fix it.
Then re-run the build script. If you paste me the error message, I'll tell you
the fix.

---

## A note on the security prompt (first open)

Because the app isn't signed with a paid developer certificate:
- **Mac**: the first time, right-click the app → **Open** → confirm. After that
  it opens normally. (Signing to remove this needs an Apple Developer account,
  $99/yr — optional, not required.)
- **Windows**: the installer may show "Windows protected your PC" → click
  **More info → Run anyway**. Normal for self-built apps.

These prompts are just because it's your own private build, not a store app.
The app is perfectly fine to use.
