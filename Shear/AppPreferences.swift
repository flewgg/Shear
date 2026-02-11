import Foundation

enum ShortcutModifier: String, CaseIterable {
    case control
    case command
    case function

    static let storageKey = "CutShortcutMode"
    static let defaultModifier: ShortcutModifier = .control

    var displayName: String {
        switch self {
        case .control:
            return "Control (^)"
        case .command:
            return "Command (⌘)"
        case .function:
            return "Fn / Globe (􀆪)"
        }
    }

    init(storedValue: String?) {
        guard let storedValue, let modifier = ShortcutModifier(rawValue: storedValue) else {
            self = ShortcutModifier.defaultModifier
            return
        }
        self = modifier
    }
}

enum AppWindowID {
    static let settings = "settings"
    static let info = "info"
}

enum AppDefaultsKey {
    static let hideDockIcon = "HideDockIcon"
}
