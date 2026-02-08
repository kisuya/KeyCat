import Foundation

struct AppConfig: Codable, Equatable {
    var tabOrder: [String]
    var hotkey: HotkeyConfig
    var preferences: Preferences

    enum CodingKeys: String, CodingKey {
        case tabOrder = "tab_order"
        case hotkey
        case preferences
    }

    init(
        tabOrder: [String] = [],
        hotkey: HotkeyConfig = HotkeyConfig(),
        preferences: Preferences = Preferences()
    ) {
        self.tabOrder = tabOrder
        self.hotkey = hotkey
        self.preferences = preferences
    }

    static let `default` = AppConfig()
}

struct HotkeyConfig: Codable, Equatable {
    var key: String
    var modifiers: [String]

    init(key: String = "k", modifiers: [String] = ["ctrl", "shift"]) {
        self.key = key
        self.modifiers = modifiers
    }
}

struct Preferences: Codable, Equatable {
    var defaultView: String

    enum CodingKeys: String, CodingKey {
        case defaultView = "default_view"
    }

    init(defaultView: String = "compact") {
        self.defaultView = defaultView
    }
}
