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
        ShortcutPreferences(
            modeStoredValue: modeStoredValue,
            multipleStoredValue: multipleStoredValue
        ).enabledModifiers
    }

    static func storageValue(for modifiers: Set<ShortcutModifier>) -> String {
        allCases
            .filter { modifiers.contains($0) }
            .map(\.rawValue)
            .joined(separator: ",")
    }
}

struct ShortcutPreferences {
    let modeStoredValue: String?
    let multipleStoredValue: String?

    var mode: ShortcutMode {
        ShortcutMode(storedValue: modeStoredValue)
    }

    var multipleSelection: Set<ShortcutModifier> {
        return ShortcutModifier.modifiers(storedValue: multipleStoredValue)
    }

    var enabledModifiers: Set<ShortcutModifier> {
        switch mode {
        case .control:
            return [.control]
        case .command:
            return [.command]
        case .function:
            return [.function]
        case .multiple:
            if multipleStoredValue == nil && multipleSelection.isEmpty {
                return ShortcutModifier.defaultMultipleModifiers
            }

            return multipleSelection
        }
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

        if storedValue == ShortcutMode.multiple.rawValue {
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
