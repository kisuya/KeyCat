import SwiftUI

struct ShortcutListView: View {
    let file: ShortcutFile?
    let query: String
    var collapsedCategories: Set<String> = []
    var onToggleCategory: ((String) -> Void)? = nil
    @Binding var selectedIndex: Int

    var body: some View {
        if let file, !file.categories.isEmpty {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                        if let prefix = file.prefix {
                            PrefixBanner(prefix: prefix)
                        }

                        ForEach(file.categories) { category in
                            Section {
                                if !collapsedCategories.contains(category.name) {
                                    ForEach(Array(category.shortcuts.enumerated()), id: \.element.id) { offset, shortcut in
                                        let globalIndex = globalShortcutIndex(for: category, localOffset: offset, in: file)
                                        ShortcutRowView(
                                            shortcut: shortcut,
                                            prefix: file.prefix,
                                            isSelected: globalIndex == selectedIndex
                                        )
                                        .id(globalIndex)
                                        .padding(.horizontal, 16)
                                    }
                                }
                            } header: {
                                CategoryHeaderView(
                                    name: category.name,
                                    shortcutCount: category.shortcuts.count,
                                    isCollapsed: collapsedCategories.contains(category.name),
                                    onToggle: { onToggleCategory?(category.name) }
                                )
                                .padding(.horizontal, 12)
                            }
                        }
                    }
                }
                .onChange(of: selectedIndex) { _, newValue in
                    if newValue >= 0 {
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        } else {
            EmptyStateView(query: query)
        }
    }

    private func globalShortcutIndex(for category: ShortcutCategory, localOffset: Int, in file: ShortcutFile) -> Int {
        var index = 0
        for cat in file.categories {
            if cat.name == category.name {
                return index + localOffset
            }
            if !collapsedCategories.contains(cat.name) {
                index += cat.shortcuts.count
            }
        }
        return index + localOffset
    }
}

private struct PrefixBanner: View {
    let prefix: String

    var body: some View {
        HStack(spacing: 6) {
            Text("prefix =")
                .foregroundStyle(.secondary)
            Text(KeyFormatter.format(prefix))
                .font(.system(.body, design: .monospaced))
                .fontWeight(.medium)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 6)
        .background(.quaternary.opacity(0.5))
    }
}
