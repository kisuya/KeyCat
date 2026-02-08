import Testing
import Foundation
@testable import KeyCat

@Suite("ConfigLoader Tests")
struct ConfigLoaderTests {

    @Test("Loads bundled config with default values")
    func loadBundledConfig() {
        let loader = ConfigLoader(configURL: URL(fileURLWithPath: "/nonexistent/config.yaml"))
        let config = loader.load()

        #expect(!config.tabOrder.isEmpty)
        #expect(config.hotkey.key == "k")
        #expect(config.hotkey.modifiers.contains("ctrl"))
        #expect(config.hotkey.modifiers.contains("shift"))
        #expect(config.preferences.defaultView == "compact")
    }

    @Test("Returns default config when file is missing")
    func missingFileReturnsDefault() {
        let loader = ConfigLoader(configURL: URL(fileURLWithPath: "/tmp/nonexistent_keycat_config.yaml"))
        let config = loader.load()

        #expect(config.hotkey.key == "k")
        #expect(config.preferences.defaultView == "compact")
    }

    @Test("AppConfig default values are correct")
    func defaultValues() {
        let config = AppConfig.default

        #expect(config.tabOrder.isEmpty)
        #expect(config.hotkey.key == "k")
        #expect(config.hotkey.modifiers == ["ctrl", "shift"])
        #expect(config.preferences.defaultView == "compact")
    }

    @Test("Loads custom config from temp file")
    func loadCustomConfig() throws {
        let tempDir = FileManager.default.temporaryDirectory
        let configURL = tempDir.appendingPathComponent("test_keycat_config.yaml")
        let yaml = """
        tab_order:
          - yazi
          - tmux
        hotkey:
          key: "j"
          modifiers: ["ctrl", "shift"]
        preferences:
          default_view: wide
        """
        try yaml.write(to: configURL, atomically: true, encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: configURL) }

        let loader = ConfigLoader(configURL: configURL)
        let config = loader.load()

        #expect(config.tabOrder == ["yazi", "tmux"])
        #expect(config.hotkey.key == "j")
        #expect(config.hotkey.modifiers == ["ctrl", "shift"])
        #expect(config.preferences.defaultView == "wide")
    }
}
