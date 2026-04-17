import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(ShortcutModifier.storageKey) private var shortcutModeRawValue = ShortcutMode.defaultMode.rawValue
    @AppStorage(ShortcutModifier.multipleStorageKey) private var multipleShortcutRawValue = ShortcutModifier.storageValue(
        for: ShortcutModifier.defaultMultipleModifiers
    )
    @State private var launchAtLogin = false
    @State private var hideDockIcon = false
    @State private var permissions = AppDelegate.PermissionState(
        inputMonitoringGranted: false,
        postEventAccessGranted: false
    )

    private let appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    var body: some View {
        Form {
            Section {
                Toggle("Hide Dock Icon", isOn: hideDockIconBinding)
                Toggle("Launch at Startup", isOn: launchAtLoginBinding)
            }

            Section {
                HStack {
                    Text("Modifier Key")
                    Spacer()
                    Picker("Modifier Key", selection: shortcutModeBinding) {
                        ForEach(ShortcutMode.allCases, id: \.self) { mode in
                            Text(mode.displayName).tag(mode)
                        }
                    }
                    .labelsHidden()
                    .pickerStyle(.segmented)
                }

                if shortcutMode == .multiple {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accepted Keys")
                            Text("Choose one or more modifiers that should trigger Shear.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        HStack(spacing: 12) {
                            ForEach(ShortcutModifier.multiShortcutDisplayOrder, id: \.self) { modifier in
                                Toggle(modifier.shortDisplayName, isOn: shortcutModifierBinding(for: modifier))
                                    .toggleStyle(.checkbox)
                            }
                        }
                    }
                }
            } header: {
                Text("Behaviour")
            }

            Section {
                permissionRow(
                    title: "Accessibility",
                    subtitle: "Lets Shear send Finder's move-paste shortcut (Option+Command+V) after you trigger cut. Manage in [Accessibility settings...](\(accessibilityURL.absoluteString))",
                    granted: accessibilityGranted
                )

                permissionRow(
                    title: "Input Monitoring",
                    subtitle: "Lets Shear detect your selected shortcut while Finder is active. Manage in [Input Monitoring settings...](\(inputMonitoringURL.absoluteString))",
                    granted: inputMonitoringGranted
                )
            } header: {
                Text("Permissions")
            } footer: {
                HStack {
                    Spacer()
                    Button("Refresh", action: refreshPermissions)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: refreshFromSystem)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshPermissions()
            }
        }
    }

    private var shortcutMode: ShortcutMode {
        ShortcutMode(storedValue: shortcutModeRawValue)
    }

    private var shortcutModeBinding: Binding<ShortcutMode> {
        Binding(
            get: { shortcutMode },
            set: { shortcutModeRawValue = $0.rawValue }
        )
    }

    private var multipleShortcutModifiers: Set<ShortcutModifier> {
        if shortcutMode == .multiple && shortcutModeRawValue != ShortcutMode.multiple.rawValue {
            let legacyModifiers = ShortcutModifier.modifiers(storedValue: shortcutModeRawValue)
            if !legacyModifiers.isEmpty {
                return legacyModifiers
            }
        }

        return ShortcutModifier.modifiers(storedValue: multipleShortcutRawValue)
    }

    private func shortcutModifierBinding(for modifier: ShortcutModifier) -> Binding<Bool> {
        Binding(
            get: {
                multipleShortcutModifiers.contains(modifier)
            },
            set: { isEnabled in
                var modifiers = multipleShortcutModifiers
                if isEnabled {
                    modifiers.insert(modifier)
                } else {
                    modifiers.remove(modifier)
                }
                multipleShortcutRawValue = ShortcutModifier.storageValue(for: modifiers)
                shortcutModeRawValue = ShortcutMode.multiple.rawValue
            }
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { enabled in
                _ = appDelegate.setLaunchAtLogin(enabled)
                launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
            }
        )
    }

    private var hideDockIconBinding: Binding<Bool> {
        Binding(
            get: { hideDockIcon },
            set: { hidden in
                appDelegate.setDockIconHidden(hidden)
                hideDockIcon = appDelegate.isDockIconHidden()
            }
        )
    }

    private var accessibilityURL: URL {
        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
    }

    private var inputMonitoringURL: URL {
        URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
    }

    private var accessibilityGranted: Bool {
        permissions.postEventAccessGranted
    }

    private var inputMonitoringGranted: Bool {
        permissions.inputMonitoringGranted
    }

    private func refreshFromSystem() {
        launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
        hideDockIcon = appDelegate.isDockIconHidden()
        permissions = appDelegate.permissionState()
    }

    private func refreshPermissions() {
        appDelegate.refreshPermissionState()
        refreshFromSystem()
    }

    private func permissionRow(title: String, subtitle: String, granted: Bool) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)

                Text(.init(subtitle))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Text(granted ? "Granted" : "Not Granted")
                .foregroundStyle(Color(nsColor: granted ? .systemGreen : .systemRed))
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

#Preview {
    GeneralSettingsView(appDelegate: AppDelegate())
}
