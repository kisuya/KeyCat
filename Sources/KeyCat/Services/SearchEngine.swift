import Foundation

enum SearchEngine {
    static func search(
        files: [ShortcutFile],
        query: String
    ) -> [ShortcutFile] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return files }

        let lowered = trimmed.lowercased()

        return files.compactMap { file in
            let filteredCategories = file.categories.compactMap { category -> ShortcutCategory? in
                let categoryNameMatch = category.name.lowercased().contains(lowered)

                let matchingShortcuts = category.shortcuts.filter { shortcut in
                    if categoryNameMatch { return true }
                    let keyMatch = shortcut.key.lowercased().contains(lowered)
                    let descMatch = shortcut.desc.lowercased().contains(lowered)
                    return keyMatch || descMatch
                }

                guard !matchingShortcuts.isEmpty else { return nil }
                return ShortcutCategory(name: category.name, shortcuts: matchingShortcuts)
            }

            guard !filteredCategories.isEmpty else { return nil }
            return ShortcutFile(
                app: file.app,
                prefix: file.prefix,
                icon: file.icon,
                categories: filteredCategories
            )
        }
    }
}
