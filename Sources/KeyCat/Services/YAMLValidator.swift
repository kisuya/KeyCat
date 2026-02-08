import Foundation
import Yams

enum YAMLValidator {
    struct ValidationResult {
        let file: ShortcutFile?
        let errors: [String]

        var isValid: Bool { errors.isEmpty && file != nil }
    }

    static func validate(data: Data, fileName: String) -> ValidationResult {
        var errors: [String] = []

        // Parse raw YAML first to check structure
        guard let yamlString = String(data: data, encoding: .utf8),
              !yamlString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return ValidationResult(file: nil, errors: ["파일이 비어있습니다."])
        }

        let rawYAML: [String: Any]
        do {
            guard let parsed = try Yams.load(yaml: yamlString) as? [String: Any] else {
                return ValidationResult(file: nil, errors: ["YAML 형식이 올바르지 않습니다. 딕셔너리 구조여야 합니다."])
            }
            rawYAML = parsed
        } catch {
            return ValidationResult(file: nil, errors: ["YAML 파싱 실패: \(error.localizedDescription)"])
        }

        // Validate required field: app
        guard let app = rawYAML["app"] as? String, !app.isEmpty else {
            errors.append("필수 필드 'app'이 없거나 비어있습니다.")
            return ValidationResult(file: nil, errors: errors)
        }

        // Validate required field: categories
        guard let categories = rawYAML["categories"] as? [[String: Any]] else {
            errors.append("필수 필드 'categories'가 없거나 배열이 아닙니다.")
            return ValidationResult(file: nil, errors: errors)
        }

        // Validate each category
        for (index, category) in categories.enumerated() {
            let catNum = index + 1

            guard let name = category["name"] as? String, !name.isEmpty else {
                errors.append("카테고리 #\(catNum): 'name' 필드가 없거나 비어있습니다.")
                continue
            }

            guard let shortcuts = category["shortcuts"] as? [[String: Any]] else {
                errors.append("카테고리 '\(name)': 'shortcuts' 필드가 없거나 배열이 아닙니다.")
                continue
            }

            for (sIndex, shortcut) in shortcuts.enumerated() {
                let sNum = sIndex + 1
                if shortcut["key"] == nil {
                    errors.append("카테고리 '\(name)' 단축키 #\(sNum): 'key' 필드가 없습니다.")
                }
                if shortcut["desc"] == nil {
                    errors.append("카테고리 '\(name)' 단축키 #\(sNum): 'desc' 필드가 없습니다.")
                }
            }
        }

        // If structural validation passed, try full decode
        if errors.isEmpty {
            do {
                let decoder = YAMLDecoder()
                let file = try decoder.decode(ShortcutFile.self, from: data)
                return ValidationResult(file: file, errors: [])
            } catch {
                errors.append("디코딩 실패: \(error.localizedDescription)")
                return ValidationResult(file: nil, errors: errors)
            }
        }

        return ValidationResult(file: nil, errors: errors)
    }
}
