import SwiftUI

struct AppColumnView: View {
    let file: ShortcutFile
    let collapsedCategories: Set<String>
    let onToggleCategory: (String) -> Void
    var selectedIndex: Int = -1
    var baseIndex: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // App header
            appHeader

            Divider()

            // Categories and shortcuts
            let _ = { () -> Void in }() // placeholder for index tracking
            ForEach(Array(categoriesWithOffsets), id: \.offset) { catOffset, category in
                CategoryHeaderView(
                    name: category.name,
                    shortcutCount: category.shortcuts.count,
                    isCollapsed: collapsedCategories.contains(category.name),
                    onToggle: { onToggleCategory(category.name) }
                )
                .padding(.horizontal, 8)

                if !collapsedCategories.contains(category.name) {
                    let catBase = baseIndex + shortcutOffset(for: category)
                    ForEach(Array(category.shortcuts.enumerated()), id: \.element.id) { idx, shortcut in
                        let globalIdx = catBase + idx
                        WideShortcutRow(
                            shortcut: shortcut,
                            prefix: file.prefix,
                            isSelected: globalIdx == selectedIndex
                        )
                        .id(globalIdx)
                        .padding(.horizontal, 12)
                    }
                }
            }

            Spacer(minLength: 8)
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(.background)
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(.quaternary, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var appHeader: some View {
        HStack(spacing: 8) {
            Image(systemName: file.icon ?? AppConstants.defaultIcon)
                .font(.system(size: 18))
                .foregroundStyle(.secondary)
                .frame(width: 28, height: 28)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.quaternary.opacity(0.5))
                )

            Text(file.app)
                .font(.headline)

            if let prefix = file.prefix {
                Text(KeyFormatter.format(prefix))
                    .font(.caption.monospaced())
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.accentColor.opacity(0.1))
                    )
                    .foregroundStyle(Color.accentColor)
            }

            Spacer()

            Text("\(totalShortcutCount)개")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.quaternary.opacity(0.3))
    }

    private var totalShortcutCount: Int {
        file.categories.reduce(0) { $0 + $1.shortcuts.count }
    }

    private var categoriesWithOffsets: [(offset: Int, element: ShortcutCategory)] {
        Array(file.categories.enumerated()).map { (offset: $0.offset, element: $0.element) }
    }

    private func shortcutOffset(for category: ShortcutCategory) -> Int {
        var offset = 0
        for cat in file.categories {
            if cat.name == category.name { return offset }
            if !collapsedCategories.contains(cat.name) {
                offset += cat.shortcuts.count
            }
        }
        return offset
    }
}

// Shortcut row with hover effect and click-to-copy for wide view
struct WideShortcutRow: View {
    let shortcut: Shortcut
    let prefix: String?
    var isSelected: Bool = false
    @State private var isHovered = false
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
        .padding(.vertical, 3)
        .padding(.horizontal, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(isSelected ? Color.accentColor.opacity(0.15) : isHovered ? Color.accentColor.opacity(0.08) : .clear)
        )
        .contentShape(Rectangle())
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            copyKey()
        }
    }

    private func copyKey() {
        let key = formattedKey
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(key, forType: .string)

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
