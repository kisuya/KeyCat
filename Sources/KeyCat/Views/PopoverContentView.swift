import SwiftUI

struct PopoverContentView: View {
    @Bindable var store: ShortcutStore
    @FocusState private var isSearchFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(
                query: $store.searchQuery,
                isFocused: $isSearchFocused
            )

            TabBarView(
                apps: store.files,
                selectedApp: Binding(
                    get: { store.selectedApp },
                    set: { store.selectApp($0) }
                )
            )

            Divider()

            ShortcutListView(
                file: store.filteredFile,
                query: store.searchQuery
            )

            Divider()

            SettingsFooterView()
        }
        .frame(
            width: AppConstants.popoverWidth,
            height: AppConstants.popoverHeight
        )
        .onAppear {
            isSearchFocused = true
        }
    }
}
