# How to turn Triage into a real installed app (Mac & Windows)

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

## Build the app

### On a Mac
Open Terminal in the `triage` folder and run:
```bash
bash build_mac.sh
```
You get:
- `triage.app` — the application
- `Triage-Installer.dmg` — double-click it, drag Triage to Applications. Done.

From then on, Triage is in Launchpad / Applications like any Mac app.

### On Windows
Open the `triage` folder and **double-click `build_windows.bat`**
(or run it in a terminal).
You get:
- `triage.exe` — the application
- a `.msix` installer — double-click to install Triage.

From then on, Triage is in the Start Menu like any Windows app.

---

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
