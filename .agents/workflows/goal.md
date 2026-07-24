# Workflow: Autonomous Developer Goal Loop (/goal)

## Sequence
The `/goal` command launches the orchestrator background task to execute development sequentially:

> [!IMPORTANT]
> **Strict Sequential Execution Policy & Autonomous Loop**
> The development loop executes strictly sequentially—one user story at a time—and operates **100% autonomously** without human-in-the-loop chat pauses. Specification quality is enforced automatically by the `/review-spec` sub-agent before landing on the issue branch.


```mermaid
graph TD
    A["Start /goal"] --> B["/specify (Fetch Issue & Draft SPEC.md)"]
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

