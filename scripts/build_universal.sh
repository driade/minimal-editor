#!/bin/zsh

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="${1:-$ROOT_DIR/build-universal}"
ARM64_DERIVED="$BUILD_DIR/derived-arm64"
X86_DERIVED="$BUILD_DIR/derived-x86_64"
OUTPUT_DIR="$BUILD_DIR/output"
APP_NAME="MinimalEditor.app"
ARM64_PRODUCTS="$BUILD_DIR/products-arm64"
X86_PRODUCTS="$BUILD_DIR/products-x86_64"
ARM64_APP="$ARM64_PRODUCTS/$APP_NAME"
X86_APP="$X86_PRODUCTS/$APP_NAME"
UNIVERSAL_APP="$OUTPUT_DIR/$APP_NAME"
SIGNING_IDENTITY="${SIGNING_IDENTITY:-}"
XCODEBUILD_SIGNING_ARGS=()

if [[ -z "$SIGNING_IDENTITY" ]]; then
  XCODEBUILD_SIGNING_ARGS=(CODE_SIGNING_ALLOWED=NO)
fi

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR"

xcodegen generate

xcodebuild \
  -project "$ROOT_DIR/MinimalEditor.xcodeproj" \
  -scheme MinimalEditor \
  -configuration Release \
  -derivedDataPath "$ARM64_DERIVED" \
  -destination "platform=macOS,arch=arm64" \
  ARCHS=arm64 \
  ONLY_ACTIVE_ARCH=YES \
  CONFIGURATION_BUILD_DIR="$ARM64_PRODUCTS" \
  "${XCODEBUILD_SIGNING_ARGS[@]}" \
  build

xcodebuild \
  -project "$ROOT_DIR/MinimalEditor.xcodeproj" \
  -scheme MinimalEditor \
  -configuration Release \
  -derivedDataPath "$X86_DERIVED" \
  -destination "platform=macOS,arch=x86_64" \
  ARCHS=x86_64 \
  ONLY_ACTIVE_ARCH=YES \
  CONFIGURATION_BUILD_DIR="$X86_PRODUCTS" \
  "${XCODEBUILD_SIGNING_ARGS[@]}" \
  build

ditto "$ARM64_APP" "$UNIVERSAL_APP"

lipo -create \
  "$ARM64_APP/Contents/MacOS/MinimalEditor" \
  "$X86_APP/Contents/MacOS/MinimalEditor" \
  -output "$UNIVERSAL_APP/Contents/MacOS/MinimalEditor"

if [[ -n "$SIGNING_IDENTITY" ]]; then
  codesign --force --deep --options runtime --timestamp --sign "$SIGNING_IDENTITY" "$UNIVERSAL_APP"
else
  codesign --force --sign - --deep --timestamp=none "$UNIVERSAL_APP"
fi

echo "Universal app created at: $UNIVERSAL_APP"
