// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FlexCodable",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(name: "FlexCodable", targets: ["FlexCodable"])
    ],
    targets: [
        .target(
            name: "FlexCodable",
            path: "Sources/FlexCodable"
        ),
        .testTarget(
            name: "FlexCodableTests",
            dependencies: ["FlexCodable"],
            path: "Tests/FlexCodableTests"
        )
    ]
)
