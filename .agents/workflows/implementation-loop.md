---
description: 
---

# Workflow: Autonomous Implementation Loop (/implementation-loop)

## Sequence
The `/implementation-loop` workflow launches the orchestrator background task to execute development sequentially:

> [!IMPORTANT]
> **Strict Sequential Execution Policy & Autonomous Loop**
> The development loop executes strictly sequentially—one user story at a time—and operates **100% autonomously** without human-in-the-loop chat pauses. Specification quality is enforced automatically by the `/review-spec` sub-agent before landing on the issue branch.

## Pre-Flight Verification Gate

Before initiating the autonomous cycle, the orchestrator MUST verify GitHub connectivity and backlog state:

1. **Verify GitHub Authentication**:
   Execute `gh auth status`. If the command fails or returns `HTTP 401: Bad credentials`, **HALT IMMEDIATELY** with the error:
   > `[CRITICAL ERROR] GitHub authentication required. Run 'gh auth login' before executing /goal.`
   Do NOT fall back to local execution.

2. **Verify GitHub Issues Exist**:
   Execute `gh issue list`. If zero open issues exist for sealed PRD stories, **HALT IMMEDIATELY** with the error:
   > `[CRITICAL ERROR] No open GitHub issues found for PRD stories. Run /prd2backlog first to seed the GitHub issue backlog.`


```mermaid
graph TD
    A["Start /implementation-loop"] --> B["/specify (Fetch Issue & Draft SPEC.md)"]
    B --> C["/review-spec (Adversarial Audit)"]
    C -->|Fails Audit| B
    C -->|VERDICT: APPROVED| D["/tdd-build (Red-Green-Refactor)"]
    D -->|Circuit Breaker Tripped| E["Circuit Breaker Takeover"]
    D -->|Tests Pass (>=90%)| F["/e2e-test (Playwright)"]
    F -->|E2E Failure| D
    F -->|E2E Passed| G["/ship (Pre-Commit Gates & Merge)"]
    G --> H["GitHub PR Squash & Merge & Traceable Commit"]
```

## Context Reset Guidelines
At each transition, clear global context, invoking the stateless sub-agent with only current files, the specific `SPEC.md`, and `docs/architecture.md`.
