#!/bin/bash
# Points the binary target in Package.swift at a release asset and records the asset's checksum.
# Usage: update-manifest.sh <asset-url> <asset.zip>
# Prints the checksum.
set -euo pipefail

ASSET_URL=$1
ASSET=$2
MANIFEST="$(dirname "$0")/../Package.swift"

CHECKSUM=$(swift package compute-checksum "$ASSET")
ASSET_URL="$ASSET_URL" CHECKSUM="$CHECKSUM" perl -pi -e '
	s{(url: ")[^"]*(")}{$1$ENV{ASSET_URL}$2};
	s{(checksum: ")[^"]*(")}{$1$ENV{CHECKSUM}$2};
' "$MANIFEST"
swift package --package-path "$(dirname "$MANIFEST")" dump-package > /dev/null
echo "$CHECKSUM"
