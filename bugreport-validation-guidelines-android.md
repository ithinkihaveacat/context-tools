# Android Bug Report Validation Protocol

This document defines the standard process for validating bug reports created according to the [Bug Report Guidelines](bugreport-guidelines-android.md). Validation ensures that reports are accurate, reproducible, and actionable before engineering resources are allocated for a fix.

Validation consists of two independent styles. A report may undergo one or both types of validation depending on available resources and the nature of the bug.

1.  **Static Analysis:** Verifies the report's internal logic, data integrity, and claim consistency.
2.  **Dynamic Reproduction:** Verifies the bug's existence in a live environment.

---

## Style 1: Static Analysis

**Goal:** Ensure the report is internally consistent, commands are functional, and claims are supported by the attached evidence.

### 1. Environment Verification
The report must provide sufficient context to attempt a reproduction or code analysis.
- **Check:** Is an Android Bug Report Zip (`bugreport.zip`) attached?
    - **YES:** This satisfies the requirement (contains system properties).
    - **NO:** Does the "Environment" section explicitly list:
        - Device/Emulator info?
        - Android API level?
        - Build version/Commit hash?
        - Critical library versions?
- **Failure Condition:** If neither the zip nor the textual description is present, mark as **NEEDS INFO**.

### 2. Artifact & Command Verification
If the report includes "Log Extraction Commands" or analysis scripts:
- **Action:** Execute the provided commands against the attached artifacts.
- **Validation Criteria:**
    - The command must run without syntax errors on a standard Unix-like environment.
    - **Acceptable Variance (Scripts):** Trivial OS-specific tweaks (e.g., `sed` syntax differences on macOS vs. Linux) are acceptable. Document these adjustments.
    - **Output Match (Logs):** The command's output must match the "Relevant Log Extract" provided in the report **EXACTLY**.
        - *Strictness:* Timestamps, PIDs, and message content must match character-for-character.
        - *Acceptable Variance (Formatting):* Minor whitespace differences (e.g., tabs vs. spaces) or trailing newlines introduced by the extraction tool are acceptable.

### 3. Source Code Verification
If the report cites specific source code fragments:
- **Action:** Cross-reference the snippets with the actual codebase or library source.
- **Validation Criteria:**
    - **Exact Match:** The code in the report must exist in the repo.
    - **Version Assumptions:** If the version is not specified, assume "latest stable" or the project's current `HEAD`.
    - **Acceptable Variance:** If the code matches a recent version but not the absolute latest, note this but do not fail the report.

### 4. Logic & Consistency
- **Check:** Does the "Description" match the "Actual Behavior"?
- **Check:** Does the "Impact" align with the severity of the crash/bug described?

---

## Style 2: Dynamic Reproduction

**Goal:** Confirm the bug exists, is reproducible via the provided steps, and affects the reported versions.

### 1. Environment Setup
- **Action:** Provision an environment matching the reported device and API level.
- **App Build:** Install the attached APK (if provided) or build the project from the specified commit hash.
    - *Note:* Do not require specific filenames (like `app-debug.apk`) as long as the artifact is identifiable.

### 2. Execution
- **Action:** Follow the "Reproduction Steps" exactly.
- **Action:** If a reproduction script is provided, run it.
    - *Acceptable Variance:* You may need to adjust paths, serial numbers, or package names in the script to match your local setup.

### 3. Verification of Results
- **Comparison:** Does the observed behavior match the "Actual Behavior" in the report?
- **Log Confirmation:** Can you find the same error message/stack trace in your new logs?
- **Reproduction Rate:**
    - **Judgment Call:** Reproduction is rarely deterministic. Use your best judgment.
    - **Red Flag:** If you cannot reproduce the bug at all after a reasonable number of attempts (e.g., 5-10), this is a significant issue.
    - **Acceptable Variance:** If the report claims "100% (5/5)" and you observe "60% (3/5)", this is generally a **PASS** (reproduced), with a note about the lower frequency.

---

## Validation Status Codes

When verifying a bug report, append a **Validation Summary** to the issue tracker or report document.

### Statuses
- **VALIDATED (FULL):** Passed both Static Analysis and Dynamic Reproduction.
- **VALIDATED (STATIC):** Passed Static Analysis only.
- **VALIDATED (DYNAMIC):** Passed Dynamic Reproduction only.
- **NEEDS INFO:** Failed either analysis style in a way that prevents further action (e.g., missing artifacts, completely unreproducible).

### Validation Summary Template

```markdown
## Validation Summary
**Validator:** [Your Name/Agent Name]
**Date:** [YYYY-MM-DD]
**Status:** [VALIDATED (FULL) | VALIDATED (STATIC) | VALIDATED (DYNAMIC) | NEEDS INFO]

### Static Analysis
- [x] Environment info present (Zip attached)
- [x] Extraction commands work
- [ ] Source code matches (Notes: Version not specified; assumed `androidx.wear:1.3.0`. Code matches.)

### Dynamic Reproduction
- **Device:** [Device Used, e.g., Pixel Watch Emulator API 33]
- **Build:** [Commit Hash or "Attached APK"]
- **Result:** Reproduced 3/5 times.
- **Notes:** [Any friction encountered, e.g., "Script required `chmod +x` before running."]
```