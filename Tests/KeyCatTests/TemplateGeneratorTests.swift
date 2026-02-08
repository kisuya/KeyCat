import Testing
import Foundation
@testable import KeyCat

@Suite("TemplateGenerator Tests")
struct TemplateGeneratorTests {

    @Test("Generates valid template string")
    func generateTemplate() {
        let template = TemplateGenerator.generate(appName: "docker")

        #expect(template.contains("app: docker"))
        #expect(template.contains("categories:"))
        #expect(template.contains("shortcuts:"))
        #expect(template.contains("key:"))
        #expect(template.contains("desc:"))
    }

    @Test("Writes template file to disk")
    func writeTemplate() throws {
        let appName = "test_template_\(UUID().uuidString.prefix(8))"
        let url = try TemplateGenerator.writeTemplate(appName: appName, updateConfig: false)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(FileManager.default.fileExists(atPath: url.path))

        let content = try String(contentsOf: url, encoding: .utf8)
        #expect(content.contains("app: \(appName)"))
    }

    @Test("Template filename is lowercase")
    func lowercaseFilename() throws {
        let appName = "MyApp"
        let url = try TemplateGenerator.writeTemplate(appName: appName, updateConfig: false)
        defer { try? FileManager.default.removeItem(at: url) }

        #expect(url.lastPathComponent == "myapp.yaml")
    }
}
