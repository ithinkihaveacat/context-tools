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

## Common Commands

### Running Documentation Scripts

Execute any of the documentation generation scripts:

```bash
./gemini-cli              # Generate Gemini CLI documentation
./mcp-server              # Generate Model Context Protocol server documentation
./mcp-typescript-sdk      # Generate MCP TypeScript SDK documentation
./rpi                     # Generate Raspberry Pi documentation
./inky-frame              # Generate Inky Frame documentation (combines multiple sources)
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

## Architecture

### Script Structure

Each script follows a consistent pattern:

1. **Setup**: Create build directories, define `require()` function
2. **Download**: Fetch archives from GitHub or documentation sites
3. **Extract**: Unzip specific files or directories
4. **Process**: Run `repomix` with specific include/ignore patterns
5. **Output**: Generate consolidated text file in `context/`

### Special Case: inky-frame

The `inky-frame` script is more complex as it combines multiple sources:
- Inky Frame repository (docs, examples, modules)
- Pimoroni Pico repository (picographics module only)
- mpremote documentation from MicroPython docs

It creates a `build/inky-frame-mix/` directory to stage all sources before running repomix.

### Directory Structure

```
.
├── build/              # Temporary download and extraction directory
├── context/            # Generated consolidated documentation files
├── gemini-cli          # Script for Gemini CLI docs
├── mcp-server          # Script for MCP server docs
├── mcp-typescript-sdk  # Script for MCP TypeScript SDK docs
├── rpi                 # Script for Raspberry Pi docs
└── inky-frame          # Script for Inky Frame docs (multi-source)
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
