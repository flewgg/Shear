import Foundation

#if canImport(Sparkle)
import Sparkle
#endif

@MainActor
final class UpdaterManager {
    #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController
    #endif

    init() {
        #if canImport(Sparkle)
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: nil,
            userDriverDelegate: nil
        )
        #endif
    }

    var isAvailable: Bool {
        #if canImport(Sparkle)
        true
        #else
        false
        #endif
    }

    func checkForUpdates() {
        #if canImport(Sparkle)
        updaterController.checkForUpdates(nil)
        #endif
    }
}
