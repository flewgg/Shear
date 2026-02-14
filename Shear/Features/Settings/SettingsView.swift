import SwiftUI

struct SettingsView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(ShortcutModifier.storageKey) private var shortcutModeRawValue = ShortcutModifier.defaultModifier.rawValue
    @StateObject private var viewModel: SettingsViewModel
    @State private var permissionInfo: PermissionInfo?

    init(appDelegate: AppDelegate) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(appDelegate: appDelegate))
    }

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

            Toggle("Hide Dock Icon", isOn: hideDockIconBinding)
            Toggle("Launch at Startup", isOn: launchAtLoginBinding)

            if viewModel.canCheckForUpdates {
                HStack {
                    Spacer()
                    Button("Check for Updates...") {
                        viewModel.checkForUpdates()
                    }
                }
            }

            if ShortcutModifier(storedValue: shortcutModeRawValue) == .command {
                Text("Command mode may override text cut behavior in rename fields.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            ForEach(AppPermission.allCases, id: \.self) { permission in
                permissionRow(permission)
            }

            HStack {
                Spacer()
                Button("Refresh Permission Status") {
                    viewModel.refreshPermissions()
                }
            }
        }
        .padding(18)
        .frame(minWidth: 440)
        .onAppear(perform: viewModel.refreshPermissions)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active { viewModel.refreshPermissions() }
        }
        .alert(item: $permissionInfo) { info in
            Alert(
                title: Text("Why this permission is needed"),
                message: Text(info.details),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var shortcutModeBinding: Binding<ShortcutModifier> {
        rawValueBinding(
            rawValue: $shortcutModeRawValue,
            defaultValue: ShortcutModifier.defaultModifier
        )
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { viewModel.launchAtLogin },
            set: { viewModel.setLaunchAtLogin($0) }
        )
    }

    private var hideDockIconBinding: Binding<Bool> {
        Binding(
            get: { viewModel.hideDockIcon },
            set: { viewModel.setHideDockIcon($0) }
        )
    }

    private func rawValueBinding<Value: RawRepresentable>(
        rawValue: Binding<String>,
        defaultValue: Value
    ) -> Binding<Value> where Value.RawValue == String {
        Binding(
            get: { Value(rawValue: rawValue.wrappedValue) ?? defaultValue },
            set: { rawValue.wrappedValue = $0.rawValue }
        )
    }

    private func permissionRow(_ permission: AppPermission) -> some View {
        let granted = permission.isGranted(in: viewModel.permissions)
        return HStack(spacing: 8) {
            Image(systemName: granted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(granted ? Color.green : Color.orange)
            Text(permission.title)
            Text(granted ? "Granted" : "Missing")
                .foregroundStyle(.secondary)
            Button {
                permissionInfo = PermissionInfo(details: permission.subtitle)
            } label: {
                Image(systemName: "info.circle")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            Spacer()
            Button("Open System Settings…") {
                viewModel.openSettings(for: permission)
            }
        }
    }
}

private struct PermissionInfo: Identifiable {
    let id = UUID()
    let details: String
}
