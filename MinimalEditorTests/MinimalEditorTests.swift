import AppKit
import Foundation
import XCTest
@testable import MinimalEditor

@MainActor
final class MinimalEditorTests: XCTestCase {
    func testEnforcedTXTURLAddsExtensionWhenMissing() {
        let input = URL(fileURLWithPath: "/tmp/demo")
        let output = EditorDocumentState.enforcedTXTURL(for: input)

        XCTAssertEqual(output.pathExtension, "txt")
        XCTAssertEqual(output.lastPathComponent, "demo.txt")
    }

    func testEnforcedTXTURLReplacesWrongExtension() {
        let input = URL(fileURLWithPath: "/tmp/demo.rtf")
        let output = EditorDocumentState.enforcedTXTURL(for: input)

        XCTAssertEqual(output.lastPathComponent, "demo.txt")
    }

    func testHexColorRoundTrip() {
        let color = NSColor(red: 0.12, green: 0.34, blue: 0.56, alpha: 1)
        let rebuilt = NSColor.fromHex(color.hexString)

        XCTAssertNotNil(rebuilt)
        XCTAssertEqual(rebuilt?.hexString, color.hexString)
    }

    func testThemeStoreReadsPersistedValues() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        defaults.set("#111111", forKey: "theme.backgroundHex")
        defaults.set("#EEEEEE", forKey: "theme.textHex")
        let expectedFontFamily = ThemeStore.availableFontFamilies.first ?? EditorTheme.default.fontFamily
        defaults.set(expectedFontFamily, forKey: "theme.fontFamily")
        defaults.set(19.0, forKey: "theme.fontSize")

        let store = ThemeStore(defaults: defaults)

        XCTAssertEqual(store.theme.background.hex, "#111111")
        XCTAssertEqual(store.theme.text.hex, "#EEEEEE")
        XCTAssertEqual(store.theme.fontFamily, expectedFontFamily)
        XCTAssertEqual(store.theme.fontSize, 19.0)
    }

    func testThemeStoreClampsFontSize() {
        let defaults = UserDefaults(suiteName: #function)!
        defaults.removePersistentDomain(forName: #function)
        let store = ThemeStore(defaults: defaults)

        store.updateFontSize(500)
        XCTAssertEqual(store.theme.fontSize, ThemeStore.maximumFontSize)

        store.updateFontSize(1)
        XCTAssertEqual(store.theme.fontSize, ThemeStore.minimumFontSize)
    }

    func testCaskHasNoMergeConflictMarkers() throws {
        let cask = try loadCaskFile()

        XCTAssertFalse(cask.contains("<<<<<<<"))
        XCTAssertFalse(cask.contains("======="))
        XCTAssertFalse(cask.contains(">>>>>>>"))
    }

    func testCaskHasValidVersionAndSHA() throws {
        let cask = try loadCaskFile()

        let version = try XCTUnwrap(firstMatch(in: cask, pattern: #"version "([0-9]+\.[0-9]+\.[0-9]+)""#))
        let sha = try XCTUnwrap(firstMatch(in: cask, pattern: #"sha256 "([0-9a-f]{64})""#))

        XCTAssertFalse(version.isEmpty)
        XCTAssertEqual(sha.count, 64)
    }

    func testTaggedCommitUsesMatchingCaskVersion() throws {
        guard let tag = exactTagForHead() else {
            return
        }

        let cask = try loadCaskFile()
        let version = try XCTUnwrap(firstMatch(in: cask, pattern: #"version "([0-9]+\.[0-9]+\.[0-9]+)""#))

        XCTAssertEqual(version, tag.replacingOccurrences(of: "v", with: ""))
    }

    private func loadCaskFile() throws -> String {
        let testsFileURL = URL(fileURLWithPath: #filePath)
        let repoRoot = testsFileURL.deletingLastPathComponent().deletingLastPathComponent()
        let caskURL = repoRoot.appendingPathComponent("Casks/minimaleditor.rb")
        return try String(contentsOf: caskURL, encoding: .utf8)
    }

    private func firstMatch(in text: String, pattern: String) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return nil
        }

        let range = NSRange(text.startIndex..., in: text)
        guard let match = regex.firstMatch(in: text, range: range),
              match.numberOfRanges > 1,
              let captureRange = Range(match.range(at: 1), in: text) else {
            return nil
        }

        return String(text[captureRange])
    }

    private func exactTagForHead() -> String? {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["git", "describe", "--tags", "--exact-match", "HEAD"]

        let testsFileURL = URL(fileURLWithPath: #filePath)
        process.currentDirectoryURL = testsFileURL.deletingLastPathComponent().deletingLastPathComponent()

        let outputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
        } catch {
            return nil
        }

        guard process.terminationStatus == 0 else {
            return nil
        }

        let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
        return String(data: data, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
