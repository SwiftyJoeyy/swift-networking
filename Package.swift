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
        .visionOS(.v1),
        .macCatalyst(.v15)
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
        .target(
            name: "Networking",
            dependencies: [
                "NetworkingCore",
                "NetworkingClient"
            ],
            swiftSettings: networkingSwiftSettings
        ),
        
        .target(
            name: "NetworkingCore",
            dependencies: ["NetworkingCoreMacros"],
            swiftSettings: networkingSwiftSettings
        ),
        .testTarget(
            name: "NetworkingCoreTests",
            dependencies: ["NetworkingCore"],
            swiftSettings: networkingSwiftSettings
        ),
        
        .macro(
            name: "NetworkingCoreMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacrosKit", package: "MacrosKit"),
            ],
            swiftSettings: networkingSwiftSettings
        ),
        .testTarget(
            name: "NetworkingCoreMacrosTests",
            dependencies: [
                "NetworkingCoreMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: networkingSwiftSettings
        ),
        
        .target(
            name: "NetworkingClient",
            dependencies: ["NetworkingCore", "NetworkingClientMacros"],
            swiftSettings: networkingSwiftSettings
        ),
        .testTarget(
            name: "NetworkingClientTests",
            dependencies: ["NetworkingClient"],
            swiftSettings: networkingSwiftSettings
        ),
        
        .macro(
            name: "NetworkingClientMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "MacrosKit", package: "MacrosKit"),
            ],
            swiftSettings: networkingSwiftSettings
        ),
        .testTarget(
            name: "NetworkingClientMacrosTests",
            dependencies: [
                "NetworkingClientMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: networkingSwiftSettings
        ),
    ]
)

var networkingSwiftSettings: [SwiftSetting] {
    return [
        .enableUpcomingFeature("ExistentialAny")
    ]
}
