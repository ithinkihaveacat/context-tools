# Bug Report Guidelines

This document outlines the standard operating procedure for documenting Android
bugs. The goal is to capture actionable information that allows engineers to
isolate the specific timeframe of a defect and identify the root cause.

## Bug Report Structure

To ensure clarity and reproducibility, bug reports (e.g., `BUG.md`) should
generally adhere to the following structure. While this is the ideal format,
adapt it as necessary based on the available information (e.g., if only a code
fragment is available rather than a full reproduction).

### Description

This section must be **completely factual** and backed up by the attachments
provided. It should describe:

- What the bug is.
- The observable symptoms (e.g., crash, UI glitch).
- The context in which it occurs.

**Do not include speculation** about root causes or internal mechanics here.
Save that for the "Analysis" section.

### Impact

Briefly explain the implications of this defect to motivate the fix. Focus on
factual outcomes rather than emotional appeals.

- **Developer Experience:** Does this cause inconsistencies that reduce
  development velocity? Does it render automated tooling unreliable or difficult
  to maintain?
- **User Experience:** Is there a tangible performance degradation or functional
  blocker?

### Reproduction Statistics (Optional)

If the bug is intermittent, provide statistics on how often it occurs (e.g., "5
out of 10 times"). Note any patterns (e.g., alternating success/failure).

### Reproduction Steps

Detailed, step-by-step instructions to reproduce the bug.

- Include specific `adb` commands or scripts where applicable.
- Mention any necessary conditions (e.g., specific device state, timing).

#### Expected Behavior

What should have happened if the system were working correctly.

#### Actual Behavior

What actually happened. This should align with the "Description" but can be more
specific about the immediate outcome of the reproduction steps.

### Error Log

Include the specific exception or error message identified in the logs.

If a full bug report is available (see
[Capturing Actionable Bug Reports](#capturing-actionable-bug-reports)), provide:

- **The Extraction Command:** The exact shell command required to extract the
  relevant log section from the ZIP (see "Verifying the Captured Report").
- **Relevant Log Extracts:** Key lines from the output that demonstrate the
  defect, including full timestamps and error messages.

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
> ```

### Workaround (If available)

Any known methods to avoid or mitigate the bug.

### Analysis (Optional)

This is the only section where **speculation** and **technical investigation**
are permitted.

- Hypothesize about root causes (e.g., race conditions, memory leaks).
- Reference specific source code fragments if useful.
- Discuss potential fixes or architectural implications.

## Attachments

Evidence validates findings. Ideally, a bug report should include the following,
though availability may vary. These files should be placed in the same directory
as the bug report document.

### Recommended Files

- `bugreport.zip` (or similar): The captured Android bug report containing
  system logs.
- `app-debug.apk`: The specific build of the application used to reproduce the
  bug.
- **Code Fragments**: If a full APK or bug report isn't available, include
  relevant source code snippets.

### Visual Evidence (Recommended for UI/Interaction Bugs)

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

## Capturing Actionable Bug Reports

When you have access to a device and can reproduce the issue, follow this
procedure to generate the artifacts (logs, markers, videos) required for the
"Error Log" and "Attachments" sections above.

### The Log Marker Technique

To assist in log analysis, inject "markers" into the system log to delimit the
reproduction window.

#### The Command

Use the following command to inject a high-priority log message into the
device's main log buffer:

```bash
adb exec-out log -p f -t "BugReportMarker" "$1"
```

- `-p f`: Sets priority to **Fatal** (ensuring high visibility).
- `-t "BugReportMarker"`: Sets a consistent tag for easy filtering.
- `"$1"`: The message content.

### Optional: Continuous Background Logging

In high-volume or long-running tests, the device's internal log buffer may
rotate, causing earlier markers or error logs to be lost before `adb bugreport`
is run. To mitigate this, capture logs continuously to a file on the host
machine.

#### Workflow

1. **Start Logging in Background:** Clear the buffer, then stream logs to a
   file, saving the process ID (PID).

   ```bash
   adb logcat -c && adb logcat > continuous_log.txt & LOGCAT_PID=$!
   ```

2. **Run Reproduction Steps:** Execute your test case, including injecting
   `BugReportMarker` tags as usual.

3. **Stop Logging:** Kill the background process once the test is complete.

   ```bash
   kill $LOGCAT_PID
   ```

4. **Verify & Attach:** Inspect `continuous_log.txt` to ensure the markers and
   errors were captured. Attach this file to the bug report if the standard
   `bugreport.zip` is missing the relevant data.

### Execution Workflow

Follow this sequence to ensure a clean capture:

#### 1. Mark the Start

Inject a start marker before beginning the reproduction steps.

**Critical:** Log buffers persist. To avoid confusing this run with previous
attempts, clear the buffer first or use a unique message.

```bash
# Optional: Clear previous logs
adb logcat -c

# Mark start with a unique timestamp to distinguish from prior runs
adb exec-out log -p f -t "BugReportMarker" "START_REPRO: <Bug Description> $(date +%H%M%S)"
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

### Capturing Visual Evidence

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

**Crucial Step:** Before submitting, verify that your markers and the error
itself are actually present in the capture.

- **Check Timestamps:** Ensure the logs correspond to the time of your _latest_
  run. Old logs from previous attempts can persist and mislead analysis.
- **Verify Unique Tags:** If you used unique session IDs in your markers (e.g.,
  `START_REPRO_12345`), confirm they match.
- **Check for Rotation:** If your markers are missing, the log buffer likely
  rotated. In this case, use the **Continuous Background Logging** technique
  described above.

To inspect the relevant log window without extracting the entire archive, you
can use the following snippet. **This snippet is also what you should include in
the "Error Log" section of your report.**

Note that file naming conventions for the internal log vary by manufacturer; for
instance, Samsung devices typically use `dumpstate-*.txt` instead of the
standard `bugreport-*.txt`.

```bash
# 1. Identify the log file within the ZIP
LOG_FILE=$(unzip -qql "bugreport.zip" | cut -c 31- | grep -e dumpstate- -e dumpstate.txt -e bugreport- | grep txt)

# 2. Extract and display only the marked "interesting" period.
# CAUTION: Check timestamps! If previous runs weren't cleared, multiple blocks may appear.
unzip -p "bugreport.zip" "$LOG_FILE" | perl -ne 'print if /START_REPRO/ .. /END_REPRO/'
```

### Benefits

- **Searchability:** Analysts can `grep` for `BugReportMarker` to instantly find
  the relevant start and end timestamps.
- **Context:** Intermediate logs provide ground truth for what the user
  _intended_ to do versus what the system actually did.
