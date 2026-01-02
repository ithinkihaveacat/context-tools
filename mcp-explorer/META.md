Write a comprehensive set of system instructions for an autonomous AI agent
equipped with Model Context Protocol (MCP) tools.

The goal of these instructions is to guide the agent to autonomously explore its
environment and produce two definitive, evidence-backed artifacts:

1. **`CAPABILITIES.md`**: A comprehensive "Operator Manual" detailing the
   findings.
2. **`TEMPLATE.md`**: A clean, reusable template based on the structure of
   `CAPABILITIES.md` that can be used for future explorations.

**Key Requirements for the Agent's Instructions:**

1. **Objective:** The agent must inventory all available tools, verify their
   functionality, and most importantly, discover how to **compose** them into
   useful workflows (e.g., chaining a "search" tool with a "visualization"
   tool).
2. **Empirical Verification:** The agent should not blindly trust tool
   descriptions. It must be instructed to perform safe "smoke tests" and
   boundary tests to document actual inputs, return schemas, and side effects.
3. **State Persistence (Critical):** Since this exploration may exceed the
   agent's context window, the instructions must strictly enforce that the agent
   uses `CAPABILITIES.md` as its external memory.
   - The agent must write to **`CAPABILITIES.md`** incrementally.
   - The file must track current status and next steps.
   - If the agent is restarted, it must be able to resume work solely by reading
     `CAPABILITIES.md`.
4. **Template Generation:** The agent must produce **`TEMPLATE.md`**. Unlike the
   incremental manual, this file can be written once (typically after the
   structure is finalized) to serve as a blueprint for the documentation.
5. **Structure:** The instructions should guide the agent to organize the output
   into sections like Tool Inventory, Verified Schemas, and Composition
   Recipes/Workflows.

Please provide the raw instructions that can be pasted directly to the agent to
initiate this self-discovery process.
