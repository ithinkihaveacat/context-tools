#!/usr/bin/env bash

set -e

# Assumes jetpack-dl.sh is in the same directory as this script.
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
dl_script="$script_dir/jetpack-dl.sh"

# Tiles
TILES_PACKAGES=(
  "androidx.wear.tiles:tiles"
  "androidx.wear.tiles:tiles-renderer"
  "androidx.wear.tiles:tiles-testing"
)
for package in "${TILES_PACKAGES[@]}"; do
  "$dl_script" "tiles" "$package" "STABLE"
  "$dl_script" "tiles" "$package" "LATEST"
done

# Protolayout
PROTO_PACKAGES=(
  "androidx.wear.protolayout:protolayout"
  "androidx.wear.protolayout:protolayout-expression"
  "androidx.wear.protolayout:protolayout-material"
  "androidx.wear.protolayout:protolayout-material3"
)
for package in "${PROTO_PACKAGES[@]}"; do
  "$dl_script" "proto" "$package" "STABLE"
  "$dl_script" "proto" "$package" "LATEST"
done

# Compose
"$dl_script" "compose" "androidx.wear.compose:compose-material3" "STABLE"

# Horologist
"$dl_script" "horologist" "com.google.android.horologist:horologist-datalayer" "STABLE" "https://repo1.maven.org/maven2"

# Ongoing
"$dl_script" "ongoing" "androidx.wear:wear-ongoing" "STABLE"

echo "All packages downloaded."