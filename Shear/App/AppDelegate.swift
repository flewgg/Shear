import ApplicationServices
import Cocoa
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    struct PermissionState {
        let inputMonitoringGranted: Bool
        let postEventAccessGranted: Bool

        var allRequiredGranted: Bool {
            inputMonitoringGranted && postEventAccessGranted
        }
    }

    private enum SettingsURL {
        static let accessibility = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        static let inputMonitoring = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
    }

    private let eventTapManager = EventTapManager()
    private lazy var updaterManager = UpdaterManager()
    private var didBecomeActiveObserver: NSObjectProtocol?

    func applicationWillFinishLaunching(_ notification: Notification) {
        applyDockIconVisibility(hidden: isDockIconHidden())
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        _ = updaterManager

        didBecomeActiveObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: NSApp,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refreshPermissionState()
            }
        }

        refreshPermissionState()

        let defaults = UserDefaults.standard
        let hasShownOnboarding = defaults.bool(forKey: AppDefaultsKey.hasShownPermissionsOnboarding)
        if !hasShownOnboarding {
            defaults.set(true, forKey: AppDefaultsKey.hasShownPermissionsOnboarding)
            if !permissionState().allRequiredGranted {
                DispatchQueue.main.async {
                    AppWindowRouter.open(id: AppWindowID.permissions)
                }
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let observer = didBecomeActiveObserver {
            NotificationCenter.default.removeObserver(observer)
            didBecomeActiveObserver = nil
        }
    }

    func hasInputMonitoringAccess() -> Bool {
        CGPreflightListenEventAccess()
    }

    func hasPostEventAccess() -> Bool {
        CGPreflightPostEventAccess()
    }

    func permissionState() -> PermissionState {
        PermissionState(
            inputMonitoringGranted: hasInputMonitoringAccess(),
            postEventAccessGranted: hasPostEventAccess()
        )
    }

    func refreshPermissionState() {
        if permissionState().allRequiredGranted {
            eventTapManager.start()
        } else {
            eventTapManager.stop()
            eventTapManager.start()
        }
    }

    func openSettings(for permission: AppPermission) {
        switch permission {
        case .inputMonitoring:
            openSystemSettings(SettingsURL.inputMonitoring)
        case .postEvents:
            openSystemSettings(SettingsURL.accessibility)
        }
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

    var canCheckForUpdates: Bool {
        updaterManager.isAvailable
    }

    func checkForUpdates() {
        updaterManager.checkForUpdates()
    }

    private func applyDockIconVisibility(hidden: Bool) {
        let policy: NSApplication.ActivationPolicy = hidden ? .accessory : .regular
        guard NSApplication.shared.activationPolicy() != policy else { return }
        NSApplication.shared.setActivationPolicy(policy)
    }

    private func openSystemSettings(_ url: URL) {
        NSWorkspace.shared.open(url)
    }
}
