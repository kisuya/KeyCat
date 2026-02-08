import Foundation

enum TemplateGenerator {
    static func generate(appName: String) -> String {
        """
        app: \(appName)
        # prefix: "Ctrl+a"
        # icon: "app.dashed"
        categories:
          - name: General
            shortcuts:
              - key: ""
                desc: ""
        """
    }

    @discardableResult
    static func writeTemplate(appName: String, updateConfig: Bool = true) throws -> URL {
        let fileName = "\(appName.lowercased()).yaml"
        let directory = AppConstants.userConfigDirectory
        let fileURL = directory.appendingPathComponent(fileName)

        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: directory.path) {
            try fileManager.createDirectory(
                at: directory,
                withIntermediateDirectories: true
            )
        }

        let content = generate(appName: appName)
        try content.write(to: fileURL, atomically: true, encoding: .utf8)

        if updateConfig {
            addToTabOrder(appName: appName)
        }

        return fileURL
    }

    private static func addToTabOrder(appName: String) {
        let configURL = AppConstants.configFilePath
        guard var content = try? String(contentsOf: configURL, encoding: .utf8) else { return }

        // tab_order 섹션에 앱 이름 추가
        let entry = "  - \(appName)"
        if content.contains("tab_order:") {
            // 이미 존재하면 추가하지 않음
            if content.contains(entry) { return }

            // tab_order: 다음 줄들 (- 로 시작)이 끝나는 지점에 삽입
            let lines = content.components(separatedBy: "\n")
            var newLines: [String] = []
            var inserted = false
            var inTabOrder = false

            for line in lines {
                if line.hasPrefix("tab_order:") {
                    inTabOrder = true
                    newLines.append(line)
                    continue
                }
                if inTabOrder {
                    if line.trimmingCharacters(in: .whitespaces).hasPrefix("- ") {
                        newLines.append(line)
                        continue
                    } else {
                        // tab_order 항목이 끝난 지점에 새 항목 삽입
                        newLines.append(entry)
                        inserted = true
                        inTabOrder = false
                    }
                }
                newLines.append(line)
            }
            // 파일 끝까지 tab_order 항목이면
            if !inserted {
                newLines.append(entry)
            }
            content = newLines.joined(separator: "\n")
        } else {
            // tab_order 섹션이 없으면 맨 앞에 추가
            content = "tab_order:\n\(entry)\n\n" + content
        }

        try? content.write(to: configURL, atomically: true, encoding: .utf8)
    }
}
