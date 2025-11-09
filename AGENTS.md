# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository contains bash scripts that download and consolidate documentation from various technical projects into single text files using `repomix`. The generated context files are stored in the `context/` directory and can be used for providing comprehensive documentation to LLMs or other tools.

## Dependencies

All scripts require the following tools to be installed:
- `curl` - for downloading files
- `unzip` - for extracting archives
- `repomix` - for consolidating documentation into single files
- `bash` - for script execution
- `xmllint` - for parsing maven metadata (Jetpack scripts only)
- `jar` - for extracting JAR archives (Jetpack scripts only)

For Jetpack scripts, add `bin/` to your PATH:
```bash
source setup-path.sh
```

This makes the following helper commands available:
- `context-jetpack` - Download Jetpack packages
- `jetpack-version-stable` - Get stable version for a package
- `jetpack-version-latest` - Get latest version for a package

## Common Commands

### Running Documentation Scripts

The scripts in the `bin/` directory download, process, and consolidate documentation, emitting the result to standard output. It is recommended to redirect the output to a file in the `context/` directory.

```bash
# Generate Gemini CLI documentation
./bin/repomix-gemini-cli > context/gemini-cli.txt

# Generate Gemini CLI extensions documentation
./bin/repomix-gemini-cli-extensions > context/gemini-cli-extensions.txt

# Generate Model Context Protocol server documentation
./bin/repomix-mcp-server > context/mcp-server.txt

# Generate MCP TypeScript SDK documentation
./bin/repomix-mcp-typescript-sdk > context/mcp-typescript-sdk.txt

# Generate Raspberry Pi documentation (dated)
./bin/repomix-rpi > context/rpi-$(date +%Y%m%d).txt

# Generate Inky Frame documentation (combines multiple sources)
./bin/repomix-inkyframe > context/inky-frame.txt
```

### Jetpack Documentation Scripts

The Jetpack source code management uses a modular tooling approach:

```bash
# Set up PATH to use helper scripts
source setup-path.sh

# Download and extract Jetpack source code to ~/.context/ with versioned directories
./jetpack-selection

# Or use context-jetpack directly for custom packages
context-jetpack androidx.wear.tiles:tiles STABLE
context-jetpack androidx.wear.protolayout:protolayout{,-expression,-material,-material3} STABLE

# Get version information
jetpack-version-stable androidx.wear.compose:compose-material3
jetpack-version-latest androidx.wear.tiles:tiles
```

Documentation scripts are executable and will:
1. Create a `build/` subdirectory for temporary files
2. Download ZIP archives or files from GitHub/documentation sites
3. Extract relevant files
4. Run `repomix` to consolidate into a single text file
5. Output the result to `context/`

Jetpack scripts follow a different pattern:
1. Download `-sources.jar` files from Maven repositories
2. Extract source code to temporary directories
3. Copy STABLE versions to versioned directories in `~/.context/`
4. Provide persistent access to Jetpack source code

### Output Locations

- `context/gemini-cli.txt` - Gemini CLI documentation
- `context/gemini-cli-extensions.txt` - Gemini CLI extensions documentation
- `context/mcp-server.txt` - MCP server concepts and architecture
- `context/mcp-typescript-sdk.txt` - MCP TypeScript SDK README
- `context/rpi-YYYYMMDD.txt` - Raspberry Pi documentation (dated)
- `context/inky-frame.txt` - Combined Inky Frame and picographics documentation

## Architecture

### Script Structure (`bin/` scripts)

Each script in the `bin/` directory follows a consistent pattern:

1.  **Setup**: Create a temporary directory for downloads and extracted files. This directory is automatically cleaned up when the script exits.
2.  **Download**: Fetch archives from GitHub or documentation sites into the temporary directory.
3.  **Extract**: Unzip specific files or directories within the temporary directory.
4.  **Process**: Run `repomix` with specific include/ignore patterns.
5.  **Output**: Emit the consolidated text to standard output (`stdout`). The script itself is silent; any diagnostic or error messages are sent to standard error (`stderr`).

### Special Case: repomix-inkyframe

