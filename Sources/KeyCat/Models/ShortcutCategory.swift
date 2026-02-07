import Foundation

struct ShortcutCategory: Identifiable, Codable, Equatable {
    let name: String
    let shortcuts: [Shortcut]

    var id: String { name }
}
