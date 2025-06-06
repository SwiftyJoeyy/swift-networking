// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "MacroTools",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1),
        .macCatalyst(.v15)
    ],
    products: [
        .library(
            name: "MacroTools",
            targets: ["MacroTools"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "601.0.1"
        ),
    ],
    targets: [
        .target(
            name: "MacroTools",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ]
        ),
    ]
)
