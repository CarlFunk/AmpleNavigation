// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "AmpleNavigation",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "AmpleNavigation",
            targets: ["AmpleNavigation"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "AmpleNavigation",
            dependencies: []),
        .testTarget(
            name: "AmpleNavigationTests",
            dependencies: [
                .target(name: "AmpleNavigation")
            ])
    ]
)
