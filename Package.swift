// swift-tools-version: 6.0

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "Networking",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .watchOS(.v8),
        .tvOS(.v15),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "Networking",
            targets: [
                "Networking"
            ]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/buildexperience/MacrosKit.git",
            from: "1.0.0"
        ),
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "600.0.0"
        ),
    ],
    targets: [
        .macro(
            name: "NetworkingMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacrosKit", package: "MacrosKit"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "NetworkingMacrosTests",
            dependencies: [
                "NetworkingMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        
        .target(
            name: "Networking",
            dependencies: ["NetworkingMacros"],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"],
            swiftSettings: [
                .enableUpcomingFeature("ExistentialAny")
            ]
        ),
    ]
)
