# MCP Explorer

A framework for autonomous AI agents to explore, verify, and document Model
Context Protocol (MCP) tools and their composition patterns.

## Purpose

This repository provides a standardized method for turning an autonomous agent
into a **Senior Capabilities Analyst**. It solves the problem of "context drift"
during long exploration sessions by using the file system as an external memory
bank.

## Core Components

The repository is structured around three primary files that work together to
initiate an exploration:

- **[META.md](./META.md)**: The "Meta-Prompt." This file contains the high-level
  requirements and logic used to generate the agent instructions. Use this if
  you want to update the core philosophy or requirements of the exploration.
- **[INSTRUCTIONS.md](./INSTRUCTIONS.md)**: The "Agent Prompt." This is a
  ready-to-use, comprehensive instruction set that you can paste directly into
  an AI agent (like Gemini, Claude, or ChatGPT) that has MCP tools configured.
- **[TEMPLATE.md](./TEMPLATE.md)**: The "Blueprint." This file provides a clean,
  standardized structure for the resulting documentation. The agent uses this to
  initialize the report.

## The Output

When the instructions are executed, the agent will produce:

- **`CAPABILITIES.md`**: A living, evidence-backed operator manual that details
  verified tool schemas, side effects, and "Recipes" (multi-tool workflows).

## How to Use

1. Configure your AI agent with the MCP servers you wish to explore.
2. Copy the entire contents of **`INSTRUCTIONS.md`**.
3. Paste the instructions into the agent's chat.
4. The agent will begin writing to `CAPABILITIES.md` and `TEMPLATE.md`
   autonomously.
5. If the agent runs out of context, simply ask it to "Continue" or "Restart,"
   and it will resume based on the state saved in `CAPABILITIES.md`.
