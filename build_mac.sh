#!/usr/bin/env bash
# ============================================================
#  Build Triage as a real Mac app (.app) and an installer (.dmg)
#  Run this ONCE on a Mac. After that, the app installs like
#  any other — no terminal, no modules needed to use it.
# ============================================================
set -e

echo "==> 1/4  Getting dependencies..."
flutter pub get

echo "==> 2/4  Building the macOS app (release)..."
flutter build macos --release

APP_PATH="build/macos/Build/Products/Release/triage.app"

echo "==> 3/4  App built at: $APP_PATH"
echo "         You can already drag this into /Applications."

echo "==> 4/4  Creating a .dmg installer..."
# create-dmg makes the nice drag-to-Applications window.
if ! command -v create-dmg >/dev/null 2>&1; then
  echo "    create-dmg not found. Installing via Homebrew..."
  if command -v brew >/dev/null 2>&1; then
    brew install create-dmg
  else
    echo "    Homebrew not installed. Skipping .dmg."
    echo "    The .app above works fine — just drag it to Applications."
    exit 0
  fi
fi

rm -f Triage-Installer.dmg
create-dmg \
  --volname "Triage" \
  --window-size 540 380 \
  --icon-size 96 \
  --icon "triage.app" 140 180 \
  --app-drop-link 400 180 \
  "Triage-Installer.dmg" \
  "$APP_PATH" || {
    echo "    create-dmg had a hiccup, but your .app is ready at $APP_PATH"
    exit 0
  }

echo ""
echo "✅ Done!"
echo "   • App:       $APP_PATH"
echo "   • Installer: Triage-Installer.dmg  (double-click → drag to Applications)"
