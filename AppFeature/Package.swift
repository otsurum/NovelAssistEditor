// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppFeature",
    platforms: [
        .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AppFeature",
            targets: ["AppFeature", "Common", "WorkListFeature", "WorkDetailFeature", "CharacterDetailFeature", "CharacterCardListFeature", "StoryListFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../Persistance"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.10.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "Common"
        ),
        .target(
            name: "AppFeature",
            dependencies: [
                "AppCore",
                "WorkListFeature",
                "WorkDetailFeature",
            ]
        ),
        .target(
            name: "WorkListFeature",
            dependencies: [
                "AppCore",
                "Common",
                "CharacterCardListFeature",
                "StoryListFeature",
                "Persistance",
                "WorkDetailFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "WorkDetailFeature",
            dependencies: [
                "AppCore",
                "Common",
                "Persistance",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CharacterDetailFeature",
            dependencies: [
                "AppCore",
                "Common",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "CharacterCardListFeature",
            dependencies: [
                "AppCore",
                "Common",
                "CharacterDetailFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .target(
            name: "StoryListFeature",
            dependencies: [
                "AppCore",
                "Common",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "WorkListFeatureTests",
            dependencies: [
                "AppCore",
                "Persistance",
                "WorkDetailFeature",
                "WorkListFeature",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "WorkDetailFeatureTests",
            dependencies: [
                "AppCore",
                "Persistance",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
                "WorkDetailFeature",
            ]
        ),
        .testTarget(
            name: "AppFeatureTests",
            dependencies: ["AppFeature"]
        ),
    ]
)
