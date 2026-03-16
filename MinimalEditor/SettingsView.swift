import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var themeStore: ThemeStore

    var body: some View {
        Form {
            ColorPicker(
                "Color de fondo",
                selection: Binding(
                    get: { themeStore.theme.background.swiftUIColor },
                    set: { themeStore.updateBackground(with: $0) }
                ),
                supportsOpacity: false
            )

            ColorPicker(
                "Color del texto",
                selection: Binding(
                    get: { themeStore.theme.text.swiftUIColor },
                    set: { themeStore.updateText(with: $0) }
                ),
                supportsOpacity: false
            )

            Picker(
                "Fuente",
                selection: Binding(
                    get: { themeStore.theme.fontFamily },
                    set: { themeStore.updateFontFamily($0) }
                )
            ) {
                ForEach(ThemeStore.availableFontFamilies, id: \.self) { family in
                    Text(family).tag(family)
                }
            }

            HStack {
                Text("Tamaño")
                Spacer()
                Stepper(value: Binding(
                    get: { themeStore.theme.fontSize },
                    set: { themeStore.updateFontSize($0) }
                ), in: ThemeStore.minimumFontSize...ThemeStore.maximumFontSize, step: ThemeStore.fontStep) {
                    Text("\(Int(themeStore.theme.fontSize)) pt")
                        .monospacedDigit()
                }
            }

            RoundedRectangle(cornerRadius: 14)
                .fill(themeStore.theme.background.swiftUIColor)
                .frame(height: 180)
                .overlay(alignment: .center) {
                    VStack(spacing: 12) {
                        Text("MinimalEditor")
                            .font(Font(themeStore.theme.editorFont))
                        Text("The quick brown fox jumps over the lazy dog")
                            .font(Font(themeStore.theme.editorFont))
                    }
                    .foregroundStyle(themeStore.theme.text.swiftUIColor)
                    .padding(20)
                }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(width: 460)
    }
}

#Preview {
    SettingsView()
        .environmentObject(ThemeStore())
}
