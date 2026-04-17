import ApplicationServices
import Cocoa
import Defaults
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

    private let eventTapManager = EventTapManager()
    private lazy var updaterManager = UpdaterManager()
    private var didBecomeActiveObserver: NSObjectProtocol?

    func applicationWillFinishLaunching(_ notification: Notification) {
        applyDockIconVisibility(hidden: Defaults[.hideDockIcon])
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

        let currentPermissionState = refreshPermissionState()

        if !Defaults[.hasShownPermissionsOnboarding] {
            Defaults[.hasShownPermissionsOnboarding] = true
            if !currentPermissionState.allRequiredGranted {
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

    @discardableResult
    func refreshPermissionState() -> PermissionState {
        let state = permissionState()

        if state.allRequiredGranted {
            eventTapManager.start()
        } else {
            eventTapManager.stop()
            eventTapManager.start()
        }

        return state
    }

    func openSettings(for permission: AppPermission) {
        openSystemSettings(permission.settingsURL)
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
        Defaults[.hideDockIcon] = hidden
        applyDockIconVisibility(hidden: hidden)
    }

    func isDockIconHidden() -> Bool {
        Defaults[.hideDockIcon]
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
