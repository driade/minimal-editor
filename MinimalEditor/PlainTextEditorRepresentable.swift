import AppKit
import SwiftUI

struct PlainTextEditorRepresentable: NSViewRepresentable {
    @Binding var text: String
    let theme: EditorTheme

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.borderType = .noBorder
        scrollView.drawsBackground = false
        scrollView.automaticallyAdjustsContentInsets = false

        let textStorage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)

        let textContainer = NSTextContainer(containerSize: NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        textContainer.widthTracksTextView = true
        textContainer.lineFragmentPadding = 0
        layoutManager.addTextContainer(textContainer)

        let textView = PlainTextView(frame: .zero, textContainer: textContainer)
        textView.delegate = context.coordinator
        textView.minSize = NSSize.zero
        textView.maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        textView.isVerticallyResizable = true
        textView.isHorizontallyResizable = false
        textView.autoresizingMask = [NSView.AutoresizingMask.width]
        textView.textContainerInset = NSSize(width: 18, height: 18)
        textView.font = theme.editorFont
        textView.string = text
        configure(textView: textView, theme: theme)

        scrollView.documentView = textView

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }

        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? PlainTextView else {
            return
        }

        if textView.string != text {
            textView.string = text
        }

        configure(textView: textView, theme: theme)

        DispatchQueue.main.async {
            if textView.window?.firstResponder == nil {
                textView.window?.makeFirstResponder(textView)
            }
        }
    }

    private func configure(textView: PlainTextView, theme: EditorTheme) {
        let font = theme.editorFont
        textView.font = font
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: theme.text.nsColor
        ]

        textView.drawsBackground = true
        textView.backgroundColor = theme.background.nsColor
        textView.insertionPointColor = theme.text.nsColor
        textView.textColor = theme.text.nsColor
        textView.typingAttributes = attributes
        textView.selectedTextAttributes = [
            .backgroundColor: theme.text.nsColor.withAlphaComponent(0.25),
            .foregroundColor: theme.background.nsColor
        ]

        if let textStorage = textView.textStorage, textStorage.length > 0 {
            let selectedRange = textView.selectedRange()
            textStorage.beginEditing()
            textStorage.setAttributes(attributes, range: NSRange(location: 0, length: textStorage.length))
            textStorage.endEditing()
            textView.setSelectedRange(selectedRange)
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding private var text: String

        init(text: Binding<String>) {
            self._text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else {
                return
            }

            text = textView.string
        }
    }
}

final class PlainTextView: NSTextView {
    override var acceptsFirstResponder: Bool { true }

    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
        configure()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configure()
    }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.window?.makeFirstResponder(self)
        }
    }

    override func paste(_ sender: Any?) {
        if let string = NSPasteboard.general.string(forType: .string) {
            insertText(string, replacementRange: selectedRange())
        }
    }

    private func configure() {
        isRichText = false
        importsGraphics = false
        isEditable = true
        isSelectable = true
        isFieldEditor = false
        allowsUndo = true
        usesFindBar = false
        usesInspectorBar = false
        usesFontPanel = false
        usesRuler = false
        isAutomaticDataDetectionEnabled = false
        isAutomaticLinkDetectionEnabled = false
        isAutomaticQuoteSubstitutionEnabled = false
        isAutomaticDashSubstitutionEnabled = false
        isAutomaticTextReplacementEnabled = false
        isContinuousSpellCheckingEnabled = false
        smartInsertDeleteEnabled = false
        textContainer?.lineFragmentPadding = 0
    }
}
