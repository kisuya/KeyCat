import Testing
@testable import KeyCat

@Suite("SearchEngine Tests")
struct SearchEngineTests {

    private let sampleFiles: [ShortcutFile] = [
        ShortcutFile(
            app: "tmux",
            prefix: "Ctrl+a",
            icon: "terminal",
            categories: [
                ShortcutCategory(name: "세션", shortcuts: [
                    Shortcut(key: "prefix + d", desc: "detach (세션 유지하고 나가기)"),
                    Shortcut(key: "prefix + s", desc: "세션 목록/전환"),
                ]),
                ShortcutCategory(name: "윈도우", shortcuts: [
                    Shortcut(key: "prefix + c", desc: "새 윈도우 생성"),
                    Shortcut(key: "prefix + n", desc: "다음 윈도우"),
                ]),
            ]
        )
    ]

    @Test("Returns all files for empty query")
    func emptyQuery() {
        let results = SearchEngine.search(files: sampleFiles, query: "")
        #expect(results.count == 1)
        #expect(results[0].categories.count == 2)
    }

    @Test("Filters by description keyword")
    func filterByDesc() {
        let results = SearchEngine.search(files: sampleFiles, query: "detach")
        #expect(results.count == 1)
        #expect(results[0].categories.count == 1)
        #expect(results[0].categories[0].shortcuts.count == 1)
        #expect(results[0].categories[0].shortcuts[0].desc.contains("detach"))
    }

    @Test("Filters by key")
    func filterByKey() {
        let results = SearchEngine.search(files: sampleFiles, query: "prefix + c")
        #expect(results.count == 1)
        #expect(results[0].categories[0].shortcuts[0].key == "prefix + c")
    }

    @Test("Case insensitive search")
    func caseInsensitive() {
        let results = SearchEngine.search(files: sampleFiles, query: "DETACH")
        #expect(results.count == 1)
    }

    @Test("Category name match includes all shortcuts in category")
    func categoryNameMatch() {
        let results = SearchEngine.search(files: sampleFiles, query: "윈도우")
        #expect(results.count == 1)
        #expect(results[0].categories.count == 1)
        #expect(results[0].categories[0].name == "윈도우")
        #expect(results[0].categories[0].shortcuts.count == 2)
    }

    @Test("Returns empty for no matches")
    func noMatches() {
        let results = SearchEngine.search(files: sampleFiles, query: "xyznonexistent")
        #expect(results.isEmpty)
    }

    @Test("Whitespace-only query returns all")
    func whitespaceQuery() {
        let results = SearchEngine.search(files: sampleFiles, query: "   ")
        #expect(results.count == 1)
    }
}