The `inky-frame` script is more complex as it combines multiple sources:
- Inky Frame repository (docs, examples, modules)
- Pimoroni Pico repository (picographics module only)
- mpremote documentation from MicroPython docs

It creates a `build/inky-frame-mix/` directory to stage all sources before running repomix.

### Special Case: Jetpack Libraries

The Jetpack tooling downloads source code for Android Jetpack libraries from Maven repositories using a modular architecture:

1.  **`jetpack-selection`**: Main script that downloads multiple package groups (tiles, protolayout, compose, horologist, ongoing). For each group, it:
    - Uses `jetpack-version-stable` to determine the stable version
    - Calls `context-jetpack` to download both STABLE and LATEST versions
    - Copies STABLE source to `~/.context/<group-name>-<version>/` for persistent access

2.  **`bin/context-jetpack`**: Core utility that downloads one or more packages:
    - Accepts multiple package names (supports brace expansion)
    - Resolves STABLE/LATEST version keywords using helper scripts
    - Downloads `-sources.jar` files from Maven repository
    - Extracts all packages into a single temporary directory
    - Outputs the temporary directory path to stdout

3.  **`bin/jetpack-version-stable`**: Helper script that queries Maven metadata to find the stable version for a package

4.  **`bin/jetpack-version-latest`**: Helper script that queries Maven metadata to find the latest version for a package

All scripts use PATH to locate helpers, eliminating hardcoded script locations.

#### Persistent Storage

The `jetpack-selection` script creates versioned directories in `~/.context/`:
- `~/.context/androidx-wear-tiles-1.5.0/`
- `~/.context/androidx-wear-protolayout-1.3.0/`
- `~/.context/androidx-wear-compose-1.5.5/`
- `~/.context/com-google-android-horologist-0.7.15/`
- `~/.context/androidx-wear-ongoing-1.1.0/`

Each directory contains the complete source tree for all related packages in that group.

#### Usage Examples

Download a single package:
```bash
context-jetpack androidx.wear.tiles:tiles STABLE
# Output: /tmp/tmp.xyz123 (temporary directory path)
```

Download multiple related packages using brace expansion:
```bash
context-jetpack androidx.wear.protolayout:protolayout{,-expression,-material,-material3} STABLE
# Downloads all four packages into one temporary directory
```

Get version information:
```bash
jetpack-version-stable androidx.wear.compose:compose-material3
# Output: 1.5.5

jetpack-version-latest androidx.wear.tiles:tiles
# Output: 1.6.0-alpha01
```

Download from a custom Maven repository:
```bash
context-jetpack com.google.android.horologist:horologist-datalayer STABLE https://repo1.maven.org/maven2
```

### Directory Structure

```
.
├── bin/                          # Scripts for generating documentation
│   ├── context-jetpack           # Download Jetpack packages (supports multiple packages)
│   ├── jetpack-version-stable    # Get stable version for a package
│   ├── jetpack-version-latest    # Get latest version for a package
│   ├── repomix-gemini-cli
│   ├── repomix-gemini-cli-extensions
│   ├── repomix-inkyframe
│   ├── repomix-mcp-server
│   ├── repomix-mcp-typescript-sdk
│   └── repomix-rpi
├── jetpack-selection             # Download and store Jetpack sources to ~/.context/
├── setup-path.sh                 # Add bin/ to PATH
├── context/                      # Generated consolidated documentation files
└── ~/.context/                   # Persistent Jetpack source storage (versioned)
    ├── androidx-wear-tiles-1.5.0/
    ├── androidx-wear-protolayout-1.3.0/
    ├── androidx-wear-compose-1.5.5/
    ├── com-google-android-horologist-0.7.15/
    └── androidx-wear-ongoing-1.1.0/
```

## Repomix Usage Patterns

Scripts use various `repomix` flags:
- `--include` - Specify file patterns to include
- `--ignore` - Exclude certain directories/files
- `--no-security-check` - Skip security checks
- `--quiet` - Suppress verbose output
- `-o` - Output file path

## Important Notes

- The `build/` and `context/` directories are gitignored (they contain generated content)
- The `rpi` script uses date-stamped output files (`rpi-YYYYMMDD.txt`)
- All scripts use `set -e` to exit on first error
- Scripts verify required commands exist before proceeding
