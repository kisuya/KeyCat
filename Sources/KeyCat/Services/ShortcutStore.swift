import Foundation
import SwiftUI

@Observable
final class ShortcutStore {
    private(set) var files: [ShortcutFile] = []
    private(set) var selectedApp: String = ""
    var searchQuery: String = ""
    private(set) var tabOrder: [String] = []
    private(set) var loadErrors: [YAMLLoadError] = []

    private let loader = YAMLLoader()

    var appNames: [String] {
        files.map(\.app)
    }

    var orderedFiles: [ShortcutFile] {
        var ordered: [ShortcutFile] = []
        for name in tabOrder {
            if let file = files.first(where: { $0.app.lowercased() == name.lowercased() }) {
                ordered.append(file)
            }
        }
        let remaining = files.filter { file in
            !tabOrder.contains(where: { $0.lowercased() == file.app.lowercased() })
        }
        ordered.append(contentsOf: remaining.sorted(by: { $0.app.localizedCaseInsensitiveCompare($1.app) == .orderedAscending }))
        return ordered
    }

    var selectedFile: ShortcutFile? {
        files.first { $0.app == selectedApp }
    }

    var filteredFile: ShortcutFile? {
        guard let selected = selectedFile else { return nil }
        let results = SearchEngine.search(files: [selected], query: searchQuery)
        return results.first
    }

    var allFilteredFiles: [ShortcutFile] {
        SearchEngine.search(files: orderedFiles, query: searchQuery)
    }

    var hasErrors: Bool {
        !loadErrors.isEmpty
    }

    func applyTabOrder(_ order: [String]) {
        tabOrder = order
        if let first = orderedFiles.first, !orderedFiles.contains(where: { $0.app == selectedApp }) {
            selectedApp = first.app
        }
    }

    func loadAll() {
        let result = loader.loadAllFiles()
        files = result.files.map(\.file)
        loadErrors = result.errors

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
        if !tabOrder.isEmpty {
            let ordered = orderedFiles
            if !ordered.isEmpty, !ordered.contains(where: { $0.app == previousApp }) {
                selectedApp = ordered[0].app
            } else {
                selectedApp = previousApp
            }
        } else if appNames.contains(previousApp) {
            selectedApp = previousApp
        }
    }
}
