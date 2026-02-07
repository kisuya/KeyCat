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

final class YAMLLoader {
    func loadBundledFiles() -> [ShortcutFile] {
        guard let resourceURL = Bundle.module.url(
            forResource: "Defaults",
            withExtension: nil
        ) else {
            return []
        }

        return loadFilesFromDirectory(resourceURL)
    }

    func loadUserFiles() -> [ShortcutFile] {
        let userDir = AppConstants.userConfigDirectory
        guard FileManager.default.fileExists(atPath: userDir.path) else {
            return []
        }
        return loadFilesFromDirectory(userDir)
    }

    func loadAllFiles() -> [(file: ShortcutFile, source: ShortcutSource)] {
        let bundled = loadBundledFiles().map { (file: $0, source: ShortcutSource.bundled) }
        let user = loadUserFiles().map { (file: $0, source: ShortcutSource.user) }

        var result: [(file: ShortcutFile, source: ShortcutSource)] = []
        var seenApps: Set<String> = []

        for item in user {
            seenApps.insert(item.file.app.lowercased())
            result.append(item)
        }

        for item in bundled where !seenApps.contains(item.file.app.lowercased()) {
            result.append(item)
        }

        return result
    }

    func parseYAML(from data: Data) throws -> ShortcutFile {
        let decoder = YAMLDecoder()
        return try decoder.decode(ShortcutFile.self, from: data)
    }

    private func loadFilesFromDirectory(_ directory: URL) -> [ShortcutFile] {
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
            return ext == AppConstants.yamlExtension || ext == AppConstants.ymlExtension
        }

        return yamlFiles.compactMap { url in
            guard let data = try? Data(contentsOf: url) else { return nil }
            return try? parseYAML(from: data)
        }
    }
}
