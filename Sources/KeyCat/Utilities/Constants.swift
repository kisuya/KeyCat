import Foundation

enum AppConstants {
    static let appName = "KeyCat"
    static let popoverWidth: CGFloat = 420
    static let popoverHeight: CGFloat = 560

    static let userConfigDirectory: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".config/keycat", isDirectory: true)
    }()

    static let menuBarIcon = "keyboard.fill"
    static let defaultIcon = "app.dashed"

    static let yamlExtension = "yaml"
    static let ymlExtension = "yml"
}
