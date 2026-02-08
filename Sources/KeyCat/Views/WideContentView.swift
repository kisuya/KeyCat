import SwiftUI

struct WideContentView: View {
    @Bindable var appState: AppState
    let onClose: () -> Void
    @FocusState private var isSearchFocused: Bool
    @State private var filterApp: String? = nil
    @State private var selectedIndex: Int = 0

    private var store: ShortcutStore { appState.store }

    private var displayFiles: [ShortcutFile] {
        let all = store.allFilteredFiles
        if let filterApp {
            return all.filter { $0.app == filterApp }
        }
        return all
    }

    /// 전체 모드: 앱 = 패널, 단일 앱 모드: 카테고리 = 패널
    private var displayPanels: [ShortcutFile] {
        let files = displayFiles
        if files.count == 1, let file = files.first, file.categories.count > 1 {
            return file.categories.map { category in
                ShortcutFile(
                    app: category.name,
                    prefix: file.prefix,
                    icon: file.icon,
                    categories: [category]
                )
            }
        }
        return files
    }

    private var allVisibleShortcuts: [Shortcut] {
        displayPanels.flatMap { panel in
            panel.categories
                .filter { !appState.collapsedCategories.contains($0.name) }
                .flatMap(\.shortcuts)
        }
    }

    /// 각 패널의 시작 인덱스 (마지막 원소 = 전체 개수)
    private var panelBoundaries: [Int] {
        var boundaries: [Int] = [0]
        for panel in displayPanels {
            let count = panel.categories
                .filter { !appState.collapsedCategories.contains($0.name) }
                .reduce(0) { $0 + $1.shortcuts.count }
            boundaries.append(boundaries.last! + count)
        }
        return boundaries
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerBar

            Divider()

            // App filter tabs
            appFilterBar

            Divider()

            // Grid content
            WideGridView(
                files: displayPanels,
                collapsedCategories: appState.collapsedCategories,
                onToggleCategory: { appState.toggleCategory($0) },
                selectedIndex: selectedIndex
            )

            Divider()

            SettingsFooterView(appState: appState)
        }
        .toast(appState.toastMessage)
        .onKeyPress(.escape) {
            onClose()
            return .handled
        }
        .onKeyPress(.upArrow) {
            moveSelection(by: -1)
            return .handled
        }
        .onKeyPress(.downArrow) {
            moveSelection(by: 1)
            return .handled
        }
        .onKeyPress(.leftArrow) {
            switchPanel(by: -1)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            switchPanel(by: 1)
            return .handled
        }
        .onKeyPress(.return) {
            copySelectedKey()
            return .handled
        }
        .onChange(of: store.searchQuery) {
            clampSelection()
        }
        .onChange(of: appState.collapsedCategories) {
            clampSelection()
        }
        .onChange(of: filterApp) {
            selectedIndex = 0
        }
        .onKeyPress(.tab) {
            switchFilter(by: 1)
            return .handled
        }
        .onKeyPress(characters: .init(charactersIn: "f")) { press in
            if press.modifiers.contains(.command) {
                isSearchFocused = true
                return .handled
            }
            return .ignored
        }
    }

    private var headerBar: some View {
        HStack(spacing: 12) {
            SearchBarView(
                query: Binding(
                    get: { store.searchQuery },
                    set: { store.searchQuery = $0 }
                ),
                isFocused: $isSearchFocused
            )

            Button {
                onClose()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
            .padding(.trailing, 12)
            .help("닫기 (Esc)")
        }
    }

    private var appFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                filterChip(label: "전체", icon: "square.grid.2x2", app: nil)

                ForEach(store.orderedFiles) { file in
                    filterChip(
                        label: file.app,
                        icon: file.icon ?? AppConstants.defaultIcon,
                        app: file.app
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
        .background(.bar)
    }

    // MARK: - Navigation

    private func moveSelection(by delta: Int) {
        let count = allVisibleShortcuts.count
        guard count > 0 else { return }
        let newIndex = selectedIndex + delta
        selectedIndex = max(0, min(newIndex, count - 1))
    }

    private func switchPanel(by delta: Int) {
        let boundaries = panelBoundaries
        let panelCount = boundaries.count - 1
        guard panelCount > 0 else { return }

        // 현재 패널 찾기
        var currentPanel = 0
        for i in 0..<panelCount {
            if selectedIndex >= boundaries[i] && selectedIndex < boundaries[i + 1] {
                currentPanel = i
                break
            }
        }

        let newPanel = max(0, min(currentPanel + delta, panelCount - 1))
        if newPanel != currentPanel {
            let offsetInCurrent = selectedIndex - boundaries[currentPanel]
            let targetPanelSize = boundaries[newPanel + 1] - boundaries[newPanel]
            let clampedOffset = min(offsetInCurrent, targetPanelSize - 1)
            selectedIndex = boundaries[newPanel] + max(0, clampedOffset)
        }
    }

    private func clampSelection() {
        let count = allVisibleShortcuts.count
        if count == 0 {
            selectedIndex = 0
        } else if selectedIndex >= count {
            selectedIndex = count - 1
        }
    }

    private func copySelectedKey() {
        let shortcuts = allVisibleShortcuts
        guard selectedIndex >= 0, selectedIndex < shortcuts.count else { return }
        let shortcut = shortcuts[selectedIndex]
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(shortcut.key, forType: .string)
        appState.showToast(.copied())
    }

    private func switchFilter(by delta: Int) {
        let apps: [String?] = [nil] + store.orderedFiles.map(\.app)
        guard !apps.isEmpty else { return }
        let currentIndex = apps.firstIndex(where: { $0 == filterApp }) ?? 0
        let newIndex = (currentIndex + delta + apps.count) % apps.count
        withAnimation(.easeInOut(duration: 0.15)) {
            filterApp = apps[newIndex]
        }
    }

    private func filterChip(label: String, icon: String, app: String?) -> some View {
        let isActive = filterApp == app

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                filterApp = app
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(label)
                    .font(.caption)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background {
                if isActive {
                    Capsule().fill(Color.accentColor.opacity(0.15))
                } else {
                    Capsule().fill(.quaternary.opacity(0.5))
                }
            }
            .overlay {
                if isActive {
                    Capsule().strokeBorder(Color.accentColor.opacity(0.5), lineWidth: 1)
                }
            }
        }
        .buttonStyle(.plain)
        .foregroundStyle(isActive ? .primary : .secondary)
    }
}
