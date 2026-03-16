import AppKit

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate, NSWindowDelegate {
    private weak var documentState: EditorDocumentState?

    func configure(documentState: EditorDocumentState) {
        self.documentState = documentState
        configureMainWindow()
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureMainWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }

    func windowShouldClose(_ sender: NSWindow) -> Bool {
        guard let documentState else {
            return true
        }

        return documentState.confirmDiscardIfNeeded()
    }

    private func configureMainWindow() {
        guard let window = NSApp.windows.first else {
            return
        }

        window.delegate = self
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.toolbar = nil
        window.contentMinSize = NSSize(width: 240, height: 320)

        if window.frame.size.width < 240 || window.frame.size.height < 320 {
            let nextSize = NSSize(width: max(window.frame.size.width, 240), height: max(window.frame.size.height, 320))
            window.setContentSize(nextSize)
        }
    }
}
