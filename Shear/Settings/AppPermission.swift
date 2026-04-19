import ApplicationServices
import Foundation

struct AppPermissionState: Equatable {
    let inputMonitoringGranted: Bool
    let postEventAccessGranted: Bool

    static let empty = Self(
        inputMonitoringGranted: false,
        postEventAccessGranted: false
    )

    static func current() -> Self {
        Self(
            inputMonitoringGranted: CGPreflightListenEventAccess(),
            postEventAccessGranted: CGPreflightPostEventAccess()
        )
    }

    var allRequiredGranted: Bool {
        inputMonitoringGranted && postEventAccessGranted
    }
}

enum AppPermission: CaseIterable, Hashable {
    case inputMonitoring
    case postEvents

    static let settingsDisplayOrder: [Self] = [.postEvents, .inputMonitoring]

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

    func isGranted(in state: AppPermissionState) -> Bool {
        switch self {
        case .inputMonitoring:
            return state.inputMonitoringGranted
        case .postEvents:
            return state.postEventAccessGranted
        }
    }
}
