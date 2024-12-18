// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "h-codegen",
    platforms: [.macOS(.v10_15)],
    products: [
        .executable(name: "h-codegen", targets: ["HCodegen"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "510.0.3"),
        .package(url: "https://github.com/tuist/XcodeProj.git", from: "8.24.4"),
        .package(url: "https://github.com/jakeheis/SwiftCLI", from: "6.0.0"),
        .package(url: "https://github.com/kylef/PathKit.git", from: "1.0.1")
    ],
    targets: [
        .executableTarget(
            name: "HCodegen",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "XcodeProj", package: "XcodeProj"),
                .product(name: "SwiftCLI", package: "SwiftCLI"),
                .product(name: "PathKit", package: "PathKit")
            ],
            resources: [
                .copy("Resources/emit_objc_header.sh")
            ]
        ),
    ]
)
