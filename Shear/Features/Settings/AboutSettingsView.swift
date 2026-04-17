import AppKit
import SwiftUI

private enum AboutContent {
    static let repositoryURL = URL(string: "https://github.com/flewgg/Shear")!
    static let releasesURL = URL(string: "https://github.com/flewgg/Shear/releases")!
    static let feedbackURL = URL(string: "https://github.com/flewgg/Shear/issues")!
    static let contactURL = URL(string: "mailto:contact@flew.gg")!

    static let links: [LinkItem] = [
        .init(title: "Release Notes", label: "github.com/flewgg/Shear/releases", destination: releasesURL),
        .init(title: "Repository", label: "github.com/flewgg/Shear", destination: repositoryURL),
        .init(title: "Contact", label: "contact@flew.gg", destination: contactURL)
    ]
}

private struct LinkItem: Identifiable {
    let id = UUID()
    let title: String
    let label: String
    let destination: URL
}

@MainActor
struct AboutSettingsView: View {
    let canCheckForUpdates: Bool
    let onCheckForUpdates: () -> Void
    let onOpenAcknowledgements: () -> Void

    init(
        canCheckForUpdates: Bool,
        onCheckForUpdates: @escaping () -> Void,
        onOpenAcknowledgements: @escaping () -> Void = {}
    ) {
        self.canCheckForUpdates = canCheckForUpdates
        self.onCheckForUpdates = onCheckForUpdates
        self.onOpenAcknowledgements = onOpenAcknowledgements
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            infoForm
            Spacer(minLength: 12)
            footer
        }
        .padding(.top, 24)
        .padding(.horizontal, 18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
                .resizable()
                .interpolation(.high)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            VStack(spacing: 0) {
                Text(Bundle.main.appName)
                    .font(.title.weight(.semibold))

                Text("Version \(Bundle.main.versionWithBuild)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                if canCheckForUpdates {
                    Button("Check for Updates…", action: onCheckForUpdates)
                        .buttonStyle(.bordered)
                }

                Link("Send Feedback", destination: AboutContent.feedbackURL)
                    .buttonStyle(.bordered)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }

    private var infoForm: some View {
        Form {
            Section {
                ForEach(AboutContent.links) { item in
                    LabeledContent(item.title) {
                        Link(item.label, destination: item.destination)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding(.top, 18)
    }

    private var footer: some View {
        VStack(spacing: 4) {
            Button("Acknowledgements") {
                onOpenAcknowledgements()
            }
            .buttonStyle(.plain)
            .underline()
            .font(.footnote)
            .foregroundStyle(.gray)

            Text(Bundle.main.copyright)
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.72))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    AboutSettingsView(
        canCheckForUpdates: true,
        onCheckForUpdates: {},
        onOpenAcknowledgements: {}
    )
        .frame(width: 520, height: 470)
}
