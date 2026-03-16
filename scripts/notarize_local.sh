#!/bin/zsh

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <app-path> <keychain-profile> [output-zip-path]" >&2
  exit 1
fi

APP_PATH="$1"
PROFILE_NAME="$2"
ZIP_PATH="${3:-${APP_PATH:r}.zip}"

if [[ ! -d "$APP_PATH" ]]; then
  echo "App not found: $APP_PATH" >&2
  exit 1
fi

rm -f "$ZIP_PATH"

echo "Packaging app for notarization..."
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$ZIP_PATH"

echo "Submitting archive to Apple notarization service..."
xcrun notarytool submit "$ZIP_PATH" \
  --keychain-profile "$PROFILE_NAME" \
  --wait

echo "Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"

echo "Validating stapled ticket..."
xcrun stapler validate "$APP_PATH"

echo "Gatekeeper assessment..."
spctl -a -vv "$APP_PATH"

echo "Notarization complete for: $APP_PATH"
