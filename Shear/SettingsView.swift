import SwiftUI

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    let appDelegate: AppDelegate
    @AppStorage(ShortcutModifier.storageKey) private var shortcutMode = ShortcutModifier.defaultModifier.rawValue
    @State private var launchAtLogin = false
    @State private var hideDockIcon = false
    @State private var inputMonitoringGranted = false
    @State private var postEventAccessGranted = false

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Modifier Key")
                Spacer()
                Picker("Modifier Key", selection: shortcutModeBinding) {
                    ForEach(ShortcutModifier.allCases, id: \.self) { modifier in
                        Text(modifier.displayName).tag(modifier)
                    }
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
                title: "Accessibility (Post Events)",
                granted: postEventAccessGranted,
                details: "Needed to synthesize Option+Command+V for Finder move-paste."
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

    private var shortcutModeBinding: Binding<ShortcutModifier> {
        Binding(
            get: {
                ShortcutModifier(storedValue: shortcutMode)
            },
            set: { modifier in
                shortcutMode = modifier.rawValue
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
                appDelegate.setDockIconHidden(hidden)
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
        postEventAccessGranted = appDelegate.hasAccessibilityAccess()
    }
}
