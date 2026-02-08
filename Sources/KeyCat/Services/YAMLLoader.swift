import Foundation
import Yams

enum YAMLLoaderError: Error, LocalizedError {
    case fileNotFound(String)
    case parsingFailed(String, Error)
    case bundleNotFound

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "YAML file not found: \(path)"
        case .parsingFailed(let path, let error):
            return "Failed to parse YAML at \(path): \(error.localizedDescription)"
        case .bundleNotFound:
            return "Bundle resource directory not found"
        }
    }
}

struct YAMLLoadResult {
    let files: [(file: ShortcutFile, source: ShortcutSource)]
    let errors: [YAMLLoadError]
}

final class YAMLLoader {
    func loadBundledFiles() -> [ShortcutFile] {
        guard let resourceURL = Bundle.module.url(
            forResource: "Defaults",
            withExtension: nil
        ) else {
            return []
        }

        return loadFilesFromDirectory(resourceURL).compactMap { $0.file }
    }

    func loadUserFiles() -> (files: [ShortcutFile], errors: [YAMLLoadError]) {
        let userDir = AppConstants.userConfigDirectory
        guard FileManager.default.fileExists(atPath: userDir.path) else {
            return ([], [])
        }
        let results = loadFilesFromDirectory(userDir)
        let files = results.compactMap(\.file)
        let errors = results.compactMap(\.error)
        return (files, errors)
    }

    func loadAllFiles() -> YAMLLoadResult {
        let bundled = loadBundledFiles().map { (file: $0, source: ShortcutSource.bundled) }
        let userResult = loadUserFiles()
        let user = userResult.files.map { (file: $0, source: ShortcutSource.user) }

        var result: [(file: ShortcutFile, source: ShortcutSource)] = []
        var seenApps: Set<String> = []

        for item in user {
            seenApps.insert(item.file.app.lowercased())
            result.append(item)
        }

        for item in bundled where !seenApps.contains(item.file.app.lowercased()) {
            result.append(item)
        }

        return YAMLLoadResult(files: result, errors: userResult.errors)
    }

    func parseYAML(from data: Data) throws -> ShortcutFile {
        let decoder = YAMLDecoder()
        return try decoder.decode(ShortcutFile.self, from: data)
    }

    private struct LoadEntry {
        let file: ShortcutFile?
        let error: YAMLLoadError?
    }

    private func loadFilesFromDirectory(_ directory: URL) -> [LoadEntry] {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else {
            return []
        }

        let yamlFiles = files.filter { url in
            let ext = url.pathExtension.lowercased()
            let isYAML = ext == AppConstants.yamlExtension || ext == AppConstants.ymlExtension
            let isConfig = url.lastPathComponent == AppConstants.configFileName
            return isYAML && !isConfig
        }

        return yamlFiles.map { url in
            let fileName = url.lastPathComponent

            guard let data = try? Data(contentsOf: url) else {
                return LoadEntry(
                    file: nil,
                    error: YAMLLoadError(fileName: fileName, message: "파일을 읽을 수 없습니다.")
                )
            }

            let validation = YAMLValidator.validate(data: data, fileName: fileName)
            if validation.isValid, let file = validation.file {
                return LoadEntry(file: file, error: nil)
            } else {
                let message = validation.errors.joined(separator: "\n")
                return LoadEntry(
                    file: nil,
                    error: YAMLLoadError(fileName: fileName, message: message)
                )
            }
        }
    }
}
