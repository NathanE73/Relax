// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "Relax",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .executable(name: "relax", targets: ["Main"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMajor(from: "1.6.2")),
        .package(url: "https://github.com/jpsim/Yams", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/mattpolzin/OpenAPIKit", .upToNextMajor(from: "5.2.1")),
        .package(url: "https://github.com/pointfreeco/swift-snapshot-testing", .upToNextMajor(from: "1.19.2")),
    ],
    targets: [
        .target(
            name: "Main",
            dependencies: [
                "RelaxFramework",
            ]
        ),
        .target(
            name: "RelaxFramework",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "OpenAPIKit",
                "Yams",
            ]
        ),
        .testTarget(
            name: "RelaxFrameworkTests",
            dependencies: [
                .product(name: "InlineSnapshotTesting", package: "swift-snapshot-testing"),
                "RelaxFramework",
            ]
        ),
    ],
    swiftLanguageVersions: [.v5]
)
