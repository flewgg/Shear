import SwiftUI

@main
struct Command_CutApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    var body: some Scene {
        MenuBarExtra {
            MenuBarContent()
        }
        label: {
            Image(systemName: "scissors.badge.ellipsis")
                .imageScale(.medium)
        }

        Window("Settings", id: "settings") {
            SettingsView(appDelegate: appDelegate)
        }
        .defaultSize(width: 420, height: 320)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        Window("Info", id: "info") {
            InfoPopupView()
        }
        .defaultSize(width: 320, height: 220)
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
    }
}

private struct MenuBarContent: View {
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Button {
            showWindow(id: "settings")
        } label: {
            Label("Settings", systemImage: "gearshape")
        }

        Button {
            showWindow(id: "info")
        } label: {
            Label("Info", systemImage: "info.circle")
        }

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
}

private struct InfoPopupView: View {
    private let repositoryURL = URL(string: "https://github.com/flewgg/CommandCut")!
    private let creditsURL = URL(string: "https://github.com/flewgg")!

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Command Cut")
                .font(.headline)

            Text("Version \(appVersionDisplay)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Divider()

            Link("GitHub Repository", destination: repositoryURL)

            HStack(spacing: 10) {
                Image("CreditsAvatar")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 34, height: 34)
                    .clipShape(RoundedRectangle(cornerRadius: 8))

                VStack(alignment: .leading, spacing: 2) {
                    Text("flewgg")
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
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String

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
