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
- `xmllint` - for parsing maven metadata
- `jar` - for extracting sources

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

The Jetpack documentation generation is a two-step process:

```bash
./jetpack-selection.sh  # Download and extract Jetpack source code
./jetpack-repomix.sh    # Consolidate the downloaded source code
```

All scripts are executable and will:
1. Create a `build/` subdirectory for temporary files
2. Download ZIP archives or files from GitHub/documentation sites
3. Extract relevant files
4. Run `repomix` to consolidate into a single text file
5. Output the result to `context/`

### Output Locations

- `context/gemini-cli.txt` - Gemini CLI documentation
- `context/gemini-cli-extensions.txt` - Gemini CLI extensions documentation
- `context/mcp-server.txt` - MCP server concepts and architecture
- `context/mcp-typescript-sdk.txt` - MCP TypeScript SDK README
- `context/rpi-YYYYMMDD.txt` - Raspberry Pi documentation (dated)
- `context/inky-frame.txt` - Combined Inky Frame and picographics documentation
- `context/<artifact>-<version>-<type>.txt` - Jetpack library documentation (e.g., `tiles-1.4.0-stable.txt`)

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

The `jetpack` scripts download source code for Android Jetpack libraries from Maven repositories. This is a multi-script process:

1.  **`jetpack-selection.sh`**: Defines a list of Jetpack packages to download. For each package, it calls `jetpack-dl.sh` for both the "STABLE" and "LATEST" versions.
2.  **`jetpack-dl.sh`**: A utility script that resolves the correct version string, downloads the `-sources.jar` file from the Maven repository, and extracts it into the `build/` directory.
3.  **`jetpack-repomix.sh`**: Iterates through the downloaded sources in the `build/` directory and runs `repomix` on each one, generating a consolidated text file in `context/`.

### Directory Structure

```
.
├── bin/                # Scripts for generating documentation
│   ├── repomix-gemini-cli
│   ├── repomix-gemini-cli-extensions
│   ├── repomix-inkyframe
│   ├── repomix-mcp-server
│   ├── repomix-mcp-typescript-sdk
│   └── repomix-rpi
├── context/            # Generated consolidated documentation files
├── jetpack-dl.sh       # Utility to download a Jetpack library
├── jetpack-repomix.sh  # Script to run repomix on downloaded libraries
├── jetpack-selection.sh # Script to select and download Jetpack libraries
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
