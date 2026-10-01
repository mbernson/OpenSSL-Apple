#!/bin/bash
# Builds and runs a throwaway package that depends on a released version, proving that the artifact
# downloads, its headers are found and the library links on macOS, and that it builds for iOS Simulator.
# Usage: verify-release.sh <version> [package-url]
set -euo pipefail

VERSION=$1
PACKAGE_URL=${2:-https://github.com/mbernson/OpenSSL-Apple.git}
PACKAGE_DIR=$(mktemp -d -t openssl-verify)

mkdir -p "$PACKAGE_DIR/Sources/Verify"
cat > "$PACKAGE_DIR/Package.swift" <<MANIFEST
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Verify",
    platforms: [.macOS(.v11), .iOS("15.5")],
    dependencies: [
        .package(url: "$PACKAGE_URL", exact: "$VERSION"),
    ],
    targets: [
        .executableTarget(
            name: "Verify",
            dependencies: [.product(name: "OpenSSL", package: "OpenSSL-Apple")]
        ),
    ]
)
MANIFEST
cat > "$PACKAGE_DIR/Sources/Verify/main.c" <<'SOURCE'
#include <stdio.h>
#include <openssl/crypto.h>

int main(void) {
	printf("%s\n", OpenSSL_version(OPENSSL_VERSION));
	return 0;
}
SOURCE

output=$(swift run --package-path "$PACKAGE_DIR" Verify)
echo "$output"
[[ $output == "OpenSSL $VERSION"* ]] || { echo "Expected OpenSSL $VERSION" >&2; exit 1; }

swift build --package-path "$PACKAGE_DIR" \
	--triple arm64-apple-ios15.5-simulator --sdk "$(xcrun --sdk iphonesimulator --show-sdk-path)"
