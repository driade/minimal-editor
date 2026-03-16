import AppKit
import SwiftUI

struct EditorTheme: Equatable {
    var background: StoredColor
    var text: StoredColor
    var fontFamily: String
    var fontSize: Double

    static let `default` = EditorTheme(
        background: StoredColor(hex: "#000000"),
        text: StoredColor(hex: "#F5F5F5"),
        fontFamily: "Menlo",
        fontSize: 15
    )

    var editorFont: NSFont {
        NSFont.editorFont(family: fontFamily, size: fontSize)
    }
}

struct StoredColor: Equatable {
    let hex: String

    var nsColor: NSColor {
        NSColor.fromHex(hex) ?? .black
    }

    var swiftUIColor: Color {
        Color(nsColor: nsColor)
    }
}

@MainActor
final class ThemeStore: ObservableObject {
    @Published private(set) var theme: EditorTheme

    private let defaults: UserDefaults
    private let backgroundKey = "theme.backgroundHex"
    private let textKey = "theme.textHex"
    private let fontFamilyKey = "theme.fontFamily"
    private let fontSizeKey = "theme.fontSize"

    static let minimumFontSize = 10.0
    static let maximumFontSize = 42.0
    static let fontStep = 1.0

    static let availableFontFamilies: [String] = {
        NSFontManager.shared.availableFontFamilies.sorted()
    }()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        let backgroundHex = defaults.string(forKey: backgroundKey) ?? EditorTheme.default.background.hex
        let textHex = defaults.string(forKey: textKey) ?? EditorTheme.default.text.hex
        let storedFontFamily = defaults.string(forKey: fontFamilyKey) ?? EditorTheme.default.fontFamily
        let fontFamily = Self.availableFontFamilies.contains(storedFontFamily) ? storedFontFamily : EditorTheme.default.fontFamily
        let rawFontSize = defaults.object(forKey: fontSizeKey) as? Double ?? EditorTheme.default.fontSize

        self.theme = EditorTheme(
            background: StoredColor(hex: backgroundHex),
            text: StoredColor(hex: textHex),
            fontFamily: fontFamily,
            fontSize: Self.clampedFontSize(rawFontSize)
        )
    }

    func updateBackground(with color: Color) {
        update(background: StoredColor(hex: nativeColor(from: color).hexString))
    }

    func updateText(with color: Color) {
        update(text: StoredColor(hex: nativeColor(from: color).hexString))
    }

    func updateFontFamily(_ family: String) {
        guard Self.availableFontFamilies.contains(family) else {
            return
        }

        update(fontFamily: family)
    }

    func updateFontSize(_ size: Double) {
        update(fontSize: Self.clampedFontSize(size))
    }

    func increaseFontSize() {
        updateFontSize(theme.fontSize + Self.fontStep)
    }

    func decreaseFontSize() {
        updateFontSize(theme.fontSize - Self.fontStep)
    }

    private func update(
        background: StoredColor? = nil,
        text: StoredColor? = nil,
        fontFamily: String? = nil,
        fontSize: Double? = nil
    ) {
        let nextTheme = EditorTheme(
            background: background ?? theme.background,
            text: text ?? theme.text,
            fontFamily: fontFamily ?? theme.fontFamily,
            fontSize: fontSize ?? theme.fontSize
        )

        theme = nextTheme
        defaults.set(nextTheme.background.hex, forKey: backgroundKey)
        defaults.set(nextTheme.text.hex, forKey: textKey)
        defaults.set(nextTheme.fontFamily, forKey: fontFamilyKey)
        defaults.set(nextTheme.fontSize, forKey: fontSizeKey)
    }

    private func nativeColor(from color: Color) -> NSColor {
        NSColor(color)
    }

    private static func clampedFontSize(_ size: Double) -> Double {
        min(max(size, minimumFontSize), maximumFontSize)
    }
}

extension NSFont {
    static func editorFont(family: String, size: Double) -> NSFont {
        NSFont(name: family, size: size) ?? NSFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

extension NSColor {
    var hexString: String {
        let rgb = usingColorSpace(.deviceRGB) ?? self
        let red = Int(round(rgb.redComponent * 255))
        let green = Int(round(rgb.greenComponent * 255))
        let blue = Int(round(rgb.blueComponent * 255))
        return String(format: "#%02X%02X%02X", red, green, blue)
    }

    static func fromHex(_ hex: String) -> NSColor? {
        let trimmed = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard trimmed.count == 6, let value = Int(trimmed, radix: 16) else {
            return nil
        }

        let red = CGFloat((value >> 16) & 0xFF) / 255
        let green = CGFloat((value >> 8) & 0xFF) / 255
        let blue = CGFloat(value & 0xFF) / 255
        return NSColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
