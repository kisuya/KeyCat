import Testing
@testable import KeyCat

@Suite("ShortcutStore Tests")
struct ShortcutStoreTests {

    @Test("Loads all bundled files")
    func loadAll() {
        let store = ShortcutStore()
        store.loadAll()

        #expect(!store.files.isEmpty)
        #expect(!store.appNames.isEmpty)
        #expect(!store.selectedApp.isEmpty)
    }

    @Test("Sets first app as selected by default")
    func defaultSelection() {
        let store = ShortcutStore()
        store.loadAll()

        #expect(store.selectedApp == store.files[0].app)
    }

    @Test("Selects specific app")
    func selectApp() {
        let store = ShortcutStore()
        store.loadAll()

        let targetApp = "neovim"
        store.selectApp(targetApp)
        #expect(store.selectedApp == targetApp)
    }

    @Test("Returns selected file")
    func selectedFile() {
        let store = ShortcutStore()
        store.loadAll()
        store.selectApp("tmux")

        let file = store.selectedFile
        #expect(file != nil)
        #expect(file?.app == "tmux")
    }

    @Test("Filters by search query")
    func searchFilter() {
        let store = ShortcutStore()
        store.loadAll()
        store.selectApp("tmux")
        store.searchQuery = "detach"

        let filtered = store.filteredFile
        #expect(filtered != nil)
        #expect(filtered?.categories.count == 1)
    }

    @Test("Reload preserves selected app")
    func reloadPreservesSelection() {
        let store = ShortcutStore()
        store.loadAll()
        store.selectApp("neovim")
        store.reload()

        #expect(store.selectedApp == "neovim")
    }
}
