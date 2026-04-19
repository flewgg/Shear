import SwiftUI

struct AcknowledgementsWindowView: View {
    private let content = loadAcknowledgementsContent()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: content.text)
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(content.isError ? .secondary : .primary)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .textSelection(.enabled)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

private struct AcknowledgementsContent {
    let text: String
    let isError: Bool
}

private enum AcknowledgementsLoadError: LocalizedError {
    case missingResource(name: String, fileExtension: String)
    case unreadableResource(name: String, underlyingError: Error)

    var errorDescription: String? {
        switch self {
        case let .missingResource(name, fileExtension):
            return "\(name).\(fileExtension) is missing from the app bundle."
        case let .unreadableResource(name, underlyingError):
            return "\(name) could not be read as UTF-8: \(underlyingError.localizedDescription)"
        }
    }
}

private func loadAcknowledgementsContent() -> AcknowledgementsContent {
    let resourceName = "Acknowledgments"
    let resourceExtension = "txt"
    let bundles = acknowledgementBundles()

    for bundle in bundles {
        guard let url = bundle.url(forResource: resourceName, withExtension: resourceExtension) else {
            continue
        }

        do {
            return AcknowledgementsContent(
                text: try String(contentsOf: url, encoding: .utf8),
                isError: false
            )
        } catch {
            return AcknowledgementsContent(
                text: AcknowledgementsLoadError.unreadableResource(
                    name: "\(resourceName).\(resourceExtension)",
                    underlyingError: error
                ).localizedDescription,
                isError: true
            )
        }
    }

    return AcknowledgementsContent(
        text: AcknowledgementsLoadError.missingResource(
            name: resourceName,
            fileExtension: resourceExtension
        ).localizedDescription,
        isError: true
    )
}

private func acknowledgementBundles() -> [Bundle] {
    var seenBundlePaths = Set<String>()

    return [Bundle.main, Bundle(for: BundleAnchor.self)].filter { bundle in
        seenBundlePaths.insert(bundle.bundlePath).inserted
    }
}

private final class BundleAnchor {}

#Preview("Acknowledgements") {
    AcknowledgementsWindowView()
}
