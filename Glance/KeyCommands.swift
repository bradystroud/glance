import SwiftUI
import UIKit

/// Captures hardware arrow keys on iPad via UIKeyCommand.
/// `.keyboardShortcut` doesn't reliably get *plain* arrow keys — the focus engine
/// eats them first — so we go through UIKit and claim priority over system behavior.
struct KeyCommands: UIViewRepresentable {
    var onLeft: () -> Void
    var onRight: () -> Void
    var onUp: () -> Void
    var onDown: () -> Void

    func makeUIView(context: Context) -> KeyCommandView {
        let view = KeyCommandView()
        view.apply(self)
        return view
    }

    func updateUIView(_ uiView: KeyCommandView, context: Context) {
        uiView.apply(self)
    }
}

final class KeyCommandView: UIView {
    private var handlers = KeyCommands(onLeft: {}, onRight: {}, onUp: {}, onDown: {})

    func apply(_ commands: KeyCommands) { handlers = commands }

    override var canBecomeFirstResponder: Bool { true }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        becomeFirstResponder()
    }

    override var keyCommands: [UIKeyCommand]? {
        let commands = [
            UIKeyCommand(input: UIKeyCommand.inputLeftArrow,  modifierFlags: [], action: #selector(left)),
            UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: [], action: #selector(right)),
            UIKeyCommand(input: UIKeyCommand.inputUpArrow,    modifierFlags: [], action: #selector(up)),
            UIKeyCommand(input: UIKeyCommand.inputDownArrow,  modifierFlags: [], action: #selector(down)),
        ]
        commands.forEach { $0.wantsPriorityOverSystemBehavior = true }
        return commands
    }

    @objc private func left()  { handlers.onLeft() }
    @objc private func right() { handlers.onRight() }
    @objc private func up()    { handlers.onUp() }
    @objc private func down()  { handlers.onDown() }
}
