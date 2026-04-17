enum AppWindowID {
    static let permissions = "permissions"
    static let settings = "settings"
    static let info = "info"
    static let acknowledgements = "acknowledgements"
}

@MainActor
enum AppWindowRouter {
    private static var openWindowHandler: ((String) -> Void)?
    private static var pendingWindowID: String?

    static func install(handler: @escaping (String) -> Void) {
        openWindowHandler = handler
        if let pendingID = pendingWindowID {
            pendingWindowID = nil
            handler(pendingID)
        }
    }

    static func open(id: String) {
        if let openWindowHandler {
            openWindowHandler(id)
        } else {
            pendingWindowID = id
        }
    }
}
