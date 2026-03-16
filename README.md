<p align="center">
  <img src="MinimalEditor/Assets.xcassets/AppIcon.appiconset/icon_512x512.png" alt="MinimalEditor icon" width="128">
</p>

# MinimalEditor

MinimalEditor is a native macOS plain-text editor built in Swift.

It is intentionally narrow in scope: one window, plain text only, `.txt` only, and persistent custom colors for the editor background and text.

The main use case is a permanently dark writing surface, for example black background with light text.

## Features

- Open existing `.txt` files
- Create new plain-text documents
- Save and Save As with enforced `.txt` extension
- Persistent global theme for background and text color
- Rich-text paste stripped down to plain text
- Unsaved changes warning before destructive actions

## Download

Prebuilt signed binaries are available from the [Releases](https://github.com/driade/minimal-editor/releases) page.

## Homebrew

```bash
brew tap driade/minimal-editor https://github.com/driade/minimal-editor
brew install --cask driade/minimal-editor/minimaleditor
```

This tap installs the notarized app published in GitHub Releases.

## Build

Requirements:
- macOS
- Xcode
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

```bash
git clone https://github.com/driade/minimal-editor.git
cd minimal-editor
xcodegen generate
./scripts/build_universal.sh
```

The app will be generated at:

```bash
build-universal/output/MinimalEditor.app
```

That command builds a universal macOS app with Apple Silicon and Intel slices.

If `SIGNING_IDENTITY` is set, the script signs the final universal app bundle. If not, it performs ad-hoc signing so the app remains runnable locally.

## Tests

```bash
xcodebuild -project MinimalEditor.xcodeproj -scheme MinimalEditor -destination 'platform=macOS,arch=arm64' test
```

The current test suite covers `.txt` URL enforcement and persisted theme color behavior.

## GitHub Releases

The repository is prepared for GitHub Actions release builds:

- pull requests and branch pushes build the app and upload a ZIP artifact
- version tags like `v0.1.0` build, sign, notarize, and publish a release asset

Required GitHub secrets for signed and notarized tag releases:

- `BUILD_CERTIFICATE_BASE64`
- `P12_PASSWORD`
- `KEYCHAIN_PASSWORD`
- `APPLE_ID`
- `APPLE_APP_SPECIFIC_PASSWORD`
- `APPLE_TEAM_ID`

For local notarization, use:

```bash
./scripts/notarize_local.sh build-universal/output/MinimalEditor.app MinimalEditorNotary
```

## Signing

The release pipeline is configured so:

- Xcode builds are generated without relying on target-level signing
- `scripts/build_universal.sh` signs the final universal app bundle when `SIGNING_IDENTITY` is set
- tag builds in GitHub Actions import the Developer ID certificate, sign the final app, notarize it, and publish the ZIP asset
- hardened runtime is applied on the final signed release build

## Project Layout

- `MinimalEditor/`: app source
- `MinimalEditorTests/`: unit tests
- `project.yml`: XcodeGen project definition
- `scripts/build_universal.sh`: universal release build helper

## License

MIT
