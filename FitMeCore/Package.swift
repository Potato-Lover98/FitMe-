// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "FitMeCore",
    platforms: [
        .watchOS(.v10)
    ],
    products: [
        .library(name: "FitMeCore", targets: ["FitMeCore"]),
    ],
    targets: [
        .target(name: "FitMeCore", path: "Sources/FitMeCore"),
        .testTarget(name: "FitMeCoreTests", dependencies: ["FitMeCore"], path: "Tests/FitMeCoreTests"),
    ]
)