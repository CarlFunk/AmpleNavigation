// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Navigation",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Navigation",
            targets: ["Navigation"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Navigation",
            dependencies: []),
        .testTarget(
            name: "NavigationTests",
            dependencies: [
                .target(name: "Navigation")
            ])
    ]
)
