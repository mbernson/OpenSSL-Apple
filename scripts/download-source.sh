#!/bin/bash
# Downloads the OpenSSL release tarball into <dir> and verifies it against the published SHA-256.
# Usage: download-source.sh <version> <dir>
set -euo pipefail

VERSION=$1
DIR=$2
BASE_URL="https://github.com/openssl/openssl/releases/download/openssl-$VERSION"
TARBALL="openssl-$VERSION.tar.gz"

mkdir -p "$DIR"
cd "$DIR"
curl -fsSLO "$BASE_URL/$TARBALL"
curl -fsSLO "$BASE_URL/$TARBALL.sha256"
echo "$(awk '{print $1}' "$TARBALL.sha256")  $TARBALL" | shasum -a 256 -c
