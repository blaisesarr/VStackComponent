// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "VStackComponent",
    products: [
        .library(
            name: "VStackComponent",
            targets: ["VStackComponent"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "VStackComponent",
            dependencies: []),
        .testTarget(
            name: "VStackComponentTests",
            dependencies: ["VStackComponent"]),
    ]
)
