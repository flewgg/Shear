import Foundation
import Combine

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published private(set) var launchAtLogin = false
    @Published private(set) var hideDockIcon = false
    @Published private(set) var permissions = AppDelegate.PermissionState(
        inputMonitoringGranted: false,
        postEventAccessGranted: false
    )

    private let appDelegate: AppDelegate

    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        refreshFromSystem()
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        _ = appDelegate.setLaunchAtLogin(enabled)
        launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
    }

    func setHideDockIcon(_ hidden: Bool) {
        appDelegate.setDockIconHidden(hidden)
        hideDockIcon = appDelegate.isDockIconHidden()
    }

    func openSettings(for permission: AppPermission) {
        appDelegate.openSettings(for: permission)
    }

    func refreshPermissions() {
        appDelegate.refreshPermissionState()
        refreshFromSystem()
    }

    private func refreshFromSystem() {
        launchAtLogin = appDelegate.isLaunchAtLoginEnabled()
        hideDockIcon = appDelegate.isDockIconHidden()
        permissions = appDelegate.permissionState()
    }
}
