// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FitMeCore",
    platforms: [
        .iOS(.v17),
        .watchOS(.v10),
    ],
    products: [
        .library(name: "FitMeCore", targets: ["FitMeCore"]),
    ],
    targets: [
        .target(
            name: "FitMeCore",
            path: "Sources/FitMeCore",
            resources: [
                .process("ML/FitMeML.bin"),
            ]
        ),
        .testTarget(
            name: "FitMeCoreTests",
            dependencies: ["FitMeCore"],
            path: "Tests/FitMeCoreTests",
            resources: [
                .process("Resources"),
            ]
        ),
    ]
)