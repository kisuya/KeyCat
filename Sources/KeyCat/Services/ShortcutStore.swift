import Foundation
import SwiftUI

@Observable
final class ShortcutStore {
    private(set) var files: [ShortcutFile] = []
    private(set) var selectedApp: String = ""
    var searchQuery: String = ""

    private let loader = YAMLLoader()

    var appNames: [String] {
        files.map(\.app)
    }

    var selectedFile: ShortcutFile? {
        files.first { $0.app == selectedApp }
    }

    var filteredFile: ShortcutFile? {
        guard let selected = selectedFile else { return nil }
        let results = SearchEngine.search(files: [selected], query: searchQuery)
        return results.first
    }

    func loadAll() {
        let loaded = loader.loadAllFiles()
        files = loaded.map(\.file)

        if !files.isEmpty, !appNames.contains(selectedApp) {
            selectedApp = files[0].app
        }
    }

    func selectApp(_ app: String) {
        selectedApp = app
    }

    func reload() {
        let previousApp = selectedApp
        loadAll()
        if appNames.contains(previousApp) {
            selectedApp = previousApp
        }
    }
}
