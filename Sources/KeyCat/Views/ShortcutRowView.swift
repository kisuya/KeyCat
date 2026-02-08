import SwiftUI

struct ShortcutRowView: View {
    let shortcut: Shortcut
    let prefix: String?
    var isSelected: Bool = false
    var onCopy: ((String) -> Void)? = nil
    @State private var showCopied = false

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

            if showCopied {
                Image(systemName: "checkmark")
                    .font(.caption)
                    .foregroundStyle(.green)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 2)
        .padding(.horizontal, isSelected ? 4 : 0)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : .clear)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            copyKey()
        }
    }

    private func copyKey() {
        let key = formattedKey
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(key, forType: .string)
        onCopy?(key)

        withAnimation(.easeInOut(duration: 0.15)) {
            showCopied = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.15)) {
                showCopied = false
            }
        }
    }

    private var formattedKey: String {
        let raw = shortcut.key
        guard let prefix else { return KeyFormatter.format(raw) }

        let resolved = raw.replacingOccurrences(of: "prefix + ", with: "\(prefix) ")
            .replacingOccurrences(of: "prefix+", with: "\(prefix)")
        return KeyFormatter.format(resolved)
    }
}
