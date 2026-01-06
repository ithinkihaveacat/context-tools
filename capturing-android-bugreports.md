# Capturing Android Bug Reports

This document outlines the standard operating procedure for capturing actionable
Android bug reports.

## Objective

A raw bug report often contains megabytes of log data covering hours of device
activity. The goal of this procedure is to isolate the specific timeframe of the
defect, making it significantly easier for engineers (and automated tools) to
identify the root cause.

## The Log Marker Technique

To assist in log analysis, you must inject "markers" into the system log to
delimit the reproduction window.

### The Command

Use the following command to inject a high-priority log message into the
device's main log buffer:

```bash
adb exec-out log -p f -t "BugReportMarker" "$1"
```

- `-p f`: Sets priority to **Fatal** (ensuring high visibility).
- `-t "BugReportMarker"`: Sets a consistent tag for easy filtering.
- `"$1"`: The message content.

## Execution Workflow

Follow this sequence to ensure a clean capture:

### 1. Mark the Start

Inject a start marker before beginning the reproduction steps.

```bash
adb exec-out log -p f -t "BugReportMarker" "START_REPRO: <Bug Description>"
```

### 2. Reproduce the Defect

Perform the steps to trigger the bug.

- **Optional:** If the reproduction is complex, inject intermediate "progress"
  logs to mark specific steps (e.g., "Step 1 complete").

### 3. Mark the End

Immediately after the bug occurs, inject an end marker.

```bash
adb exec-out log -p f -t "BugReportMarker" "END_REPRO"
```

### 4. Capture the Report

Generate the zipped bug report.

```bash
adb bugreport
```

## Visual Evidence

For UI glitches or complex interaction bugs, logs alone may be insufficient.
Complement the bug report with a screen recording or screenshot using the
following scripts (which should be available in your `PATH`):

### Screen Recording

Use `adb-screenrecord` to capture recordings. This script handles touch
visualization automatically and saves the file directly to your host machine.

```bash
adb-screenrecord repro.mp4
```

### Screenshots

Use `adb-screenshot` for static evidence. It automatically handles
device-specific requirements, such as applying circular masks for Wear OS
displays.

```bash
adb-screenshot repro.png
```

## Verifying the Captured Report

To ensure the markers were successfully captured and to inspect the relevant log
window without extracting the entire archive, you can use the following snippet.

Note that file naming conventions for the internal log vary by manufacturer; for
instance, Samsung devices typically use `dumpstate-*.txt` instead of the
standard `bugreport-*.txt`.

```bash
# 1. Identify the log file within the ZIP
LOG_FILE=$(unzip -qql "bugreport.zip" | cut -c 31- | grep -e dumpstate- -e dumpstate.txt -e bugreport- | grep txt)

# 2. Extract and display only the marked "interesting" period
unzip -p "bugreport.zip" "$LOG_FILE" | perl -ne 'print if /START_REPRO/ .. /END_REPRO/'
```

## Reporting Guidelines

When submitting a bug report (e.g., in a PR description or tracking ticket), you
should provide:

1.  **The Extraction Command:** The exact shell command required to extract the
    relevant log section from the ZIP.
2.  **Relevant Log Extracts:** Key lines from the output that demonstrate the
    defect, including full timestamps and error messages.

This ensures the reviewer has immediate context and can verify the evidence
themselves if needed.

### Example Inclusion

> **Log Extraction Command:**
>
> ```bash
> # Extracting the reproduction window from bugreport-20260106.zip
> LOG_FILE=$(unzip -qql "bugreport-20260106.zip" | cut -c 31- | grep -e dumpstate- -e dumpstate.txt -e bugreport- | grep txt)
> unzip -p "bugreport-20260106.zip" "$LOG_FILE" | perl -ne 'print if /START_REPRO/ .. /END_REPRO/'
> ```
>
> **Relevant Log Extract:**
>
> ```text
> 01-06 11:13:46.066 10043 32234 32234 E ProtoTilesTileRendererImpl: Failed to render and attach the tile:  com.google.example.wear_widget/.WidgetCatalogService
> 01-06 11:13:46.066 10043 32234 32234 E ProtoTilesTileRendererImpl: java.lang.RuntimeException: Failed to read the given Remote Compose document: The `224` operation is unknown
> --
> 01-06 11:14:46.184 10043 32234 32234 E ProtoTilesTileRendererImpl: Failed to render and attach the tile:  com.google.example.wear_widget/.WidgetCatalogService
> 01-06 11:14:46.184 10043 32234 32234 E ProtoTilesTileRendererImpl: java.lang.RuntimeException: Failed to read the given Remote Compose document: The `224` operation is unknown
> ```

## Benefits

- **Searchability:** Analysts can `grep` for `BugReportMarker` to instantly find
  the relevant start and end timestamps.
- **Context:** Intermediate logs provide ground truth for what the user
  _intended_ to do versus what the system actually did.
