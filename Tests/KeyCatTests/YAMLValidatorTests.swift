import Testing
import Foundation
@testable import KeyCat

@Suite("YAMLValidator Tests")
struct YAMLValidatorTests {

    @Test("Valid YAML passes validation")
    func validYAML() {
        let yaml = """
        app: test-app
        prefix: "Ctrl+b"
        categories:
          - name: "기본"
            shortcuts:
              - key: "Ctrl+c"
                desc: "복사"
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "test.yaml")

        #expect(result.isValid)
        #expect(result.file != nil)
        #expect(result.file?.app == "test-app")
        #expect(result.errors.isEmpty)
    }

    @Test("Empty file fails validation")
    func emptyFile() {
        let result = YAMLValidator.validate(data: Data("".utf8), fileName: "empty.yaml")

        #expect(!result.isValid)
        #expect(result.errors.count == 1)
        #expect(result.errors[0].contains("비어있습니다"))
    }

    @Test("Missing app field fails validation")
    func missingApp() {
        let yaml = """
        categories:
          - name: "기본"
            shortcuts:
              - key: "q"
                desc: "종료"
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "no-app.yaml")

        #expect(!result.isValid)
        #expect(result.errors.contains(where: { $0.contains("'app'") }))
    }

    @Test("Missing categories field fails validation")
    func missingCategories() {
        let yaml = """
        app: test-app
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "no-cat.yaml")

        #expect(!result.isValid)
        #expect(result.errors.contains(where: { $0.contains("'categories'") }))
    }

    @Test("Missing shortcut key field reports error")
    func missingShortcutKey() {
        let yaml = """
        app: test-app
        categories:
          - name: "기본"
            shortcuts:
              - desc: "설명만"
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "no-key.yaml")

        #expect(!result.isValid)
        #expect(result.errors.contains(where: { $0.contains("'key'") }))
    }

    @Test("Missing shortcut desc field reports error")
    func missingShortcutDesc() {
        let yaml = """
        app: test-app
        categories:
          - name: "기본"
            shortcuts:
              - key: "Ctrl+c"
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "no-desc.yaml")

        #expect(!result.isValid)
        #expect(result.errors.contains(where: { $0.contains("'desc'") }))
    }

    @Test("Invalid YAML syntax fails validation")
    func invalidSyntax() {
        let yaml = "not: [valid: yaml: structure"
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "broken.yaml")

        #expect(!result.isValid)
        #expect(!result.errors.isEmpty)
    }

    @Test("Minimal valid YAML passes")
    func minimalValid() {
        let yaml = """
        app: minimal
        categories:
          - name: General
            shortcuts:
              - key: "q"
                desc: "quit"
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "minimal.yaml")

        #expect(result.isValid)
        #expect(result.file?.app == "minimal")
    }

    @Test("Category without name fails validation")
    func categoryWithoutName() {
        let yaml = """
        app: test-app
        categories:
          - shortcuts:
              - key: "q"
                desc: "quit"
        """
        let result = YAMLValidator.validate(data: Data(yaml.utf8), fileName: "no-name.yaml")

        #expect(!result.isValid)
        #expect(result.errors.contains(where: { $0.contains("'name'") }))
    }
}
