import AppKit
import SwiftUI

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

                Text("Version \(Bundle.main.appVersionDisplay)")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 10) {
                if canCheckForUpdates {
                    Button("Check for Updates…", action: onCheckForUpdates)
                        .buttonStyle(.bordered)
                }

                Link("Send Feedback", destination: URL(string: "https://github.com/flewgg/Shear/issues")!)
                    .buttonStyle(.bordered)
            }
            .padding(.top, 12)
        }
        .frame(maxWidth: .infinity)
    }

    private var infoForm: some View {
        Form {
            Section {
                LabeledContent("Release Notes") {
                    Link(
                        "github.com/flewgg/Shear/releases",
                        destination: URL(string: "https://github.com/flewgg/Shear/releases")!
                    )
                }

                LabeledContent("Repository") {
                    Link(
                        "github.com/flewgg/Shear",
                        destination: URL(string: "https://github.com/flewgg/Shear")!
                    )
                }

                LabeledContent("Contact") {
                    Link("contact@flew.gg", destination: URL(string: "mailto:contact@flew.gg")!)
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
        onCheckForUpdates: {}
    )
        .frame(width: 520, height: 470)
}
