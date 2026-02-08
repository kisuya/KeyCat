import SwiftUI

struct WideContentView: View {
    @Bindable var appState: AppState
    let onClose: () -> Void
    @FocusState private var isSearchFocused: Bool
    @State private var filterApp: String? = nil

    private var store: ShortcutStore { appState.store }

    private var displayFiles: [ShortcutFile] {
        let all = store.allFilteredFiles
        if let filterApp {
            return all.filter { $0.app == filterApp }
        }
        return all
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
                files: displayFiles,
                collapsedCategories: appState.collapsedCategories,
                onToggleCategory: { appState.toggleCategory($0) }
            )

            Divider()

            SettingsFooterView(appState: appState)
        }
        .toast(appState.toastMessage)
        .onKeyPress(.escape) {
            onClose()
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
