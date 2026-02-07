import SwiftUI

struct SettingsFooterView: View {
    var body: some View {
        HStack {
            Button {
                openConfigFolder()
            } label: {
                Label("Config Folder", systemImage: "folder")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)

            Spacer()

            Button {
                NSApplication.shared.terminate(nil)
            } label: {
                Label("Quit", systemImage: "power")
                    .font(.subheadline)
            }
            .buttonStyle(.plain)
            .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.bar)
    }

    private func openConfigFolder() {
        let url = AppConstants.userConfigDirectory
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: url.path) {
            try? fileManager.createDirectory(
                at: url,
                withIntermediateDirectories: true
            )
        }
        NSWorkspace.shared.open(url)
    }
}
