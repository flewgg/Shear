import Foundation

enum ShortcutModifier: String {
    case control
    case command
    case function

    static let storageKey = "CutShortcutMode"
    static let defaultModifier: ShortcutModifier = .control

    init(storedValue: String?) {
        guard let storedValue, let modifier = ShortcutModifier(rawValue: storedValue) else {
            self = ShortcutModifier.defaultModifier
            return
        }
        self = modifier
    }
}
