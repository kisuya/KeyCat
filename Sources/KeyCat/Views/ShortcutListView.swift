import SwiftUI

struct ShortcutListView: View {
    let file: ShortcutFile?
    let query: String

    var body: some View {
        if let file, !file.categories.isEmpty {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0, pinnedViews: [.sectionHeaders]) {
                    if let prefix = file.prefix {
                        PrefixBanner(prefix: prefix)
                    }

                    ForEach(file.categories) { category in
                        Section {
                            ForEach(category.shortcuts) { shortcut in
                                ShortcutRowView(
                                    shortcut: shortcut,
                                    prefix: file.prefix
                                )
                                .padding(.horizontal, 16)
                            }
                        } header: {
                            CategoryHeaderView(name: category.name)
                                .padding(.horizontal, 12)
                        }
                    }
                }
            }
        } else {
            EmptyStateView(query: query)
        }
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
