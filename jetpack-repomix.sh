#!/usr/bin/env bash

set -e

require() { hash "$@" || exit 127; }

require repomix

run_repomix() {
  local artifact_type="$1"
  local version="$2"
  local suffix="$3"
  local input_dir="build/$artifact_type/$version"
  local output_file="context/$artifact_type-$version-$suffix.txt"

  # Ensure the output directory exists
  mkdir -p "$(dirname "$output_file")"

  echo "Running repomix for $input_dir to $output_file"
  repomix "$input_dir" --no-security-check --quiet -o "$output_file"

  if [[ $? -ne 0 ]]; then
    echo "Error running repomix for $input_dir"
    exit 1
  fi
}

# Check if the build directory exists
if [ ! -d "build" ]; then
  echo "The 'build' directory does not exist. Run jetpack-selection.sh first."
  exit 1
fi

# Iterate over artifact types in the build directory
for artifact_dir in build/*/; do
  if [ -d "$artifact_dir" ]; then
    artifact_type=$(basename "$artifact_dir")
    
    # Iterate over versions for each artifact type
    for version_dir in "$artifact_dir"*/; do
      if [ -d "$version_dir" ]; then
        version=$(basename "$version_dir")
        
        # Determine if the version is stable or latest
        # Stable versions are numeric (e.g., 1.2.3)
        # Latest versions have suffixes (e.g., 1.2.3-alpha01)
        if [[ $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
          suffix="stable"
        else
          suffix="latest"
        fi
        
        run_repomix "$artifact_type" "$version" "$suffix"
      fi
    done
  fi
done

echo "Repomix processing complete."
