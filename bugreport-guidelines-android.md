# Bug Report Guidelines

This document outlines the standard operating procedure for capturing actionable
Android bug reports and structuring the resulting documentation.

## Capturing Actionable Bug Reports

A raw bug report often contains megabytes of log data covering hours of device
activity. The goal of this procedure is to isolate the specific timeframe of the
defect, making it significantly easier for engineers (and automated tools) to
identify the root cause.

### The Log Marker Technique

To assist in log analysis, you must inject "markers" into the system log to
delimit the reproduction window.

#### The Command

Use the following command to inject a high-priority log message into the
device's main log buffer:

```bash
adb exec-out log -p f -t "BugReportMarker" "$1"
```

- `-p f`: Sets priority to **Fatal** (ensuring high visibility).
- `-t "BugReportMarker"`: Sets a consistent tag for easy filtering.
- `"$1"`: The message content.

### Execution Workflow

Follow this sequence to ensure a clean capture:

#### 1. Mark the Start

Inject a start marker before beginning the reproduction steps.

```bash
adb exec-out log -p f -t "BugReportMarker" "START_REPRO: <Bug Description>"
```

#### 2. Reproduce the Defect

Perform the steps to trigger the bug.

- **Optional:** If the reproduction is complex, inject intermediate "progress"
  logs to mark specific steps (e.g., "Step 1 complete").

#### 3. Mark the End

Immediately after the bug occurs, inject an end marker.

```bash
adb exec-out log -p f -t "BugReportMarker" "END_REPRO"
```

#### 4. Capture the Report

Generate the zipped bug report.

```bash
adb bugreport
```

### Visual Evidence

For UI glitches or complex interaction bugs, logs alone may be insufficient.
Complement the bug report with a screen recording or screenshot using the
following scripts (which should be available in your `PATH`):

#### Screen Recording

Use `adb-screenrecord` to capture recordings. This script handles touch
visualization automatically and saves the file directly to your host machine.

```bash
adb-screenrecord repro.mp4
```

#### Screenshots

Use `adb-screenshot` for static evidence. It automatically handles
device-specific requirements, such as applying circular masks for Wear OS
displays.

```bash
adb-screenshot repro.png
```

### Verifying the Captured Report

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

### Reporting Guidelines

When submitting a bug report (e.g., in a PR description or tracking ticket), you
should provide:

1.  **The Extraction Command:** The exact shell command required to extract the
    relevant log section from the ZIP.
2.  **Relevant Log Extracts:** Key lines from the output that demonstrate the
    defect, including full timestamps and error messages.

This ensures the reviewer has immediate context and can verify the evidence
themselves if needed.

#### Example Inclusion

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

### Benefits

- **Searchability:** Analysts can `grep` for `BugReportMarker` to instantly find
  the relevant start and end timestamps.
- **Context:** Intermediate logs provide ground truth for what the user
  _intended_ to do versus what the system actually did.

## Structuring the Bug Report

To ensure clarity and reproducibility, every bug report file (e.g., `BUG.md`)
must adhere to the following structure. The order of these sections is
mandatory.

### 1. Description

This section must be **completely factual** and backed up by the attachments
provided. It should describe:

- What the bug is.
- The observable symptoms (e.g., crash, UI glitch).
- The context in which it occurs.

**Do not include speculation** about root causes or internal mechanics here.
Save that for the "Analysis" section.

### 2. Reproduction Statistics (Optional but Recommended)

If the bug is intermittent, provide statistics on how often it occurs (e.g., "5
out of 10 times"). Note any patterns (e.g., alternating success/failure).

### 3. Error Log

Include the specific exception or error message identified in the logs.

- Provide the **Log Extraction Command** tailored to the attached bug report
  file.
- Provide the **Relevant Log Extract** showing the error within the marked
  reproduction window.

### 4. Reproduction Steps

Detailed, step-by-step instructions to reproduce the bug.

- Include specific `adb` commands or scripts.
- Mention any necessary conditions (e.g., specific device state, timing).

### 5. Expected Behavior

What should have happened if the system were working correctly.

### 6. Actual Behavior

What actually happened. This should align with the "Description" but can be more
specific about the immediate outcome of the reproduction steps.

### 7. Workaround (If available)

Any known methods to avoid or mitigate the bug.

### 8. Analysis (Optional)

This is the only section where **speculation** and **technical investigation**
are permitted.

- Hypothesize about root causes (e.g., race conditions, memory leaks).
- Reference specific source code fragments if useful.
- Discuss potential fixes or architectural implications.

## Required Attachments

Every bug report must be accompanied by specific files to validate the findings.
These files should be placed in the same directory as the bug report document.

### Mandatory Files

- `bugreport.zip` (or similar): The captured Android bug report containing
  system logs.
- `app-debug.apk`: The specific build of the application used to reproduce the
  bug.

### Visual Evidence (Required for UI/Interaction Bugs)

- `repro.png`: A screenshot showing the bug (e.g., visual glitch, error screen).
- `repro.mp4`: A screen recording showing the interaction leading up to the bug.

### Naming Conventions

- Filenames should be descriptive but concise.
- **Do not** add a separate textual description for an attachment unless the
  filename is ambiguous.
- **Ambiguity Rule:** If multiple files of the same type are attached (e.g.,
  multiple screenshots), ensure their filenames clearly distinguish them (e.g.,
  `repro_step1.png`, `repro_step2.png`). Only add a brief description (max 40
  chars) in the bug report if strictly necessary to clarify the difference.
