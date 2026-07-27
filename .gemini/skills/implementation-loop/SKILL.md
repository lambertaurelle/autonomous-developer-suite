---
name: implementation-loop
description: Autonomous loop to sequentially specify, audit, build (TDD), validate (E2E), and ship PRD user stories inside Antigravity CLI (/implementation-loop).
license: MIT
metadata:
  persona: Senior Autonomous Lead Developer
  type: Autonomous Execution Loop Orchestrator Skill
  version: 5.0.0
---

# Skill: Autonomous Implementation Loop (`/implementation-loop`)

## 1. Purpose & Strategic Goal
The `/implementation-loop` skill executes standard development stories sequentially and **100% autonomously** in **Antigravity CLI (`agy`)**.

For each open user story in the GitHub issue backlog, `/implementation-loop` orchestrates:
1. `/specify`: Intakes issue criteria via `gh` CLI and drafts `SPEC.md` on branch `issue/<number>-<title>`.
2. `/review-spec`: Runs adversarial subagent audit on `SPEC.md`.
3. `/tdd-build`: Executes TDD Red-Green-Refactor cycle for Functional Core (`src/core/`) and Imperative Shell (`src/shell/`).
4. `/e2e-test`: Runs Playwright end-to-end browser agent validation.
5. `/ship`: Runs pre-commit verification gates, creates PR via `gh pr create`, monitors CI, and squash-merges into `main`.

---

## 2. Pre-Flight Verification Gate

Before starting the loop, execute these mandatory CLI checks:

1. **Verify GitHub CLI Authentication**:
   Execute `gh auth status`. If authentication or required scope is missing, halt with:
   > `[CRITICAL ERROR] GitHub CLI authentication required. Run 'gh auth login -s project' before launching /implementation-loop.`

2. **Verify Open Issues Exist**:
   Execute `gh issue list --state open`. If zero issues exist, halt with:
   > `[CRITICAL ERROR] No open GitHub issues found. Run /interview-me or /prd2backlog first to seed the issue backlog.`

---

## 3. Autonomous Execution Sequence

```mermaid
graph TD
    A["Issue in Backlog"] --> B["/specify (Draft SPEC.md & Issue Branch)"]
    B -->|Stage: Ready| C["/review-spec (Adversarial Subagent Audit)"]
    C -->|Fails Audit (Max 5 Retries)| B
    C -->|VERDICT: APPROVED<br/>(Stage: Spec Reviewed)| D["/tdd-build (Red-Green-Refactor Cycle)"]
    D -->|Stage: In Progress| D
    D -->|Unit Tests Pass >=90%| E["/e2e-test (Playwright Agent)"]
    E -->|E2E Failure| D
    E -->|E2E Passed<br/>(Stage: In Review)| F["/ship (Pre-Commit Gates & Squash Merge)"]
    F -->|PR Squash & Merge| G["Issue Closed & Synced to Main<br/>(Stage: Done)"]
```

---

## 4. Context Reset & Subagent Isolation Guidelines

To prevent context rot during autonomous execution:
- After each story or test attempt, clear global agent history.
- Spawn subagents using `invoke_subagent` with strictly bounded context:
  1. `docs/architecture.md` (System contracts)
  2. Target `SPEC.md` (Behavioral contract)
  3. Modified source files and direct trimmed test outputs.
- Enforce the **Strike-5 Circuit Breaker**: If TDD build fails 5 consecutive times on the same issue, halt the loop, run `scripts/hooks/on-circuit-breaker.sh`, checkout emergency branch `drift/circuit-breaker-<timestamp>`, and notify the human developer.
