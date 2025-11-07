#!/bin/bash
#
# Downloads and extracts the source code for a given Jetpack package.
#
# Usage:
#   jetpack-dl.sh <artifact_type> <package_name> <version> [repo_url]
#
# Example:
#   jetpack-dl.sh tiles androidx.wear.tiles:tiles STABLE
#   jetpack-dl.sh horologist com.google.android.horologist:horologist-datalayer STABLE https://repo1.maven.org/maven2
#

set -e

if [ "$#" -ne 3 ] && [ "$#" -ne 4 ]; then
  echo "Usage: jetpack-dl.sh <artifact_type> <package_name> <version> [repo_url]"
  exit 1
fi

require() { hash "$@" || exit 127; }

require curl
require grep
require sed
require xmllint
require tr
require sort
require tail
require jar

# shellcheck disable=SC2181

# https://maven.google.com/web/index.html

get_stable_version() {
  local base_url="$1"
  local group_id="$2"
  local artifact_id="$3"
  local group_id_path
  group_id_path=$(echo "$group_id" | sed 's/\./\//g')
  local metadata_url="$base_url/$group_id_path/$artifact_id/maven-metadata.xml"

  local release_version
  release_version=$(curl -sSL "$metadata_url" |
    xmllint --xpath "//version/text()" - |
    tr ' ' '\n' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' |
    sort -V |
    tail -n 1)

  if [[ -z "$release_version" ]]; then
    # Fallback for cases where no stable version is found, take the latest prerelease.
    release_version=$(curl -sSL "$metadata_url" |
      xmllint --xpath "//version/text()" - |
      tr ' ' '\n' |
      sort -V |
      tail -n 1)
    if [[ -z "$release_version" ]]; then
      echo "error: could not determine latest version for $group_id:$artifact_id from $metadata_url" >&2
      exit 1
    fi
    echo "info: using latest prerelease version: $release_version" >&2
  fi

  echo "$release_version"
}

get_latest_version() {
  local base_url="$1"
  local group_id="$2"
  local artifact_id="$3"
  local group_id_path
  group_id_path=$(echo "$group_id" | sed 's/\./\//g')
  local metadata_url="$base_url/$group_id_path/$artifact_id/maven-metadata.xml"

  local latest_version
  latest_version=$(curl -sSL "$metadata_url" |
    xmllint --xpath "//versioning/latest/text()" -)

  if [[ -z "$latest_version" ]]; then
    echo "error: could not determine latest version for $group_id:$artifact_id from $metadata_url" >&2
    exit 1
  fi

  echo "$latest_version"
}

ARTIFACT_TYPE=$1
PACKAGE_NAME=$2
VERSION_STRING=$3
REPO_URL=${4:-"https://dl.google.com/android/maven2"}

GROUP_ID=$(echo "$PACKAGE_NAME" | cut -d: -f1)
ARTIFACT_ID=$(echo "$PACKAGE_NAME" | cut -d: -f2)

VERSION_STRING_UPPER=$(echo "$VERSION_STRING" | tr '[:lower:]' '[:upper:]')

if [ "$VERSION_STRING_UPPER" == "STABLE" ]; then
  VERSION=$(get_stable_version "$REPO_URL" "$GROUP_ID" "$ARTIFACT_ID")
  echo "Resolved STABLE version for ${PACKAGE_NAME} to ${VERSION}"
elif [ "$VERSION_STRING_UPPER" == "LATEST" ]; then
  VERSION=$(get_latest_version "$REPO_URL" "$GROUP_ID" "$ARTIFACT_ID")
  echo "Resolved LATEST version for ${PACKAGE_NAME} to ${VERSION}"
else
  VERSION=$VERSION_STRING
fi

GROUP_ID_PATH=$(echo "$GROUP_ID" | sed 's/\./\//g')
SOURCE_JAR_URL="${REPO_URL}/${GROUP_ID_PATH}/${ARTIFACT_ID}/${VERSION}/${ARTIFACT_ID}-${VERSION}-sources.jar"
SOURCE_JAR_FILENAME="${ARTIFACT_ID}-${VERSION}-sources.jar"

BUILD_DIR="build/${ARTIFACT_TYPE}/${VERSION}"
mkdir -p "${BUILD_DIR}"

echo "Downloading sources from ${SOURCE_JAR_URL}"
curl -sSL -o "${BUILD_DIR}/${SOURCE_JAR_FILENAME}" "${SOURCE_JAR_URL}"

echo "Extracting sources to ${BUILD_DIR}"
(
  cd "${BUILD_DIR}"
  jar xf "${SOURCE_JAR_FILENAME}"
  rm "${SOURCE_JAR_FILENAME}"
  rm -rf META-INF
)

echo "Successfully downloaded and extracted ${PACKAGE_NAME}:${VERSION}"