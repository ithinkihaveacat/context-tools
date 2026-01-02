# Bug Reports vs. Known Issues

Bug reports and known issues often describe the same technical problem, but they
differ in intent, audience, and framing. This document explains the distinction
and how to translate between them.

## Intent and Audience

| Aspect          | Bug Report                         | Known Issue                                        |
| --------------- | ---------------------------------- | -------------------------------------------------- |
| **Intent**      | Request a fix from library authors | Help developers use the library as-is              |
| **Audience**    | Library maintainers                | Developers using the library                       |
| **Action by**   | Library authors must fix           | Developers must work around                        |
| **Perspective** | "This is broken"                   | "This is how it works" (or "This is a limitation") |
| **Tone**        | Assertive, identifying a defect    | Helpful, facilitating success                      |

## The Lifecycle of a Defect

It is helpful to view these documents not just as static categories, but as
stages in a lifecycle.

- **A Bug Report is a Request:** It asks for a change in the code.
- **A Known Issue is a Response (or Concession):** It acknowledges that the code
  cannot or will not change right now.

Often, a **Bug Report** is submitted to maintainers. If the maintainers decide
the fix is too risky, too difficult, or not currently prioritized, they convert
it into a **Known Issue** for the documentation. Conversely, writing a Known
Issue implies, "We accept this behavior/limitation for now."

## Language Differences

**Bug report language:**

- "This is a bug"
- "Should behave like..."
- "Inconsistent with..."
- "Incorrect behavior"
- "Fix needed"

**Known issue language:**

- "This differs from..."
- "Use X instead of Y"
- "Currently, X is not supported by design..."
- "Due to platform limitations..."
- "Solution:" / "Workaround:"

## Structure Differences

**Bug report structure:**

1. **The Defect:** What is wrong.
2. **Expectation:** How it should work.
3. **Root Cause/Context:** Deep technical context (stack traces, internal logic)
   to help the maintainer debug.
4. **Suggested Fix:** (Optional) Code changes.

**Known issue structure:**

1. **The Symptom:** What the user might encounter.
2. **The Workaround:** Immediate steps to unblock the user.
3. **Context:** Brief explanation of _why_ (deep technical causality is omitted
   unless it helps identify the symptom).

_Note: Known issues lead with the solution; bug reports lead with the problem._

## Translation Examples

### Example 1: API Consistency (`RemoteBox`)

**As a Bug Report**

> **Title:** `RemoteBox` incorrectly uses Arrangement instead of Alignment\
> **Defect:** `RemoteBox` uses `verticalArrangement` for positioning. This is
> inconsistent with `RemoteRow`, which uses `RemoteAlignment`.\
> **Expected:** It should use `RemoteAlignment` to match standard semantics.\
> **Suggested fix:** Change the parameter type in `RemoteBox.kt`.

**As a Known Issue**

> **Title:** `RemoteBox` Vertical Axis Requires `Arrangement`.\
> **Symptom:** You cannot use `RemoteAlignment` constants when configuring a
> `RemoteBox`.\
> **Workaround:** Use `RemoteArrangement` constants (`Top`, `Center`, `Bottom`)
> instead.\
> **Context:** This differs from `RemoteRow`, which uses standard Alignment
> types.

### Example 2: Functional Limitation (Video Uploads)

**As a Bug Report**

> **Title:** App crashes with `OutOfMemoryError` on 4k Video Uploads\
> **Defect:** The upload buffer attempts to load the entire file into RAM before
> sending.\
> **Expected:** The client should stream the file in chunks to avoid memory
> spikes.\
> **Fix:** Implement `InputStream` handling in the network layer.

**As a Known Issue**

> **Title:** Video Upload Size Limits\
> **Symptom:** Uploading videos larger than 500MB may cause the application to
> terminate unexpectedly.\
> **Workaround:** Compress videos before upload, or use the dedicated
> `ChunkedUpload` helper class for large files.\
> **Context:** The standard upload helper is optimized for small assets
> (images/documents).

## When to Use Each

**Write a bug report when:**

- You want the library to change.
- You are communicating with maintainers.
- The behavior prevents a valid use case.
- You believe the behavior is unintentional.

**Write a known issue when:**

- You are documenting how to use an API.
- You are helping other developers succeed right now.
- The library behavior is unlikely to change soon (or is a design trade-off).
- You want to reduce confusion for your team.

## Key Principle

The raw technical content is often identical, but the framing determines the
action required.

1. **Action:** Who needs to do the work? (Maintainer vs. User)
2. **Acceptance:** Is this a problem to be eradicated (Bug) or a reality to be
   navigated (Known Issue)?
