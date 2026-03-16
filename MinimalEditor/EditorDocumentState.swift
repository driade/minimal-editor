import AppKit
import SwiftUI
import UniformTypeIdentifiers

@MainActor
final class EditorDocumentState: ObservableObject {
    @Published var text = "" {
        didSet {
            guard text != lastSavedText else {
                isDirty = false
                return
            }

            isDirty = true
        }
    }

    @Published private(set) var fileURL: URL?
    @Published private(set) var isDirty = false

    private var lastSavedText = ""

    var displayName: String {
        fileURL?.lastPathComponent ?? "Sin título.txt"
    }

    var canSave: Bool {
        isDirty || fileURL != nil
    }

    func newDocument() {
        guard confirmDiscardIfNeeded() else {
            return
        }

        text = ""
        lastSavedText = ""
        fileURL = nil
        isDirty = false
    }

    func openDocument() {
        guard confirmDiscardIfNeeded() else {
            return
        }

        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.plainText]
        panel.allowsMultipleSelection = false
        panel.canChooseDirectories = false
        panel.canCreateDirectories = false

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return
        }

        do {
            let loadedText = try Self.readText(from: selectedURL)
            text = loadedText
            lastSavedText = loadedText
            fileURL = selectedURL
            isDirty = false
        } catch {
            presentErrorAlert(message: "No se pudo abrir el archivo TXT.", error: error)
        }
    }

    func saveDocument() {
        guard let fileURL else {
            saveDocumentAs()
            return
        }

        save(to: fileURL)
    }

    func saveDocumentAs() {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [.plainText]
        panel.canCreateDirectories = true
        panel.isExtensionHidden = false
        panel.nameFieldStringValue = Self.enforcedTXTURL(for: fileURL ?? URL(fileURLWithPath: "Sin título.txt")).lastPathComponent

        guard panel.runModal() == .OK, let selectedURL = panel.url else {
            return
        }

        save(to: Self.enforcedTXTURL(for: selectedURL))
    }

    func confirmDiscardIfNeeded() -> Bool {
        guard isDirty else {
            return true
        }

        let alert = NSAlert()
        alert.messageText = "Hay cambios sin guardar."
        alert.informativeText = "Si continúas, perderás los cambios del documento actual."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Guardar")
        alert.addButton(withTitle: "Descartar")
        alert.addButton(withTitle: "Cancelar")

        switch alert.runModal() {
        case .alertFirstButtonReturn:
            saveDocument()
            return !isDirty
        case .alertSecondButtonReturn:
            return true
        default:
            return false
        }
    }

    private func save(to url: URL) {
        let targetURL = Self.enforcedTXTURL(for: url)

        do {
            try Self.writeText(text, to: targetURL)
            fileURL = targetURL
            lastSavedText = text
            isDirty = false
        } catch {
            presentErrorAlert(message: "No se pudo guardar el archivo TXT.", error: error)
        }
    }

    private func presentErrorAlert(message: String, error: Error) {
        let alert = NSAlert(error: error)
        alert.messageText = message
        alert.runModal()
    }

    static func enforcedTXTURL(for url: URL) -> URL {
        if url.pathExtension.lowercased() == "txt" {
            return url
        }

        return url.deletingPathExtension().appendingPathExtension("txt")
    }

    static func readText(from url: URL) throws -> String {
        let data = try Data(contentsOf: url)
        if let utf8 = String(data: data, encoding: .utf8) {
            return utf8
        }
        if let unicode = String(data: data, encoding: .unicode) {
            return unicode
        }
        if let latin1 = String(data: data, encoding: .isoLatin1) {
            return latin1
        }

        throw CocoaError(.fileReadInapplicableStringEncoding)
    }

    static func writeText(_ text: String, to url: URL) throws {
        try text.write(to: url, atomically: true, encoding: .utf8)
    }
}
