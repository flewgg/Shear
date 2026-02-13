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
            return "Required to detect your selected shortcut globally."
        case .postEvents:
            return "Required to send Option+Command+V for cut-paste."
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
