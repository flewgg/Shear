import SwiftUI

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    let appDelegate: AppDelegate
    @AppStorage(ShortcutModifier.storageKey) private var shortcutMode = ShortcutModifier.defaultModifier.rawValue
    @State private var launchAtLogin = false
    @State private var hideDockIcon = false
    @State private var inputMonitoringGranted = false
    @State private var accessibilityGranted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Modifier Key")
                Spacer()
                Picker("Modifier Key", selection: shortcutModeBinding) {
                    Text("Control (^)").tag(ShortcutModifier.control.rawValue)
                    Text("Command (⌘)").tag(ShortcutModifier.command.rawValue)
                    Text("Fn / Globe (􀆪)").tag(ShortcutModifier.function.rawValue)
                }
                .labelsHidden()
                .pickerStyle(.menu)
                .frame(width: 170)
            }

            Toggle("Hide Dock Icon", isOn: dockIconToggleBinding)
            Toggle("Launch at Startup", isOn: launchAtLoginToggleBinding)

            if ShortcutModifier(storedValue: shortcutMode) == .command {
                Text("Command mode may override Finder text cut behavior.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            permissionRow(
                title: "Accessibility",
                granted: accessibilityGranted,
                details: "Needed to post synthetic key events for move (Option+Command+V)."
            ) {
                appDelegate.openAccessibilitySettings()
            }

            permissionRow(
                title: "Input Monitoring",
                granted: inputMonitoringGranted,
                details: "Needed to detect your selected shortcut globally while Finder is active."
            ) {
                appDelegate.openInputMonitoringSettings()
            }
        }
        .padding(18)
        .frame(minWidth: 440)
        .onAppear(perform: refreshFromSystem)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { refreshFromSystem() }
        }
    }

    private var shortcutModeBinding: Binding<String> {
        Binding(
            get: {
                ShortcutModifier(storedValue: shortcutMode).rawValue
            },
            set: { newValue in
                shortcutMode = ShortcutModifier(storedValue: newValue).rawValue
            }
        )
    }

    private var launchAtLoginToggleBinding: Binding<Bool> {
        Binding(
            get: { launchAtLogin },
            set: { desiredState in
                let success = appDelegate.setLaunchAtLogin(desiredState)
                launchAtLogin = success ? desiredState : appDelegate.isLaunchAtLoginEnabled()
            }
        )
    }

    private var dockIconToggleBinding: Binding<Bool> {
        Binding(
            get: { hideDockIcon },
            set: { hidden in
                hideDockIcon = hidden
                appDelegate.setDockIconHidden(hideDockIcon)
            }
        )
    }

    @ViewBuilder
    private func permissionRow(
        title: String,
        granted: Bool,
        details: String,
        action: @escaping () -> Void
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(granted ? Color.green : Color.orange)
            Text(title)
            Text(granted ? "Granted" : "Missing")
                .foregroundStyle(.secondary)
            Button {
                showPermissionInfo(details)
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Spacer()
            Button("Open Settings...", action: action)
        }
    }

    private func showPermissionInfo(_ details: String) {
        let alert = NSAlert()
        alert.messageText = "Why this permission is needed"
        alert.informativeText = details
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    private func refreshFromSystem() {
        launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
        hideDockIcon = appDelegate.isDockIconHidden()
        inputMonitoringGranted = appDelegate.hasInputMonitoringAccess()
        accessibilityGranted = appDelegate.hasAccessibilityAccess()
    }
}
