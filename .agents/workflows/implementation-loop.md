---
description: Autonomous loop to sequentially specify, build, test, and ship PRD user stories.
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
    A["Issue in Backlog"] --> B["/specify (Draft SPEC.md & Branch)"]
    B -->|Status: Ready| C["/review-spec (Adversarial Audit)"]
    C -->|Fails Audit (Max 5 Retries)| B
    C -->|VERDICT: APPROVED<br/>(Status: Spec Reviewed)| D["/tdd-build (Red-Green-Refactor)"]
    D -->|Status: In Progress| D
    D -->|Unit Tests Pass >=90%| E["/e2e-test (Playwright)"]
    E -->|E2E Failure| D
    E -->|E2E Passed<br/>(Status: In Review)| F["/ship (Pre-Commit Gates & Merge)"]
    F -->|PR Squash & Merge| G["Issue Closed<br/>(Status: Done)"]

```

## Context Reset Guidelines
At each transition, clear global context, invoking the stateless sub-agent with only current files, the specific `SPEC.md`, and `docs/architecture.md`.