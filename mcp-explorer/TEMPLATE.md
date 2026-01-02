# Agent Capabilities & MCP Tool Registry

## 1. Current Status

**Status:** [INITIALIZING / DISCOVERING / TESTING / SYNTHESIZING /
COMPLETED]\n**Last Updated:** <!-- YYYY-MM-DD HH:MM -->\n**Next Immediate
Action:** <!-- e.g., "Test Tool B return values" -->

---

## 2. Executive Summary

<!-- High-level overview of what tools are connected and the primary domains they cover -->

---

## 3. Tool Inventory

> **Legend:** ⬜ Untested | 🟨 Smoke Tested | ✅ Verified | 🛑 Blocked

### Server: <!-- Server Name -->

| Tool        | Purpose                    | Status | Notes               |
| :---------- | :------------------------- | :----- | :------------------ |
| `tool_name` | <!-- Brief description --> | ⬜     | <!-- Quick note --> |

#### Verified Tool Details

<!-- For each VERIFIED tool, add a compact entry below -->

**Tool:** `tool_name`

- **Signature:** `(param1: type, param2?: type) -> ReturnType`
- **Verified Input:**

  ```json
  // Minimal valid payload
  ```

- **Verified Output:**

  ```json
  // Observed response structure (redacted)
  ```

- **Side Effects:** <!-- e.g., "Writes to disk", "Costly" -->
- **Constraints:** <!-- e.g., "Max 50 items", "Requires API key" -->

---

## 4. Capability Matrix & Workflows

### Capability Categories

<!-- Group tools by function: Search, Transform, Execute, etc. -->

- **Category A:** `tool_1`, `tool_2`
- **Category B:** `tool_3`

### Integration Patterns (The "Combo" List)

<!-- Validated combinations of tools to solve specific problems -->

#### Recipe 1: <!-- Name (e.g., "Market Research Report") -->

- **Goal:** <!-- What does this solve? -->
- **Tools:** `tool_A` → `tool_B`
- **Logic:**
  1. Call `tool_A` with `...` to get `id`.
  2. Pass `id` to `tool_B` to get `details`.
- **Example Code/Snippet:**

  ```javascript
  // Pseudo-code or actual verified call chain
  ```

---

## 5. Troubleshooting & Limitations

- **Known Issues:**
  - `tool_X`: Fails if input > 1MB.
- **Missing Auth:**
  - `tool_Y`: Requires scope `write:files`.

---

## 6. Raw Exploration Logs (Optional)

<!-- Keep brief; move older logs to archive if file grows too large. -->

- **[Timestamp]** Verified `tool_A`. Output matches schema.
- **[Timestamp]** Failed to call `tool_B` (403 Forbidden).
