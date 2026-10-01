// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "OpenSSL",
    platforms: [
        .macOS(.v10_13),
        .iOS("15.5"),
    ],
    products: [
        .library(name: "OpenSSL", targets: ["OpenSSL"]),
    ],
    targets: [
        // The release workflow rewrites `url` and `checksum` for every release.
        .binaryTarget(
            name: "OpenSSL",
            url: "https://github.com/mbernson/OpenSSL-Apple/releases/download/0.0.0/OpenSSL.xcframework.zip",
            checksum: "0000000000000000000000000000000000000000000000000000000000000000"
        ),
    ]
)
