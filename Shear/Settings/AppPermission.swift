import Foundation

enum AppPermission: CaseIterable, Hashable {
    case inputMonitoring
    case postEvents

    var title: String {
        switch self {
        case .inputMonitoring:
            return "Input Monitoring"
        case .postEvents:
            return "Accessibility"
        }
    }

    var subtitle: String {
        switch self {
        case .inputMonitoring:
            return "Required to detect your selected shortcut while Finder is active."
        case .postEvents:
            return "Required to send Finder's move-paste shortcut (Option+Command+V) after cut."
        }
    }

    var settingsDescription: String {
        switch self {
        case .inputMonitoring:
            return "Allows Shear to detect your selected shortcut while Finder is active. Manage in [Input Monitoring settings...](\(settingsURL.absoluteString))"
        case .postEvents:
            return "Allows Shear to send Finder's move-paste shortcut (Option+Command+V) after cut. Manage in [Accessibility settings...](\(settingsURL.absoluteString))"
        }
    }

    var iconName: String {
        switch self {
        case .inputMonitoring:
            return "keyboard"
        case .postEvents:
            return "accessibility"
        }
    }

    var settingsURL: URL {
        switch self {
        case .inputMonitoring:
            return URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent")!
        case .postEvents:
            return URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        }
    }

    func isGranted(in state: AppDelegate.PermissionState) -> Bool {
        switch self {
        case .inputMonitoring:
            return state.inputMonitoringGranted
        case .postEvents:
            return state.postEventAccessGranted
        }
    }
}
