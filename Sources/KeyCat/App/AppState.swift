import Foundation

@Observable
final class AppState {
    let store = ShortcutStore()
    private var fileWatcher: FileWatcher?

    func setup() {
        store.loadAll()

        fileWatcher = FileWatcher(
            directory: AppConstants.userConfigDirectory
        ) { [weak self] in
            self?.store.reload()
        }
        fileWatcher?.start()
    }

    func teardown() {
        fileWatcher?.stop()
        fileWatcher = nil
    }
}
