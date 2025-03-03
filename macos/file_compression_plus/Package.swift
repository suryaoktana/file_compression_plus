// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "file_compression_plus",
    platforms: [.macOS(.v10_14), .iOS(.v13)],
    products: [
        .library(
            name: "file_compression_plus",
            targets: ["file_compression_plus"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/flutter/flutter.git", .branch("main")),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "file_compression_plus",
            dependencies: [
                .product(name: "FlutterMacOS", package: "flutter"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: ".",
            sources: ["Classes"],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),
        .target(
            name: "file_compression_plus_ios",
            dependencies: [
                .product(name: "Flutter", package: "flutter"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "../ios",
            sources: ["Classes"],
            resources: [
                .copy("Resources")
            ],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        )
    ]
)