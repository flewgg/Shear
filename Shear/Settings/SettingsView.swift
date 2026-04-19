import SwiftUI

struct SettingsView: View {
    @Environment(\.openWindow) private var openWindow
    private let appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
    }

    var body: some View {
        TabView {
            GeneralSettingsView(appDelegate: appDelegate)
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            AboutSettingsView(
                canCheckForUpdates: appDelegate.canCheckForUpdates,
                onCheckForUpdates: appDelegate.checkForUpdates,
                onOpenAcknowledgements: {
                    openWindow.openAndActivate(id: .acknowledgements)
                }
            )
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(minWidth: 520, minHeight: 470)
    }
}

#Preview {
    SettingsView(appDelegate: AppDelegate())
}
