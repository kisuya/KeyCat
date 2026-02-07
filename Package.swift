// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "KeyCat",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.1.0")
    ],
    targets: [
        .executableTarget(
            name: "KeyCat",
            dependencies: ["Yams"],
            path: "Sources/KeyCat",
            resources: [
                .copy("Resources/Defaults")
            ]
        ),
        .testTarget(
            name: "KeyCatTests",
            dependencies: ["KeyCat", "Yams"],
            path: "Tests/KeyCatTests"
        )
    ]
)
