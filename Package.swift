// swift-tools-version: 5.9

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
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "NetworkingCore", targets: ["NetworkingCore"]),
        .library(name: "NetworkingClient", targets: ["NetworkingClient"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "601.0.1"
        ),
        .package(url: "https://github.com/buildexperience/MacrosKit.git", from: "1.0.1")
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
        
// MARK: - NetworkingCore
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
        
// MARK: - NetworkingCoreMacros
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
        
// MARK: - NetworkingClient
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
        
// MARK: - NetworkingClientMacros
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
