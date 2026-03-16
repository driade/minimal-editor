import AppKit
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
        defaults.set("Courier", forKey: "theme.fontFamily")
        defaults.set(19.0, forKey: "theme.fontSize")

        let store = ThemeStore(defaults: defaults)

        XCTAssertEqual(store.theme.background.hex, "#111111")
        XCTAssertEqual(store.theme.text.hex, "#EEEEEE")
        XCTAssertEqual(store.theme.fontFamily, "Courier")
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
}
