#!/bin/bash
# Merges per-architecture slices into one static library per platform and bundles them into an XCFramework.
# Usage: create-xcframework.sh <slices-dir> <license-file> <output.xcframework>
# <slices-dir> holds one directory per slice, named <platform>-<arch>, as produced by build-slice.sh.
set -euo pipefail

SLICES_DIR=$1
LICENSE_FILE=$2
OUTPUT=$3
MERGED_DIR=$(mktemp -d -t openssl-merged)

create_args=()
for platform in macos ios iossimulator; do
	slices=("$SLICES_DIR/$platform"-*)
	[[ -d ${slices[0]} ]] || continue

	# One header set is shared per platform, so the generated headers must not differ between its architectures.
	for slice in "${slices[@]:1}"; do
		if ! diff -r "${slices[0]}/include" "$slice/include"; then
			echo "Headers differ between ${slices[0]} and $slice; they cannot share one XCFramework slice." >&2
			exit 1
		fi
	done

	libraries=()
	for slice in "${slices[@]}"; do
		libraries+=("$slice/lib/libssl.a" "$slice/lib/libcrypto.a")
	done
	mkdir -p "$MERGED_DIR/$platform"
	libtool -static -o "$MERGED_DIR/$platform/libopenssl.a" "${libraries[@]}"
	create_args+=(-library "$MERGED_DIR/$platform/libopenssl.a" -headers "${slices[0]}/include")
done

rm -rf "$OUTPUT"
xcodebuild -create-xcframework "${create_args[@]}" -output "$OUTPUT"
cp "$LICENSE_FILE" "$OUTPUT/LICENSE.txt"
