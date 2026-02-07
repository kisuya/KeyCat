import Foundation

struct ShortcutFile: Identifiable, Codable, Equatable {
    let app: String
    let prefix: String?
    let icon: String?
    let categories: [ShortcutCategory]

    var id: String { app }
}
