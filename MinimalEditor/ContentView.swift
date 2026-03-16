import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var documentState: EditorDocumentState
    @EnvironmentObject private var themeStore: ThemeStore

    var body: some View {
        PlainTextEditorRepresentable(
            text: $documentState.text,
            theme: themeStore.theme
        )
        .background(themeStore.theme.background.swiftUIColor)
    }
}

#Preview {
    ContentView()
        .environmentObject(EditorDocumentState())
        .environmentObject(ThemeStore())
}
