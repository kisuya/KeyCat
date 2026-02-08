import Foundation
import Yams

final class ConfigLoader {
    private let configURL: URL

    init(configURL: URL? = nil) {
        self.configURL = configURL ?? AppConstants.configFilePath
    }

    func load() -> AppConfig {
        guard FileManager.default.fileExists(atPath: configURL.path),
              let data = try? Data(contentsOf: configURL),
              let config = try? YAMLDecoder().decode(AppConfig.self, from: data) else {
            return loadBundledConfig()
        }
        return config
    }

    private func loadBundledConfig() -> AppConfig {
        guard let bundleURL = Bundle.module.url(
            forResource: "config",
            withExtension: "yaml",
            subdirectory: "Defaults"
        ),
        let data = try? Data(contentsOf: bundleURL),
        let config = try? YAMLDecoder().decode(AppConfig.self, from: data) else {
            return .default
        }
        return config
    }
}
