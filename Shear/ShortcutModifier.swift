enum ShortcutModifier: String, CaseIterable {
    case control
    case command
    case function

    static let defaultMultipleModifiers = Set(ShortcutModifier.allCases)
    static let multiShortcutDisplayOrder: [ShortcutModifier] = [.control, .function, .command]

    var displayName: String {
        switch self {
        case .control:
            return "Ctrl"
        case .command:
            return "⌘"
        case .function:
            return "Fn"
        }
    }

    init(storedValue: String?) {
        guard let storedValue, let modifier = ShortcutModifier(rawValue: storedValue) else {
            self = .control
            return
        }
        self = modifier
    }

    static func modifiers(storedValue: String?) -> Set<ShortcutModifier> {
        guard let storedValue, !storedValue.isEmpty else {
            return []
        }

        return Set(
            storedValue
                .split(separator: ",")
                .compactMap { ShortcutModifier(rawValue: String($0)) }
        )
    }

    static func enabledModifiers(
        modeStoredValue: String?,
        multipleStoredValue: String?
    ) -> Set<ShortcutModifier> {
        switch ShortcutMode(storedValue: modeStoredValue) {
        case .control:
            return [.control]
        case .command:
            return [.command]
        case .function:
            return [.function]
        case .multiple:
            if modeStoredValue != ShortcutMode.multiple.rawValue {
                let legacyModifiers = modifiers(storedValue: modeStoredValue)
                if !legacyModifiers.isEmpty {
                    return legacyModifiers
                }
            }

            guard multipleStoredValue != nil else {
                return defaultMultipleModifiers
            }

            return modifiers(storedValue: multipleStoredValue)
        }
    }

    static func storageValue(for modifiers: Set<ShortcutModifier>) -> String {
        allCases
            .filter { modifiers.contains($0) }
            .map(\.rawValue)
            .joined(separator: ",")
    }
}

enum ShortcutMode: String, CaseIterable {
    case control
    case command
    case function
    case multiple

    static let defaultMode: ShortcutMode = .control

    var displayName: String {
        switch self {
        case .control:
            return ShortcutModifier.control.displayName
        case .command:
            return ShortcutModifier.command.displayName
        case .function:
            return ShortcutModifier.function.displayName
        case .multiple:
            return "Multiple"
        }
    }

    init(storedValue: String?) {
        guard let storedValue else {
            self = ShortcutMode.defaultMode
            return
        }

        if storedValue == ShortcutMode.multiple.rawValue || storedValue.contains(",") {
            self = .multiple
            return
        }

        guard let modifier = ShortcutModifier(rawValue: storedValue),
              let mode = ShortcutMode(modifier: modifier) else {
            self = ShortcutMode.defaultMode
            return
        }

        self = mode
    }

    private init?(modifier: ShortcutModifier) {
        switch modifier {
        case .control:
            self = .control
        case .command:
            self = .command
        case .function:
            self = .function
        }
    }
}
