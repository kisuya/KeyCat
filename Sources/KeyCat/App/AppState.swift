import Foundation

@Observable
final class AppState {
    let store = ShortcutStore()
    private(set) var config = AppConfig.default
    var viewMode: ViewMode = .compact {
        didSet {
            UserDefaults.standard.set(viewMode.rawValue, forKey: Self.viewModeKey)
            if oldValue != viewMode {
                onViewModeChanged?(viewMode)
            }
        }
    }
    var onViewModeChanged: ((ViewMode) -> Void)?
    var collapsedCategories: Set<String> = []
    var showingErrors = false
    var toastMessage: ToastMessage? = nil
    private var fileWatcher: FileWatcher?
    private var toastWorkItem: DispatchWorkItem?

    private static let collapsedCategoriesKey = "KeyCat.collapsedCategories"
    private static let viewModeKey = "KeyCat.viewMode"

    var loadErrors: [YAMLLoadError] {
        store.loadErrors
    }

    var hasErrors: Bool {
        store.hasErrors
    }

    func setup() {
        InitialSetup.performIfNeeded()

        let configLoader = ConfigLoader()
        config = configLoader.load()

        // UserDefaults takes priority over config.yaml default_view
        if let savedMode = UserDefaults.standard.string(forKey: Self.viewModeKey),
           let mode = ViewMode(rawValue: savedMode) {
            viewMode = mode
        } else if config.preferences.defaultView == "wide" {
            viewMode = .wide
        }

        restoreCollapsedCategories()

        store.loadAll()
        store.applyTabOrder(config.tabOrder)

        fileWatcher = FileWatcher(
            directory: AppConstants.userConfigDirectory
        ) { [weak self] in
            self?.reloadAll()
        }
        fileWatcher?.start()
    }

    func teardown() {
        fileWatcher?.stop()
        fileWatcher = nil
    }

    func toggleViewMode() {
        viewMode = viewMode == .compact ? .wide : .compact
    }

    func toggleCategory(_ categoryID: String) {
        if collapsedCategories.contains(categoryID) {
            collapsedCategories.remove(categoryID)
        } else {
            collapsedCategories.insert(categoryID)
        }
        saveCollapsedCategories()
    }

    func isCategoryCollapsed(_ categoryID: String) -> Bool {
        collapsedCategories.contains(categoryID)
    }

    func showToast(_ message: ToastMessage, duration: TimeInterval = 1.5) {
        toastWorkItem?.cancel()
        toastMessage = message
        let workItem = DispatchWorkItem { [weak self] in
            self?.toastMessage = nil
        }
        toastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: workItem)
    }

    private func reloadAll() {
        let configLoader = ConfigLoader()
        config = configLoader.load()
        store.reload()
        store.applyTabOrder(config.tabOrder)
    }

    private func saveCollapsedCategories() {
        let array = Array(collapsedCategories)
        UserDefaults.standard.set(array, forKey: Self.collapsedCategoriesKey)
    }

    private func restoreCollapsedCategories() {
        if let array = UserDefaults.standard.stringArray(forKey: Self.collapsedCategoriesKey) {
            collapsedCategories = Set(array)
        }
    }
}
