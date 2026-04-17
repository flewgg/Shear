import Foundation

extension Bundle {
    var appName: String {
        infoDictionary?["CFBundleDisplayName"] as? String
            ?? infoDictionary?["CFBundleName"] as? String
            ?? "Unknown"
    }

    var appVersion: String {
        infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }

    var buildNumber: String {
        infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }

    var appVersionDisplay: String {
        switch (appVersion, buildNumber) {
        case let (version, build) where version != "Unknown" && build != "Unknown" && version != build:
            return "\(version) (\(build))"
        case let (version, _) where version != "Unknown":
            return version
        case let (_, build) where build != "Unknown":
            return build
        default:
            return "Unknown"
        }
    }

    var copyright: String {
        object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String
            ?? "© \(Calendar.current.component(.year, from: Date())) flew. All rights reserved."
    }
}
