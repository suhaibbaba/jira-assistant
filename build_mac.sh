#!/usr/bin/env bash
# ============================================================
#  Build the Mac app (.app) plus a .dmg installer and .zip
#  into dist/. Same outputs as the GitHub Release workflow.
# ============================================================
set -e
cd "$(dirname "$0")"

VERSION=$(grep '^version:' pubspec.yaml | head -1 | awk '{print $2}' | cut -d'+' -f1)
TAG="v$VERSION"

echo "==> 1/4  Getting dependencies..."
flutter pub get

echo "==> 2/4  Building the macOS app (release)..."
# Ad-hoc sign so the build works without an Apple provisioning profile.
FLUTTER_XCODE_CODE_SIGN_IDENTITY=- \
FLUTTER_XCODE_CODE_SIGN_STYLE=Manual \
FLUTTER_XCODE_DEVELOPMENT_TEAM= \
FLUTTER_XCODE_PROVISIONING_PROFILE_SPECIFIER= \
  flutter build macos --release

APP_PATH=$(ls -d build/macos/Build/Products/Release/*.app | head -1)
APP_NAME=$(basename "$APP_PATH")
rm -rf dist dmg-src && mkdir -p dist dmg-src

echo "==> 3/4  Zipping $APP_NAME..."
ditto -c -k --keepParent "$APP_PATH" "dist/Xngage-$TAG-macos.zip"

echo "==> 4/4  Creating the .dmg installer..."
if ! command -v create-dmg >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    brew install create-dmg
  else
    echo "    Homebrew not installed — skipping .dmg (the .zip is ready)."
    exit 0
  fi
fi
cp -R "$APP_PATH" dmg-src/
create-dmg \
  --volname "Xngage" \
  --window-size 540 380 \
  --icon-size 96 \
  --icon "$APP_NAME" 140 180 \
  --app-drop-link 400 180 \
  --no-internet-enable \
  "dist/Xngage-$TAG-macos.dmg" dmg-src/ || [ $? -eq 2 ]
rm -rf dmg-src

echo ""
echo "✅ Done — see dist/:"
ls -1 dist
