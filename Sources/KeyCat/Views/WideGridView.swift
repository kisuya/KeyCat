import SwiftUI

struct WideGridView: View {
    let files: [ShortcutFile]
    let collapsedCategories: Set<String>
    let onToggleCategory: (String) -> Void
    var selectedIndex: Int = -1

    private let columns = [
        GridItem(.adaptive(minimum: AppConstants.wideViewMinColumnWidth), spacing: 16)
    ]

    var body: some View {
        if files.isEmpty {
            ContentUnavailableView {
                Label("검색 결과 없음", systemImage: "magnifyingglass")
            } description: {
                Text("검색어를 변경해보세요.")
            }
        } else {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVGrid(columns: columns, alignment: .leading, spacing: 16) {
                        ForEach(Array(files.enumerated()), id: \.element.id) { fileIdx, file in
                            let base = baseIndex(for: fileIdx)
                            AppColumnView(
                                file: file,
                                collapsedCategories: collapsedCategories,
                                onToggleCategory: onToggleCategory,
                                selectedIndex: selectedIndex,
                                baseIndex: base
                            )
                        }
                    }
                    .padding(20)
                }
                .onChange(of: selectedIndex) { _, newValue in
                    if newValue >= 0 {
                        withAnimation {
                            proxy.scrollTo(newValue, anchor: .center)
                        }
                    }
                }
            }
        }
    }

    private func baseIndex(for fileIndex: Int) -> Int {
        var base = 0
        for i in 0..<fileIndex {
            base += visibleShortcutCount(for: files[i])
        }
        return base
    }

    private func visibleShortcutCount(for file: ShortcutFile) -> Int {
        file.categories
            .filter { !collapsedCategories.contains($0.name) }
            .reduce(0) { $0 + $1.shortcuts.count }
    }
}
