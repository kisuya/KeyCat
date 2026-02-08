import PackagePlugin
import Foundation

@main
struct SyncShortcuts: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
        let scriptPath = context.package.directory.appending("Scripts").appending("sync-shortcuts.sh")
        return [
            .prebuildCommand(
                displayName: "Sync shortcut YAMLs from shortcuts/ to Resources/Defaults/",
                executable: .init("/bin/bash"),
                arguments: [scriptPath.string],
                environment: ["PACKAGE_DIR": context.package.directory.string],
                outputFilesDirectory: context.pluginWorkDirectory
            )
        ]
    }
}
