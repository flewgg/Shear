import SwiftUI

@main
struct ShearApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent(appDelegate: appDelegate)
        }
        label: {
            MenuBarLabel()
        }

        Window("Permissions Required", id: AppWindowID.permissions) {
            PermissionsOnboardingView(appDelegate: appDelegate)
        }
        .defaultSize(width: 520, height: 350)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        Window("Settings", id: AppWindowID.settings) {
            SettingsView(appDelegate: appDelegate)
        }
        .defaultSize(width: 520, height: 470)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        Window("Info", id: AppWindowID.info) {
            InfoPopupView()
        }
        .defaultSize(width: 320, height: 220)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        Window("Acknowledgements", id: AppWindowID.acknowledgements) {
            AcknowledgementsWindowView()
        }
        .windowToolbarStyle(.unified)
        .defaultSize(width: 720, height: 640)
    }
}

private func openAndActivateWindow(_ openWindow: OpenWindowAction, id: String) {
    openWindow(id: id)
    NSApplication.shared.activate(ignoringOtherApps: true)
}

private struct MenuBarLabel: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image(systemName: "scissors.badge.ellipsis")
            .imageScale(.medium)
            .onAppear {
                AppWindowRouter.install { id in
                    openAndActivateWindow(openWindow, id: id)
                }
            }
    }
}

private struct MenuBarContent: View {
    let appDelegate: AppDelegate
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        windowButton(title: "Settings", systemImage: "gearshape", id: AppWindowID.settings)
        windowButton(title: "Info", systemImage: "info.circle", id: AppWindowID.info)

        if appDelegate.canCheckForUpdates {
            Button {
                appDelegate.checkForUpdates()
            } label: {
                Label("Check for updates...", systemImage: "arrow.triangle.2.circlepath")
            }
        }

        Divider()

        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Label("Quit", systemImage: "xmark.circle")
        }
    }

    private func windowButton(title: String, systemImage: String, id: String) -> some View {
        Button {
            openAndActivateWindow(openWindow, id: id)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}

private struct InfoPopupView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shear")
                .font(.headline)

            Text("Version \(Bundle.main.appVersionDisplay)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Link("GitHub Repository", destination: URL(string: "https://github.com/flewgg/Shear")!)

            Divider()

            HStack(spacing: 10) {
                Image("CreditsAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("flew")
                    Link("github.com/flewgg", destination: URL(string: "https://github.com/flewgg")!)
                        .font(.caption)
                }
                Spacer()
            }
        }
        .padding(16)
        .frame(minWidth: 220)
    }
}
