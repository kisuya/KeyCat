import Foundation

enum InitialSetup {
    private static let setupCompleteKey = "KeyCat.initialSetupComplete"

    static var isFirstLaunch: Bool {
        !UserDefaults.standard.bool(forKey: setupCompleteKey)
    }

    static func performIfNeeded() {
        ensureConfigDirectoryExists()
        copyDefaultConfigIfNeeded()

        if isFirstLaunch {
            copyBundledShortcuts()
            UserDefaults.standard.set(true, forKey: setupCompleteKey)
        }
    }

    static func ensureConfigDirectoryExists() {
        let dir = AppConstants.userConfigDirectory
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: dir.path) {
            try? fileManager.createDirectory(at: dir, withIntermediateDirectories: true)
        }
    }

    static func copyDefaultConfigIfNeeded() {
        let configPath = AppConstants.configFilePath
        let fileManager = FileManager.default

        guard !fileManager.fileExists(atPath: configPath.path) else { return }

        guard let bundleURL = Bundle.module.url(
            forResource: "config",
            withExtension: "yaml",
            subdirectory: "Defaults"
        ) else { return }

        try? fileManager.copyItem(at: bundleURL, to: configPath)
    }

    static func copyBundledShortcuts() {
        guard let resourceURL = Bundle.module.url(
            forResource: "Defaults",
            withExtension: nil
        ) else { return }

        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: resourceURL,
            includingPropertiesForKeys: nil,
            options: .skipsHiddenFiles
        ) else { return }

        let userDir = AppConstants.userConfigDirectory
        let yamlFiles = files.filter { url in
            let ext = url.pathExtension.lowercased()
            let isYAML = ext == AppConstants.yamlExtension || ext == AppConstants.ymlExtension
            let isConfig = url.lastPathComponent == AppConstants.configFileName
            return isYAML && !isConfig
        }

        for file in yamlFiles {
            let destURL = userDir.appendingPathComponent(file.lastPathComponent)
            if !fileManager.fileExists(atPath: destURL.path) {
                try? fileManager.copyItem(at: file, to: destURL)
            }
        }
    }
}
