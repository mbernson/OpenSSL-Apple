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
            url: "https://github.com/mbernson/OpenSSL-Apple/releases/download/4.0.3/OpenSSL.xcframework.zip",
            checksum: "262cac5a3fc1016a8823c4ce0e7a22b8652bd8aa44a9a8f1dff5aa66d065b78f"
        ),
    ]
)
