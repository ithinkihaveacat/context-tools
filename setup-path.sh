#!/bin/bash
#
# Source this file to add context-tools/bin to your PATH
#
# Usage:
#   source setup-path.sh
#   OR
#   . setup-path.sh
#

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
export PATH="$SCRIPT_DIR/bin:$PATH"

echo "Added $SCRIPT_DIR/bin to PATH"
echo "Available commands:"
echo "  - context-jetpack"
echo "  - jetpack-version-stable"
echo "  - jetpack-version-latest"
