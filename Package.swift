// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "todobackend",
    products: [
        .executable(name: "todobackend", targets: ["todobackend"]),
        .library(name: "todolib", targets: ["todolib"])
    ],
    dependencies: [
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter.git", .upToNextMajor(from: "1.5.0"))
    ],
    targets: [
        .target(
            name: "todobackend",
            dependencies: ["Swifter", "todolib"]),
        .target(name: "todolib"),
        .testTarget(
            name: "todobackendTests",
            dependencies: ["todolib"]),
    ]
)
