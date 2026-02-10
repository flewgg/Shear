import SwiftUI

@main
struct Command_CutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage("CutShortcutMode") private var shortcutMode = "command"
    @State private var launchAtLogin = false

    var body: some Scene {
        MenuBarExtra {
            Section("Shortcut Mode") {
                Button {
                    shortcutMode = "command"
                } label: {
                    ShortcutRow(title: "Command", shortcut: "⌘X", selected: shortcutMode == "command")
                }
                Button {
                    shortcutMode = "control"
                } label: {
                    ShortcutRow(title: "Control", shortcut: "⌃X", selected: shortcutMode == "control")
                }
            }
            
            Divider()

            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { _, newValue in
                    appDelegate.setLaunchAtLogin(newValue)
                }
                .onAppear {
                    launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
                }

            Divider()

           
            Button("Input Monitoring Settings...") {
                appDelegate.openInputMonitoringSettings()
            }
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        label: {
            Image(systemName: "scissors")
                .imageScale(.medium)
        }
    }
}

private struct ShortcutRow: View {
    let title: String
    let shortcut: String
    let selected: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark")
                .opacity(selected ? 1 : 0)
                .foregroundStyle(.secondary)
                .frame(width: 12)
            Text(title)
            Spacer()
            Text(shortcut)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: 200)
    }
}
