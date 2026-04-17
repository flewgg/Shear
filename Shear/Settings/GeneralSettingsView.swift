import Defaults
import SwiftUI

struct GeneralSettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Default(.shortcutModeRawValue) private var shortcutModeRawValue
    @Default(.multipleShortcutRawValue) private var multipleShortcutRawValue
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
                                Toggle(modifier.displayName, isOn: shortcutModifierBinding(for: modifier))
                                    .toggleStyle(.checkbox)
                            }
                        }
                    }
                }
            } header: {
                Text("Behaviour")
            }

            Section {
                ForEach([AppPermission.postEvents, .inputMonitoring], id: \.self) { permission in
                    permissionRow(for: permission)
                }
            } header: {
                Text("Permissions")
            } footer: {
                HStack {
                    Spacer()
                    Button("Refresh", action: refreshFromSystem)
                }
            }
        }
        .formStyle(.grouped)
        .onAppear(perform: refreshFromSystem)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshFromSystem()
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

    private func refreshFromSystem() {
        launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
        hideDockIcon = appDelegate.isDockIconHidden()
        permissions = appDelegate.refreshPermissionState()
    }

    private func permissionRow(for permission: AppPermission) -> some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(permission.title)

                Text(.init(permission.settingsDescription))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .layoutPriority(1)

            Text(permission.isGranted(in: permissions) ? "Granted" : "Not Granted")
                .foregroundStyle(
                    Color(
                        nsColor: permission.isGranted(in: permissions) ? .systemGreen : .systemRed
                    )
                )
                .lineLimit(1)
                .fixedSize(horizontal: true, vertical: false)
        }
    }
}

#Preview {
    GeneralSettingsView(appDelegate: AppDelegate())
}
