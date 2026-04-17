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
            return "Required to send Finder's move-paste shortcut (Option+Command+V)."
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

    func isGranted(in state: AppDelegate.PermissionState) -> Bool {
        switch self {
        case .inputMonitoring:
            return state.inputMonitoringGranted
        case .postEvents:
            return state.postEventAccessGranted
        }
    }
}
