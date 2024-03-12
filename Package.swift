// swift-tools-version: 5.9
/*
 This source file is part of swift-signal project

 Copyright (c) 2024 Cyandev and project authors
 Licensed under MIT License
*/

import PackageDescription

let package = Package(
    name: "swift-signal",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .macCatalyst(.v13),
        .tvOS(.v13),
        .watchOS(.v6),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "SwiftSignal",
            targets: ["SwiftSignal"]),
        .library(
            name: "SwiftUISignal",
            targets: ["SwiftUISignal"]),
    ],
    targets: [
        .target(name: "SwiftSignal"),
        .target(
            name: "SwiftUISignal",
            dependencies: ["SwiftSignal"]),
        .testTarget(
            name: "SwiftSignalTests",
            dependencies: ["SwiftSignal"]),
    ]
)
