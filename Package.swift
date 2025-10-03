// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "AmpleNavigation",
    platforms: [
        .iOS(.v18)
    ],
    products: [
        .library(
            name: "AmpleNavigation",
            targets: ["AmpleNavigation"])
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
