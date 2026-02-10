import Foundation

enum ShortcutModifier: String {
    case control
    case command
    case function

    static let storageKey = "CutShortcutMode"
    static let defaultModifier: ShortcutModifier = .control

    init(storedValue: String?) {
        self = ShortcutModifier(rawValue: storedValue ?? "") ?? ShortcutModifier.defaultModifier
    }
}
