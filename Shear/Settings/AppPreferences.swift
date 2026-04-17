import Defaults

extension Defaults.Keys {
    static let shortcutModeRawValue = Key<String>(
        "CutShortcutMode",
        default: ShortcutMode.defaultMode.rawValue
    )

    static let multipleShortcutRawValue = Key<String>(
        "CutShortcutModes",
        default: ShortcutModifier.storageValue(for: ShortcutModifier.defaultMultipleModifiers)
    )

    static let hideDockIcon = Key<Bool>("HideDockIcon", default: false)
    static let hasShownPermissionsOnboarding = Key<Bool>("HasShownPermissionsOnboarding", default: false)
}
