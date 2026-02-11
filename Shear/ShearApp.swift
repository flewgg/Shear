import SwiftUI

@main
struct ShearApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent()
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
        .defaultSize(width: 420, height: 320)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        Window("Info", id: AppWindowID.info) {
            InfoPopupView()
        }
        .defaultSize(width: 320, height: 220)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

private struct MenuBarLabel: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Image(systemName: "scissors.badge.ellipsis")
            .imageScale(.medium)
            .onAppear {
                AppWindowRouter.install { id in
                    openWindow(id: id)
                    NSApplication.shared.activate(ignoringOtherApps: true)
                }
            }
    }
}

private struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        windowButton(title: "Settings", systemImage: "gearshape", id: AppWindowID.settings)
        windowButton(title: "Info", systemImage: "info.circle", id: AppWindowID.info)

        Divider()

        Button {
            NSApplication.shared.terminate(nil)
        } label: {
            Label("Quit", systemImage: "xmark.circle")
        }
    }

    private func showWindow(id: String) {
        openWindow(id: id)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }

    private func windowButton(title: String, systemImage: String, id: String) -> some View {
        Button {
            showWindow(id: id)
        } label: {
            Label(title, systemImage: systemImage)
        }
    }
}

private struct InfoPopupView: View {
    private let repositoryURL = URL(string: "https://github.com/flewgg/Shear")!
    private let creditsURL = URL(string: "https://github.com/flewgg")!

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Shear")
                .font(.headline)

            Text("Version \(appVersionDisplay)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Link("GitHub Repository", destination: repositoryURL)
            
            Divider()

            HStack(spacing: 10) {
                Image("CreditsAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("flew")
                    Link("github.com/flewgg", destination: creditsURL)
                        .font(.caption)
                }
                Spacer()
            }
        }
        .padding(16)
        .frame(minWidth: 220)
    }

    private var appVersionDisplay: String {
        Bundle.main.appVersionDisplay
    }
}

private extension Bundle {
    var appVersionDisplay: String {
        let version = object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = object(forInfoDictionaryKey: "CFBundleVersion") as? String

        switch (version, build) {
        case let (version?, build?) where version != build:
            return "\(version) (\(build))"
        case let (version?, _):
            return version
        case let (_, build?):
            return build
        default:
            return "Unknown"
        }
    }
}
