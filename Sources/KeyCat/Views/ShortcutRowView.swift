import SwiftUI

struct ShortcutRowView: View {
    let shortcut: Shortcut
    let prefix: String?

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: 12) {
            Text(formattedKey)
                .font(.system(.body, design: .monospaced))
                .foregroundStyle(.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(.quaternary)
                )
                .fixedSize()

            Text(shortcut.desc)
                .font(.body)
                .foregroundStyle(.secondary)
                .lineLimit(2)

            Spacer()
        }
        .padding(.vertical, 2)
    }

    private var formattedKey: String {
        let raw = shortcut.key
        guard let prefix else { return KeyFormatter.format(raw) }

        let resolved = raw.replacingOccurrences(of: "prefix + ", with: "\(prefix) ")
            .replacingOccurrences(of: "prefix+", with: "\(prefix)")
        return KeyFormatter.format(resolved)
    }
}
