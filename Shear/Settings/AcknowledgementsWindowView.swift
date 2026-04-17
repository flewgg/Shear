import SwiftUI

struct AcknowledgementsWindowView: View {
    private let acknowledgmentsText = loadAcknowledgementsText()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Text(verbatim: acknowledgmentsText)
                    .font(.system(.body, design: .monospaced))
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

private func loadAcknowledgementsText() -> String {
    let resourceName = "Acknowledgments"
    let resourceExtension = "txt"
    let bundles = [Bundle.main, Bundle(for: BundleAnchor.self)]

    for bundle in bundles {
        guard let url = bundle.url(forResource: resourceName, withExtension: resourceExtension),
              let text = try? String(contentsOf: url, encoding: .utf8) else {
            continue
        }

        return text
    }

    return """
    Acknowledgments are unavailable because \(resourceName).\(resourceExtension) could not be loaded from the app bundle.
    """
}

private final class BundleAnchor {}

#Preview("Acknowledgements") {
    AcknowledgementsWindowView()
}
