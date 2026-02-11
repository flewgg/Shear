import ApplicationServices
import Cocoa
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private enum SettingsURL {
        static let accessibility = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
        static let inputMonitoring = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")
    }

    private let eventTapManager = EventTapManager()

    func applicationWillFinishLaunching(_ notification: Notification) {
        applyDockIconVisibility(hidden: isDockIconHidden())
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        requestInputMonitoringAccess()
        requestAccessibilityAccess()
        eventTapManager.start()
    }

    func requestInputMonitoringAccess() {
        if !CGPreflightListenEventAccess() {
            _ = CGRequestListenEventAccess()
        }
    }

    func hasInputMonitoringAccess() -> Bool {
        CGPreflightListenEventAccess()
    }

    func requestAccessibilityAccess() {
        if !CGPreflightPostEventAccess() {
            _ = CGRequestPostEventAccess()
        }
    }

    func hasAccessibilityAccess() -> Bool {
        CGPreflightPostEventAccess()
    }

    func openAccessibilitySettings() {
        openSystemSettings(SettingsURL.accessibility)
    }

    func openInputMonitoringSettings() {
        openSystemSettings(SettingsURL.inputMonitoring)
    }

    @discardableResult
    func setLaunchAtLogin(_ enabled: Bool) -> Bool {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
            return isLaunchAtLoginEnabled() == enabled
        } catch {
            NSLog("Shear: failed to update launch at login: %@", error.localizedDescription)
            return false
        }
    }

    func isLaunchAtLoginEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setDockIconHidden(_ hidden: Bool) {
        UserDefaults.standard.set(hidden, forKey: AppDefaultsKey.hideDockIcon)
        applyDockIconVisibility(hidden: hidden)
    }

    func isDockIconHidden() -> Bool {
        UserDefaults.standard.bool(forKey: AppDefaultsKey.hideDockIcon)
    }

    private func applyDockIconVisibility(hidden: Bool) {
        let policy: NSApplication.ActivationPolicy = hidden ? .accessory : .regular
        guard NSApplication.shared.activationPolicy() != policy else { return }
        NSApplication.shared.setActivationPolicy(policy)
    }

    private func openSystemSettings(_ url: URL?) {
        guard let url else { return }
        NSWorkspace.shared.open(url)
    }
}
