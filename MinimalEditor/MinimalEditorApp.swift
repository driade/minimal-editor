import SwiftUI

@main
struct MinimalEditorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var documentState = EditorDocumentState()
    @StateObject private var themeStore = ThemeStore()

    var body: some Scene {
        Window("MinimalEditor", id: "main") {
            ContentView()
                .environmentObject(documentState)
                .environmentObject(themeStore)
                .frame(minWidth: 240, minHeight: 320)
                .onAppear {
                    appDelegate.configure(documentState: documentState)
                }
        }
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("Nuevo") {
                    documentState.newDocument()
                }
                .keyboardShortcut("n")

                Button("Abrir…") {
                    documentState.openDocument()
                }
                .keyboardShortcut("o")
            }

            CommandGroup(replacing: .saveItem) {
                Button("Guardar") {
                    documentState.saveDocument()
                }
                .keyboardShortcut("s")
                .disabled(!documentState.canSave)

                Button("Guardar como…") {
                    documentState.saveDocumentAs()
                }
                .keyboardShortcut("S", modifiers: [.command, .shift])
            }

            CommandMenu("Texto") {
                Button("Aumentar tamaño") {
                    themeStore.increaseFontSize()
                }
                .keyboardShortcut("=", modifiers: [.command])

                Button("Aumentar tamaño (+)") {
                    themeStore.increaseFontSize()
                }
                .keyboardShortcut("+", modifiers: [.command])

                Button("Reducir tamaño") {
                    themeStore.decreaseFontSize()
                }
                .keyboardShortcut("-", modifiers: [.command])
            }
        }

        Settings {
            SettingsView()
                .environmentObject(themeStore)
        }
    }
}
