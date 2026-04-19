import AppKit
import SwiftUI

enum AppWindowID: String {
    case permissions
    case settings
    case info
    case acknowledgements
}

extension OpenWindowAction {
    @MainActor
    func openAndActivate(id: AppWindowID) {
        callAsFunction(id: id.rawValue)
        NSApplication.shared.activate(ignoringOtherApps: true)
    }
}

@MainActor
enum AppWindowRouter {
    private static var openWindowHandler: ((AppWindowID) -> Void)?
    private static var pendingWindowID: AppWindowID?

    static func install(handler: @escaping (AppWindowID) -> Void) {
        openWindowHandler = handler
        if let pendingID = pendingWindowID {
            pendingWindowID = nil
            handler(pendingID)
        }
    }

    static func install(openWindow: OpenWindowAction) {
        install { id in
            openWindow.openAndActivate(id: id)
        }
    }

    static func open(_ id: AppWindowID) {
        if let openWindowHandler {
            openWindowHandler(id)
        } else {
            pendingWindowID = id
        }
    }
}
