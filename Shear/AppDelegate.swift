import ApplicationServices
import Cocoa
import Defaults
import ServiceManagement

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    enum LaunchAtLoginError: LocalizedError {
        case statusMismatch(requestedEnabled: Bool)

        var errorDescription: String? {
            switch self {
            case let .statusMismatch(requestedEnabled):
                if requestedEnabled {
                    return "macOS did not enable launch at startup after the change was requested."
                }

                return "macOS did not disable launch at startup after the change was requested."
            }
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
                    AppWindowRouter.open(AppWindowID.permissions)
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

    @discardableResult
    func refreshPermissionState() -> AppPermissionState {
        let state = AppPermissionState.current()

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

    func setLaunchAtLogin(_ enabled: Bool) throws {
        if enabled {
            try SMAppService.mainApp.register()
        } else {
            try SMAppService.mainApp.unregister()
        }

        guard isLaunchAtLoginEnabled() == enabled else {
            throw LaunchAtLoginError.statusMismatch(requestedEnabled: enabled)
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
