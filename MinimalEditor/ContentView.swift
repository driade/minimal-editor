import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var documentState: EditorDocumentState
    @EnvironmentObject private var themeStore: ThemeStore

    var body: some View {
        VStack(spacing: 0) {
            EditorTopBar(title: documentState.displayName)

            PlainTextEditorRepresentable(
                text: $documentState.text,
                theme: themeStore.theme
            )
            .background(themeStore.theme.background.swiftUIColor)
        }
        .background(themeStore.theme.background.swiftUIColor)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .ignoresSafeArea(.container, edges: .top)
    }
}

private struct EditorTopBar: View {
    let title: String

    private let barColor = Color(nsColor: NSColor(calibratedRed: 0.42, green: 0.40, blue: 0.39, alpha: 1))
    private let dividerColor = Color.white.opacity(0.10)

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            TopOnlyRoundedRectangle(radius: 12)
                .fill(barColor)

            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.white.opacity(0.92))
                .lineLimit(1)
                .truncationMode(.middle)
                .padding(.horizontal, 16)
                .padding(.bottom, 8)

            Rectangle()
                .fill(dividerColor)
                .frame(height: 1)
        }
        .frame(height: 58)
    }
}

private struct TopOnlyRoundedRectangle: Shape {
    var radius: CGFloat = 12

    func path(in rect: CGRect) -> Path {
        let radius = min(radius, rect.width / 2, rect.height)
        var path = Path()

        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + radius))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + radius, y: rect.minY),
            control: CGPoint(x: rect.minX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.maxX, y: rect.minY + radius),
            control: CGPoint(x: rect.maxX, y: rect.minY)
        )
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()

        return path
    }
}

#Preview {
    ContentView()
        .environmentObject(EditorDocumentState())
        .environmentObject(ThemeStore())
}
