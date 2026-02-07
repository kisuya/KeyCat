import Foundation

struct Shortcut: Identifiable, Codable, Equatable {
    let key: String
    let desc: String

    var id: String { "\(key)-\(desc)" }
}
