import SwiftUI

struct PopoverContentView: View {
    @Bindable var appState: AppState
    @FocusState private var isSearchFocused: Bool
    @State private var selectedIndex: Int = -1

    private var store: ShortcutStore { appState.store }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(
                query: Binding(
                    get: { store.searchQuery },
                    set: { store.searchQuery = $0 }
                ),
                isFocused: $isSearchFocused
            )

            TabBarView(
                apps: store.orderedFiles,
                selectedApp: Binding(
                    get: { store.selectedApp },
                    set: { store.selectApp($0) }
                )
            )

            Divider()

            ShortcutListView(
                file: store.filteredFile,
                query: store.searchQuery,
                collapsedCategories: appState.collapsedCategories,
                onToggleCategory: { appState.toggleCategory($0) },
                selectedIndex: $selectedIndex
            )

            Divider()

            SettingsFooterView(appState: appState)
        }
        .toast(appState.toastMessage)
        .frame(
            width: AppConstants.popoverWidth,
            height: AppConstants.popoverHeight
        )
        .onAppear {
            isSearchFocused = true
            selectedIndex = 0
        }
        .onChange(of: store.searchQuery) {
            clampSelection()
        }
        .onChange(of: appState.collapsedCategories) {
            clampSelection()
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
            switchTab(by: -1)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            switchTab(by: 1)
            return .handled
        }
        .onKeyPress(.return) {
            copySelectedKey()
            return .handled
        }
        .onKeyPress(.tab) {
            switchTab(by: 1)
            return .handled
        }
        .onKeyPress(characters: .init(charactersIn: "e")) { press in
            if press.modifiers.contains(.command) {
                appState.toggleViewMode()
                return .handled
            }
            return .ignored
        }
        .onKeyPress(characters: .init(charactersIn: "f")) { press in
            if press.modifiers.contains(.command) {
                isSearchFocused = true
                return .handled
            }
            return .ignored
        }
        .onKeyPress(characters: .init(charactersIn: "123456789")) { press in
            if press.modifiers.contains(.command) {
                let char = press.characters.first!
                if let num = char.wholeNumberValue, num >= 1 {
                    switchToTab(index: num - 1)
                    return .handled
                }
            }
            return .ignored
        }
    }

    private var allVisibleShortcuts: [Shortcut] {
        guard let file = store.filteredFile else { return [] }
        return file.categories
            .filter { !appState.isCategoryCollapsed($0.name) }
            .flatMap(\.shortcuts)
    }

    private func moveSelection(by delta: Int) {
        let count = allVisibleShortcuts.count
        guard count > 0 else { return }
        let newIndex = selectedIndex + delta
        selectedIndex = max(0, min(newIndex, count - 1))
    }

    private func clampSelection() {
        let count = allVisibleShortcuts.count
        if count == 0 {
            selectedIndex = 0
        } else if selectedIndex >= count {
            selectedIndex = count - 1
        }
    }

    private func switchTab(by delta: Int) {
        let ordered = store.orderedFiles
        guard !ordered.isEmpty else { return }
        guard let currentIndex = ordered.firstIndex(where: { $0.app == store.selectedApp }) else { return }
        let newIndex = (currentIndex + delta + ordered.count) % ordered.count
        store.selectApp(ordered[newIndex].app)
        selectedIndex = 0
    }

    private func switchToTab(index: Int) {
        let ordered = store.orderedFiles
        guard index < ordered.count else { return }
        store.selectApp(ordered[index].app)
        selectedIndex = 0
    }

    private func copySelectedKey() {
        let shortcuts = allVisibleShortcuts
        guard selectedIndex >= 0, selectedIndex < shortcuts.count else { return }
        let shortcut = shortcuts[selectedIndex]
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(shortcut.key, forType: .string)
        appState.showToast(.copied())
    }
}
