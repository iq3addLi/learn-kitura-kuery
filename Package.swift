// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "learn-kitura-kuery",
    products: [
        .executable(name: "learn-kitura-kuery", targets: ["Main"]),
    ],
    dependencies: [
        .package(url: "https://github.com/IBM-Swift/Kitura", from: "2.8.1"),
        .package(url: "https://github.com/IBM-Swift/SwiftKueryMySQL", from: "2.0.2"),
        .package(url: "https://github.com/IBM-Swift/Swift-Kuery-ORM", from: "0.6.1"),
    ],
    targets: [
        .target(name: "Main", dependencies: [
            "Kitura",
            "SwiftKueryMySQL",
            "SwiftKueryORM",
            ]),
        .testTarget(name: "learn-kitura-kueryTests", dependencies: ["Main"]),
    ]
)
