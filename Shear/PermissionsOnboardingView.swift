import SwiftUI

struct PermissionsOnboardingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase

    let appDelegate: AppDelegate

    @State private var permissions = AppDelegate.PermissionState(
        inputMonitoringGranted: false,
        postEventAccessGranted: false
    )

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Permissions")
                    .font(.system(size: 28, weight: .bold))

                Text("Grant both permissions to continue.")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, 2)

            ForEach(AppPermission.allCases, id: \.self) { permission in
                PermissionCard(
                    title: permission.title,
                    subtitle: permission.subtitle,
                    icon: permission.iconName,
                    isGranted: permission.isGranted(in: permissions)
                ) {
                    appDelegate.openSettings(for: permission)
                }
            }

            Spacer()

            HStack {
                Spacer()
                if allPermissionsGranted {
                    Button("Continue") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Refresh") {
                        refreshFromSystem()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(20)
        .frame(
            minWidth: 520,
            idealWidth: 520,
            maxWidth: 520,
            minHeight: 350,
            idealHeight: 350,
            maxHeight: 350
        )
        .background(Color(nsColor: .windowBackgroundColor))
        .onAppear(perform: refreshFromSystem)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                refreshFromSystem()
            }
        }
    }

    private var allPermissionsGranted: Bool {
        permissions.allRequiredGranted
    }

    private func refreshFromSystem() {
        permissions = appDelegate.refreshPermissionState()
    }
}

private struct PermissionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let isGranted: Bool
    let openSettingsAction: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(isGranted ? Color.green : Color.secondary)
                .frame(width: 22)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))

                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 12)

            if isGranted {
                Label("Granted", systemImage: "checkmark.circle.fill")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.green)
            } else {
                Button("Open System Settings…", action: openSettingsAction)
                    .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(cardBackground)
        .overlay(cardBorder)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(isGranted ? Color.green.opacity(0.14) : Color(nsColor: .controlBackgroundColor))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isGranted ? Color.green.opacity(0.42) : Color(nsColor: .separatorColor).opacity(0.30), lineWidth: 1)
    }
}

#Preview {
    PermissionsOnboardingView(appDelegate: AppDelegate())
}
