# The Anatomy of a Pull Request Description

Think of a Pull Request (PR) description not merely as a formality, but as the
"pitch" for your code. While the code implementation tells the computer what to
do, the description persuades the reviewer that the change is necessary, safe,
and architecturally sound—especially when contributing to a codebase you do not
own.

This document outlines how to structure a PR description to ensure clarity and
mergeability.

## The Core Objectives

A strong PR description does not just summarize code; it addresses four specific
needs of the reviewer:

| Objective              | Question Answered                                 |
| ---------------------- | ------------------------------------------------- |
| **Problem Definition** | Why are we doing this at all?                     |
| **Solution Details**   | How does this actually work?                      |
| **Quality Assurance**  | Why is this safe to merge and how do I verify it? |
| **Strategic Context**  | Why is this the _best_ approach?                  |

## The Structure of a Description

To meet these objectives, a PR description should follow a logical narrative
structure. Feel free to adapt the specific section titles or bullet points to
match the repository’s customs or requirements.

### 1. The Purpose and Problem

Before explaining the solution, clearly define the deficiency.

- **The Problem:** Describe the bug, limitation, or missing feature.
- **Context:** Support your argument with **hyperlinks**. If the behavior
  contradicts documentation, link directly to the relevant section. Link to
  related bug reports, tracking tickets, or specific source symbols
  (classes/methods) to help the reviewer navigate the context immediately.
- **Evidence:** Explain how the problem can be reproduced. For UI issues or
  complex workflows, **screenshots or screen recordings** are often the most
  effective way to demonstrate the defect instantly.
- **Severity:** Justify why this warrants attention (e.g., "Blocks the payment
  flow" vs. "Cosmetic alignment issue").

### 2. Solution Details

Summarize the logic of the change and its architectural fit.

- **The Fix:** In summary, how does this change solve the problem?
- **Architecture:** How does this interact with the system? (e.g., "Leverages
  the existing `EventBus` to decouple the logic," or "Reuses the shared
  `ValidationMiddleware` to match existing API behavior").
- **Breaking Changes & Commitments:** Explicitly call out any design decisions
  that are consequential and **difficult to reverse** (e.g., breaking public API
  changes, database schema modifications, introducing new heavy dependencies, or
  establishing data format contracts for external consumers).

### 3. Quality, Safety, and Verification

Provide evidence that the change is high quality, and instruct the reviewer on
how to confirm it.

- **Verification Instructions:** Don't just list the tests you ran; explain how
  the reviewer can test it themselves. If specific states are required (e.g.,
  "The database must have a user with 0 roles"), list the setup steps
  explicitly.
- **Compliance:** If the repository has a standard contribution checklist or
  style guide, explicitly note that you have completed those steps.
- **Risk Profile:** Explain why the risk is managed (e.g., "Behind a feature
  flag," "Backwards compatible").

### 4. Alternatives Considered

Demonstrate due diligence by briefly mentioning other paths not taken.

- **Comparison:** If other approaches were tried, why were they discarded?
- **Superiority:** Explain why the current approach is safer, faster, or
  cleaner.

## Language and Tone

**Vague language:**

- "Fixed the bug."
- "Refactored the code."
- "Works on my machine."
- "Better logic."

**Confident language:**

- "Corrects a race condition by..."
- "To verify, run the seeder script X..."
- "Isolates impact to [Module X] to minimize regression risk."
- "This approach was chosen over [Alternative] because..."

## Examples

### Example 1: Database Query Fix

**As a Weak Description**

> **Title:** Fix slow query\
> I changed the user lookup because it was slow. I added a join. It works better
> now and I tested it locally.

**As a Strong Description**

> **Title:** Optimize `UserLookup` via Eager Loading\
> **The Problem:** The `UserLookup` endpoint triggers an N+1 query issue when
> fetching roles, causing 500ms latency. This contradicts the performance
> guidelines in [Server Docs v2].\
> **Solution Details:** Implements eager loading for `Roles` within the main
> repository query. This fits the existing Repository pattern by modifying
> `findWithRoles` (see [AbstractRepo]).\
> **Breaking Changes & Commitments:** This modifies the shared `AbstractRepo`
> interface, which will require updates to the `MockRepo` in the test suite.\
> **Verification:** I have verified this locally using the `seed_large_db`
> script. To verify:\
>
> 1. Run the seeder.\
> 2. Hit `GET /users`.\
> 3. Check logs to confirm query count dropped from N+1 to 1.\
>    **Safety:** Added a unit test covering this scenario.

### Example 2: Establishing a Public Data Contract

**As a Weak Description**

> **Title:** Add JSON Export\
> Added a way to get reports as JSON. The structure is just a dump of the
> object.

**As a Strong Description**

> **Title:** Introduce `v1` Standardized JSON Export\
> **The Problem:** Integrators currently scrape HTML to extract report data,
> which is brittle and breaks whenever we change CSS classes.\
> **Solution Details:** Adds a dedicated `?format=json` endpoint. The output
> uses a flat structure for ease of parsing by third-party tools.\
> **Breaking Changes & Commitments:** We are committing to the "Flat Field"
> naming convention (e.g., `user_email` rather than nested `user: { email }`).
> This is a one-way door; changing this structure later will be a breaking
> change for all integrators using this export.\
> **Verification:**\
>
> 1. Request `GET /reports/daily?format=json`.\
> 2. Verify the `Content-Type` header is `application/json`.\
> 3. Verify keys match the Swagger spec attached.\
>    **Alternatives Considered:** We considered nesting user data, but rejected
>    it to maintain compatibility with the existing CSV export parser logic.

## Key Principle

A Pull Request description is a tool for conveying **confidence**.

1. **Confidence in the Problem:** You understand the root cause and have
   verified it against documentation/specs.
2. **Confidence in the Solution:** You understand how your code interacts with
   the broader architecture and have flagged any irreversible choices.
3. **Confidence in Safety:** You have provided a clear path for the reviewer to
   verify the fix themselves.
