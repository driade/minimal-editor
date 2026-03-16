#!/bin/zsh

set -euo pipefail

REPO="${1:-driade/minimal-editor}"
P12_PATH="${P12_PATH:-/Users/driade/Desktop/temporal/Certificados.p12}"
APPLE_TEAM_ID_VALUE="${APPLE_TEAM_ID_VALUE:-KYNN4JTWJN}"
TMP_KEYCHAIN="/tmp/minimaleditor-secret-check.keychain-db"
TMP_P12_COPY="/tmp/minimaleditor-cert-check.p12"

cleanup() {
  rm -f "$TMP_P12_COPY"
  security delete-keychain "$TMP_KEYCHAIN" >/dev/null 2>&1 || true
}
trap cleanup EXIT

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is required." >&2
  exit 1
fi

if [[ ! -f "$P12_PATH" ]]; then
  echo "P12 file not found: $P12_PATH" >&2
  exit 1
fi

read -r "APPLE_ID_VALUE?Apple ID: "
read -rs "APPLE_APP_SPECIFIC_PASSWORD_VALUE?Apple app-specific password: "
echo
read -rs "P12_PASSWORD_VALUE?P12 password: "
echo
read -rs "KEYCHAIN_PASSWORD_VALUE?Temporary keychain password for GitHub Actions: "
echo

# Validate that the base64 round-trip is lossless.
base64 -i "$P12_PATH" | tr -d "\n" | base64 -D > "$TMP_P12_COPY"
if ! cmp -s "$P12_PATH" "$TMP_P12_COPY"; then
  echo "Base64 round-trip check failed for $P12_PATH" >&2
  exit 1
fi

# Validate the .p12 and password locally before touching GitHub secrets.
security create-keychain -p "$KEYCHAIN_PASSWORD_VALUE" "$TMP_KEYCHAIN" >/dev/null
security unlock-keychain -p "$KEYCHAIN_PASSWORD_VALUE" "$TMP_KEYCHAIN" >/dev/null
if ! security import "$TMP_P12_COPY" -P "$P12_PASSWORD_VALUE" -A -t cert -f pkcs12 -k "$TMP_KEYCHAIN" >/dev/null; then
  echo "Local validation failed: the .p12 or its password is incorrect." >&2
  exit 1
fi

echo "Local .p12 validation succeeded. Uploading secrets to $REPO..."
TMP_B64="$(mktemp /tmp/minimaleditor-cert.XXXXXX)"
base64 -i "$P12_PATH" | tr -d "\n" > "$TMP_B64"
gh secret set BUILD_CERTIFICATE_BASE64 --repo "$REPO" < "$TMP_B64"
rm -f "$TMP_B64"
gh secret set P12_PASSWORD --repo "$REPO" --body "$P12_PASSWORD_VALUE"
gh secret set KEYCHAIN_PASSWORD --repo "$REPO" --body "$KEYCHAIN_PASSWORD_VALUE"
gh secret set APPLE_ID --repo "$REPO" --body "$APPLE_ID_VALUE"
gh secret set APPLE_APP_SPECIFIC_PASSWORD --repo "$REPO" --body "$APPLE_APP_SPECIFIC_PASSWORD_VALUE"
gh secret set APPLE_TEAM_ID --repo "$REPO" --body "$APPLE_TEAM_ID_VALUE"

echo "Secrets updated for $REPO"
