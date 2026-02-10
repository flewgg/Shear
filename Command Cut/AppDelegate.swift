import Cocoa
import ApplicationServices
import ServiceManagement

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let eventTapManager = EventTapManager()
    private let hideDockIconKey = "HideDockIcon"
    private let accessibilitySettingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")
    private let inputMonitoringSettingsURL = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")

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
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        _ = AXIsProcessTrustedWithOptions(options)
    }

    func hasAccessibilityAccess() -> Bool {
        AXIsProcessTrusted()
    }

    func openAccessibilitySettings() {
        guard let accessibilitySettingsURL else { return }
        NSWorkspace.shared.open(accessibilitySettingsURL)
    }

    func openInputMonitoringSettings() {
        guard let inputMonitoringSettingsURL else { return }
        NSWorkspace.shared.open(inputMonitoringSettingsURL)
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
            NSLog("Command Cut: failed to update launch at login: %@", error.localizedDescription)
            return false
        }
    }

    func isLaunchAtLoginEnabled() -> Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setDockIconHidden(_ hidden: Bool) {
        UserDefaults.standard.set(hidden, forKey: hideDockIconKey)
        applyDockIconVisibility(hidden: hidden)
    }

    func isDockIconHidden() -> Bool {
        UserDefaults.standard.bool(forKey: hideDockIconKey)
    }

    private func applyDockIconVisibility(hidden: Bool) {
        let policy: NSApplication.ActivationPolicy = hidden ? .accessory : .regular
        guard NSApplication.shared.activationPolicy() != policy else { return }
        NSApplication.shared.setActivationPolicy(policy)
    }
}
