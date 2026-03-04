---
name: bug-reporting
description: >
  Guidelines for reporting Android bugs, validating existing reports, and
  converting unresolved bugs into known issues documentation. Use when filing a
  new bug, reviewing bug reports, or documenting library limitations.
---

# Android Bug Reporting Skill

This skill provides standards and protocols for handling Android bug reports. It
covers the entire lifecycle from initial reporting to validation and triage.

## 1. Writing a Bug Report

When you need to document a new defect, follow the **Android Bug Report
Guidelines**. This ensures that reports are actionable, reproducible, and
contain necessary log evidence.

**Key Requirements:**

- **Factual Description:** Focus on symptoms and context, not speculation.
- **Environment:** Precise device, build, and library versions.
- **Reproduction:** Step-by-step instructions with `adb` commands where
  possible.
- **Evidence:** Logs (with markers), screenshots, and screen recordings.

For the full template and detailed instructions on capturing logs:
[Read the Guidelines](references/android-guidelines.md)

## 2. Validating a Bug Report

When you are tasked with verifying a reported bug, use the **Validation
Protocol**. This defines two validation styles:

1. **Static Analysis:** Checking the report's logic, artifacts, and commands.
2. **Dynamic Reproduction:** Attempting to reproduce the bug on a
   device/emulator.

Always output a **Validation Summary** code block upon completion.

For the validation checklist and status codes:
[Read the Validation Protocol](references/validation.md)

## 3. Converting Bugs to Known Issues

When a bug is confirmed but will not be fixed (e.g., "WontFix", "Infeasible"),
convert it into a **Known Issue** for documentation. This shifts the focus from
"fixing the code" to "helping the user work around the limitation."

- **Source (Bug Report):** "This is broken." (Audience: Maintainers)
- **Target (Known Issue):** "This is how it works / Workaround." (Audience:
  Developers)

For a guide on translating technical defects into helpful documentation:
[Read Converting Bug Reports to Known Issues](references/known-issues.md)
