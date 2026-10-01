#!/bin/bash
# Builds static libssl and libcrypto for one OpenSSL configure target.
# Usage: build-slice.sh <tarball> <configure-target> <min-version-flag> <output-dir>
# Produces <output-dir>/lib/{libssl,libcrypto}.a and <output-dir>/include/openssl/.
set -euo pipefail

TARBALL=$1
TARGET=$2
MIN_VERSION_FLAG=$3
OUTPUT_DIR=$4
CONFIGURE_OPTIONS=${OPENSSL_CONFIGURE_OPTIONS:-"no-asm no-apps no-docs no-shared no-dso no-quic no-tests"}

mkdir -p "$OUTPUT_DIR"
OUTPUT_DIR=$(cd "$OUTPUT_DIR" && pwd)
SOURCE_DIR=$(mktemp -d -t openssl-src)
tar xzf "$TARBALL" -C "$SOURCE_DIR" --strip-components=1

STAGING_DIR=$(mktemp -d -t openssl-staging)

# /etc/ssl is where macOS keeps its CA bundle (cert.pem), so certificate verification works there
# without configuration. Installing through DESTDIR keeps build paths out of the binaries.
cd "$SOURCE_DIR"
# shellcheck disable=SC2086
perl ./Configure $CONFIGURE_OPTIONS "$TARGET" "$MIN_VERSION_FLAG" \
	--prefix=/usr/local --libdir=lib --openssldir=/etc/ssl
make -j"$(sysctl -n hw.ncpu)" build_libs
make install_dev DESTDIR="$STAGING_DIR"
mv "$STAGING_DIR/usr/local/lib" "$STAGING_DIR/usr/local/include" "$OUTPUT_DIR/"
