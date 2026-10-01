# OpenSSL for Apple platforms

Prebuilt static OpenSSL (`libssl` and `libcrypto` merged into one library) as an XCFramework, distributed as a Swift package with a binary target. 
Every release is built on GitHub Actions from the official OpenSSL release tarball.

## Usage

The package version is the OpenSSL version.

```swift
dependencies: [
    .package(url: "https://github.com/mbernson/OpenSSL-Apple.git", from: "4.0.3"),
],
targets: [
    .target(
        name: "MyTarget",
        dependencies: [.product(name: "OpenSSL", package: "OpenSSL-Apple")]
    ),
]
```

C targets can then `#include <openssl/ssl.h>`.

## Contents

| Platform | Architectures | Minimum OS |
|---|---|---|
| macOS | arm64, x86_64 | 11.0 (arm64), 10.13 (x86_64) |
| iOS | arm64 | 15.5 |
| iOS Simulator | arm64, x86_64 | 15.5 |

Configured with `no-asm no-apps no-docs no-shared no-dso no-quic no-tests`. The OpenSSL license is included in the XCFramework as `LICENSE.txt`.

The certificate directory (`--openssldir`) is `/etc/ssl`, so on macOS the default verify paths pick up the system CA bundle at `/etc/ssl/cert.pem`. 
iOS has no CA bundle on disk; apps must ship one and load it with `SSL_CTX_load_verify_locations` or the equivalent in the library using OpenSSL.

## Releasing a new version

Open Actions → Release → Run workflow and enter the OpenSSL version. The workflow:

1. Builds every slice in parallel.
2. Merges them into `OpenSSL.xcframework` and zips it.
3. Writes the asset URL and SPM checksum into `Package.swift` and commits that.
4. Creates the GitHub release, tagged with the version, with the zip attached.
5. Builds and runs an example package depending on the new version, to confirm the artifact downloads, compiles and links (`scripts/verify-release.sh`).

The asset URL is derived from the tag, so the manifest committed in step 3 is already correct before the release exists. A version can only be released once. To rebuild it, delete the release and its tag first.

## Building locally

```sh
scripts/download-source.sh 4.0.3 build
scripts/build-slice.sh build/openssl-4.0.3.tar.gz darwin64-arm64 -mmacosx-version-min=12.0 slices/macos-arm64
scripts/build-slice.sh build/openssl-4.0.3.tar.gz darwin64-x86_64 -mmacosx-version-min=10.13 slices/macos-x86_64
scripts/build-slice.sh build/openssl-4.0.3.tar.gz iossimulator-arm64-xcrun -mios-simulator-version-min=15.5 slices/iossimulator-arm64
scripts/create-xcframework.sh slices path/to/LICENSE.txt OpenSSL.xcframework
scripts/verify-release.sh 4.0.3
```

See `.github/workflows/release.yml` for the configure target and minimum-version flag of every slice.
