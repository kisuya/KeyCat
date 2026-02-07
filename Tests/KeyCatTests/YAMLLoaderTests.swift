import Testing
import Foundation
@testable import KeyCat

@Suite("YAMLLoader Tests")
struct YAMLLoaderTests {

    private let validYAML = """
    app: test-app
    prefix: "Ctrl+b"
    icon: "terminal"
    categories:
      - name: "기본"
        shortcuts:
          - key: "prefix + d"
            desc: "detach"
          - key: "prefix + c"
            desc: "새로 만들기"
    """

    private let minimalYAML = """
    app: minimal
    categories:
      - name: "기본"
        shortcuts:
          - key: "q"
            desc: "종료"
    """

    @Test("Parses valid YAML")
    func parseValid() throws {
        let loader = YAMLLoader()
        let data = Data(validYAML.utf8)
        let file = try loader.parseYAML(from: data)

        #expect(file.app == "test-app")
        #expect(file.prefix == "Ctrl+b")
        #expect(file.icon == "terminal")
        #expect(file.categories.count == 1)
        #expect(file.categories[0].name == "기본")
        #expect(file.categories[0].shortcuts.count == 2)
        #expect(file.categories[0].shortcuts[0].key == "prefix + d")
        #expect(file.categories[0].shortcuts[0].desc == "detach")
    }

    @Test("Parses minimal YAML without optional fields")
    func parseMinimal() throws {
        let loader = YAMLLoader()
        let data = Data(minimalYAML.utf8)
        let file = try loader.parseYAML(from: data)

        #expect(file.app == "minimal")
        #expect(file.prefix == nil)
        #expect(file.icon == nil)
        #expect(file.categories.count == 1)
    }

    @Test("Throws on invalid YAML")
    func parseInvalid() {
        let loader = YAMLLoader()
        let data = Data("not: [valid: yaml: structure".utf8)

        #expect(throws: Error.self) {
            try loader.parseYAML(from: data)
        }
    }

    @Test("Loads bundled default files")
    func loadBundled() {
        let loader = YAMLLoader()
        let files = loader.loadBundledFiles()

        #expect(!files.isEmpty)

        let appNames = files.map(\.app)
        #expect(appNames.contains("tmux"))
        #expect(appNames.contains("neovim"))
        #expect(appNames.contains("yazi"))
        #expect(appNames.contains("lazygit"))
    }
}
