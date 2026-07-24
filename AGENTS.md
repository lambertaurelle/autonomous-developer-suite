# **Project Constitution: AGENTS.md**
This document serves as the supreme governance charter and architectural constitution for all AI agents and sub-agents executing operations within this repository. All background tasks and autonomous development cycles must strictly adhere to the rules, cascades, and isolation protocols detailed below.

---

## **1. Core Architectural Pillars**

### **1.1 "A Skill Asks; A Hook Imposes"**
- **Skills (Method)**: Located under `.agents/skills/`, these describe procedures, guidelines, and workflows carrying logical judgment. They suggest the path but cannot guarantee execution correctness.
- **Hooks (Enforcement)**: Located under `scripts/hooks/` and registered in `.agents/hooks.json`, these are zero-token, absolute-compliance gates executing outside the LLM context. Any non-zero exit code blocks the autonomous loop immediately.

### **1.2 Functional Core / Imperative Shell (FC/IS)**
- **Functional Core (`src/core/`)**: Pure deterministic domain logic. Zero side effects, zero network/IO, zero databases, and zero library dependency leaks. Fully unit-tested to >= 90% coverage.
- **Imperative Shell (`src/shell/`)**: External technical wrapper handling network requests, HTTP APIs, file systems, databases, and standard environment IO. Injects sanitized data into the Functional Core and executes Core-driven side effects.

### **1.3 End-to-End Traceability**
Every modification, specification, and execution must trace directly back to PRD Rule IDs (`[Rn]`) and issue numbers (`#xxx`). All commits generated autonomously must match:
`type(scope): brief summary [Rn] (#issue_id)`

---

## **2. Resource and Token Optimization**

### **2.1 Model Cascading Routing Table**
We utilize Gemini models and cascading principles to minimize costs while maintaining extreme production quality. Always reference the official [Google AI Latest Gemini Models Documentation](https://ai.google.dev/gemini-api/docs/latest-model) for up-to-date model capabilities and selection:
- **Gemini 3.5 Flash-Lite**: Default high-throughput model for routine tasks (`/audit-prd`, `/prd2backlog`, `/review-spec`, `/ship`), formatting, lint error cleaning, log trimming, spec checks, and test-suite parsing.
- **Gemini 3.6 Flash**: Model for deep reasoning and complex coding tasks (`/interview-prd`, `/arch-gate`, `/specify`, `/tdd-build`, `/e2e-test`), architectural drafting, TDD cycle debugging, complex refactoring, and interactive interviews.

### **2.2 Stateless Sub-Agent Cycles**
To prevent context rot, background agents must clear their history at each test/fix cycle. The active sub-agent context window is strictly constrained to:
1. `docs/architecture.md` (System contracts)
2. `SPEC.md` (The active behavioral contract; archived copies in `docs/specs/`)
3. Modified source files and direct test output.

### **2.3 Log Trimming & Diff Patching**
- **Trimming**: Terminal outputs from test failures must be stripped of framework stack traces, passing only the file name, offending line, and exact assertion failure message.
- **Patching**: Regeneration of entire large files is strictly forbidden. Sub-agents must output targeted diff/patch blocks.

---

## **3. Execution Circuit Breaker**
- **Hard Limit**: A maximum of 5 recursive fix attempts is enforced for any failing test cycle.
- **Trip Handler**: On the 5th failure, the loop is paused, state is committed to a local emergency branch `drift/circuit-breaker-xxx`, and control is handed back to the human developer.

---

## **4. Database Integration & Grounding Protocols**
- **Read-Only Sandboxing**: Direct SQL generation must execute under restricted database credentials preventing destructive actions (e.g., `DROP`, `TRUNCATE`).
- **PII Masking**: Personal identifiable information must be redacted before being exposed to LLM contexts.
- **Factual Grounding**: System prompts compel the agent to state "I do not have factual evidence" rather than extrapolating or inventing missing data.

---

## **5. GitHub Synchronization & Project Management**
To ensure full synchronization with GitHub for Project Management, we enforce a strict integration using standard Git CLI, GitHub (`gh`) CLI, and the `github` MCP server:
- **Repository Setup (`init-project`)**: Checks if `gh` is installed, verifies auth status, and interactively prompts to create a public/private GitHub repository if no 'origin' remote exists.
- **Backlog Generation (`/prd2backlog`)**: All backlog items extracted from sealed `docs/PRD.md` are automatically created or reconciled as GitHub Issues via the `github` MCP server (or `gh issue create`). The assigned GitHub Issue ID (e.g., `#123`) is dynamically parsed and saved to metadata.
- **Autonomous Specification Drafting (`/specify`)**: Pulls user story criteria from GitHub via the `github` MCP server, drafts `SPEC.md` at repository root, validates automatically via `/review-spec` sub-agent audit (zero HITL pauses), creates `issue/<number>-<title>` branch, commits `SPEC.md`, transitions GitHub issue state to `in-progress`, and hands off to `/tdd-build`.
- **Branch & Commit Standards**: All staging (`git add`) and commits (`git commit`) utilize standard Git CLI to strictly enforce the rule-traceability format: `type(scope): summary [Rn] (#issue_id)`.
- **Merge & Pull Requests (`/ship`)**: Merges into `main` are conducted via `gh pr create --fill` and completed with Squash and Merge (`gh pr merge --squash --delete-branch`) to maintain clean main commit history.
- **Sequential Execution Policy**: The automated background development loop (`/implementation-loop`) executes strictly sequentially—one user story at a time—guaranteeing stable baselines.



