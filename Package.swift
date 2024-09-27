// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "UM-SQLManager-iOS",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "UM-SQLManager-iOS",
            targets: ["UM-SQLManager-iOS"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "UM-SQLManager-iOS"),
        .testTarget(
            name: "UM-SQLManager-iOSTests",
            dependencies: ["UM-SQLManager-iOS"]),
    ]
)
