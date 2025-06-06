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
        .library(name: "Networking", targets: ["Networking"]),
        .library(name: "NetworkingCore", targets: ["NetworkingCore"]),
        .library(name: "NetworkingClient", targets: ["NetworkingClient"]),
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
                .product(name: "SwiftSyntax", package: "swift-syntax")
            ],
            swiftSettings: networkingSwiftSettings
        ),
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
            dependencies: ["NetworkingCoreMacros", "MacroTools"],
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
                "MacroTools",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: networkingSwiftSettings
        ),
        .testTarget(
            name: "NetworkingCoreMacrosTests",
            dependencies: [
                "NetworkingCoreMacros",
                "MacroTools",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ],
            swiftSettings: networkingSwiftSettings
        ),
        
        .target(
            name: "NetworkingClient",
            dependencies: ["NetworkingCore", "NetworkingClientMacros", "MacroTools"],
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
                "MacroTools",
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
            ],
            swiftSettings: networkingSwiftSettings
        ),
        .testTarget(
            name: "NetworkingClientMacrosTests",
            dependencies: [
                "NetworkingClientMacros",
                "MacroTools",
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
