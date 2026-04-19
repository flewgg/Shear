import Foundation

extension Bundle {
    private enum InfoKey: String {
        case displayName = "CFBundleDisplayName"
        case bundleName = "CFBundleName"
        case shortVersion = "CFBundleShortVersionString"
        case buildNumber = "CFBundleVersion"
        case copyright = "NSHumanReadableCopyright"
    }

    var appName: String {
        stringValue(for: .displayName)
            ?? stringValue(for: .bundleName)
            ?? "Unknown"
    }

    var appVersion: String {
        stringValue(for: .shortVersion) ?? "Unknown"
    }

    var buildNumber: String {
        stringValue(for: .buildNumber) ?? "Unknown"
    }

    var appVersionDisplay: String {
        let version = stringValue(for: .shortVersion)
        let build = stringValue(for: .buildNumber)

        switch (version, build) {
        case let (version?, build?) where version != build:
            return "\(version) (\(build))"
        case let (version?, _):
            return version
        case let (_, build?):
            return build
        default:
            return "Unknown"
        }
    }

    var copyright: String {
        stringValue(for: .copyright)
            ?? "© \(Calendar.current.component(.year, from: Date())) flew. All rights reserved."
    }

    private func stringValue(for key: InfoKey) -> String? {
        object(forInfoDictionaryKey: key.rawValue) as? String
    }
}
