// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "URLQueryItemEncoder",
    products: [
        .library(
            name: "URLQueryItemEncoder",
            targets: ["URLQueryItemEncoder"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "URLQueryItemEncoder",
            dependencies: [],
            path: "URLQueryItemEncoder"),
        .testTarget(
            name: "URLQueryItemEncoderTests",
            dependencies: ["URLQueryItemEncoder"]
      )
    ],
    swiftLanguageVersions: [.v5]
)
