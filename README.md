### Disclaimer and Credits :
- This repo took several of its ideas from the incredible **SDD-design** [repo](https://github.com/npintaux/sdd-plugin) made by *Nicolas Pintaux*  and is less focus in development excellence but rather on full automation.
- At this stage, this work is relying on Antigravity IDE workflows, which is NOT available in Antigravity CLI or Antigravity 2.0.

# **Autonomous Developer Suite — Production-Grade Agentic Blueprint**

This repository contains the complete, production-grade implementation of the **Autonomous Development Driven by AI Agents** architecture. By pairing structured specification-driven skills with deterministic, zero-token verification hooks, this suite bridges the gap between AI autonomy and absolute engineering rigor.

Developed under the standards of **Google Antigravity**, **Conductor**, and the **Gemini Cookbook**, this package enables any repository to immediately instantiate a self-documenting, self-testing, self-securing, and self-shipping development environment.

---

## **1. Architectural Philosophy: "A Skill Asks; A Hook Imposes"**

The suite relies on a strict dual-control plane model:
1. **Interactive Skills (Method Plane)**: Specialized workflows carrying business judgment, persona-driven interviews, adversarial specification audits, and contract-first code generation. Written in Markdown and executed inside the AI context.
2. **Deterministic Hooks (Enforcement Plane)**: Zero-token, ultra-fast execution blocks running completely outside the LLM. If tests fail, coverage drops below **90%**, security scans detect vulnerabilities, or unauthorized DB drops are attempted, execution is locked.

```
                          ┌───────────────────────────┐
                          │    Human Product Owner    │
                          └─────────────┬─────────────┘
                                        │
                                  /interview-me
                                   (Workflow)
                                        ▼
     ┌─────────────────────────────────────────────────────────────────────┐
     │                      Upstream Scoping Pipeline                      │
     │  /interview-prd ───► /audit-prd ───► /arch-gate ───► /prd2backlog   │
     │  (6-Pillar Grid)     (Seals PRD)     (Blueprint)     (Intake Issues)│
     └──────────────────────────────────┬──────────────────────────────────┘
                                        │
                                        ▼
                          ┌───────────────────────────┐
                          │ GitHub Issues (Backlog)   │
                          └─────────────┬─────────────┘
                                        │
                              /implementation-loop
                                   (Workflow)
                                        ▼
     ┌─────────────────────────────────────────────────────────────────────┐
     │                     Engineering Sub-Agents                          │
     │  /specify ───────────────► /review-spec ────────────► /tdd-build    │
     │  (Stage: Ready)            (Stage: Spec Reviewed)   (Stage: In Prog)│
     │                                                            │        │
     │  /ship ◄────────────────── /e2e-test ◄──────────────────────┘        │
     │  (Stage: Done)             (Stage: In Review)                       │
     └──────────────────────────────────┬──────────────────────────────────┘
                                        │
                               ┌────────▼────────┐
                               │ src/core & shell│
                               └────────┬────────┘
                                        │
                       [Git Commit / Pre-Commit Hooks]
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
    [Linter Enforcement]       [Unit Tests & E2E]       [Trivy & Secrets Scan]
    (ruff/eslint/shellcheck)   (coverage >= 90%)          (HIGH/CRITICAL keys)
```

---

## **2. Standardized Directory Tree**

Bootstrapping a project with this suite deploys the following structure:

```
my-project/
├── AGENTS.md                    # Project Constitution (FC/IS, model cascading, circuit breakers)
├── SPEC.md                      # Active Behavioral Specification Contract (archived in docs/specs/)
├── .agents/
│   ├── hooks.json               # Deterministic trigger & tool permission definitions
│   ├── default-ruff.toml        # Fallback Ruff Python linter configuration
│   ├── default-eslint.json      # Fallback ESLint JavaScript/TypeScript linter configuration
│   ├── conventions/             # Code layout contract harness definitions
│   │   ├── code-layout.md       # Human-readable module and package rules
│   │   └── code-layout.env      # Machine-readable layout invariants for hooks
│   ├── rules/                   # Supreme agent compliance rules
│   │   ├── fc-is-architecture.md# [R-ARCH] Functional Core vs Imperative Shell
│   │   ├── model-cascading.md   # [R-MODEL] Gemini model cascading & token routing (https://ai.google.dev/gemini-api/docs/latest-model)
│   │   ├── circuit-breakers.md  # [R-BREAK] Strike counters and takeover action
│   │   └── traceability.md      # [R-TRACE] PRD Rule to commit mapping
│   ├── workflows/               # Pre-defined orchestration procedures
│   │   ├── implementation-loop.md # Autonomous implementation loop sequence
│   │   └── interview-me.md      # Guided scoping and interview sequence (/interview-me)
│   └── skills/                  # Procedural skill files per persona
│       ├── interview-prd/       # [PO] Guided 6-pillar scoping and web search matrix
│       ├── audit-prd/           # [PO] 5-check completeness grid audit & PRD sealer
│       ├── arch-gate/           # [PO/ENG] Upstream technology decision gate & AI data patterns
│       ├── prd2backlog/         # [PO] Backlog generator & idempotent reconciliation
│       │   └── templates/STORY.template.md
│       ├── specify/             # [ENG] Specification drafter & stage manager
│       │   └── templates/SPEC.template.md
│       ├── review-spec/         # [ENG] Adversarial 5-check specification auditor
│       ├── tdd-build/           # [ENG] Test-driven core/shell builder & 2-level tests
│       │   └── templates/
│       │       ├── code-layout.template.md
│       │       └── code-layout.env.template
│       ├── e2e-test/            # [ENG] Playwright E2E browser agent validator
│       └── ship/                # [ENG] Automated remote PR creation, CI watcher & squash-merger
├── docs/                        # Specifications, contracts, and state
│   ├── PRD.md                   # Validated PRD (100% 360° completeness, status: sealed)
│   ├── architecture.md          # Infrastructure contracts sealed by arch-gate
│   └── specs/                   # Archived issue specifications
├── scripts/
│   ├── init-project.sh          # Automated project initializer script (v5.0 Remote-Ready)
│   └── hooks/                   # Zero-token hook scripts
│       ├── pre-commit-lint.sh   # Syntactic/styling checker & commit message format gate
│       ├── pre-commit-test.sh   # Run tests + apply isomorphic log trimming
│       ├── pre-commit-coverage.sh # Validate >=90% test coverage floor
│       ├── pre-commit-security.sh # Run Trivy security checks + secrets search
│       ├── on-interrupt.sh      # Environment credential validator
│       ├── on-circuit-breaker.sh# Coordinated human takeover state log
│       └── on-architecture-drift.sh # Architectural contract defender
└── src/                         # System Source Code
    ├── core/                    # Functional Core (Pure deterministic logic, 0 IO/DB)
    └── shell/                   # Imperative Shell (IO, DB, HTTP APIs)
```

---

## **3. Getting Started (Installation & Initialization)**

### **Prerequisites**
- Git installed and initialized.
- GitHub CLI (`gh`) installed and authenticated with `project` scope:
  ```bash
  gh auth login -s project
  # or to refresh permissions on an existing login:
  gh auth refresh -s project
  ```
  *(The `project` OAuth scope is mandatory for automated GitHub Project V2 Stage transitions).*
- Standard developer runtime (Python 3.8+ or Node.js 16+).
- Recommended global packages (automatically detected and used if present):
  - Python: `ruff`, `pylint`, `pytest`, `coverage`
  - JS: `eslint`, `jest`
  - Security/Container: `trivy`, `shellcheck`, `jq`

---

### **Option 1: One-Liner Remote Initialization (Recommended)**

You can instantly bootstrap **any empty directory or existing project** directly from GitHub without cloning this repository first.

Open your terminal in your target project folder and run one of the following commands:

**Using `curl` (Linux / WSL / macOS)**:
```bash
curl -fsSL https://raw.githubusercontent.com/lambertaurelle/autonomous-developer-suite/main/scripts/init-project.sh | bash
```

**Using `wget` (Linux / WSL / macOS)**:
```bash
wget -qO- https://raw.githubusercontent.com/lambertaurelle/autonomous-developer-suite/main/scripts/init-project.sh | bash
```

**Using `bash <(...)`**:
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/lambertaurelle/autonomous-developer-suite/main/scripts/init-project.sh)
```

*What the one-liner initializer does automatically:*
1. **GitHub Setup**: Verifies `gh` CLI authentication and mandatory `project` scope. Interactively prompts to create a private or public GitHub repository (`gh repo create`) if no `origin` remote exists.
2. **Directory Architecture**: Constructs `.agents/skills/`, `.agents/rules/`, `.agents/workflows/`, `.agents/conventions/`, `docs/specs/`, `src/core/`, `src/shell/`, and `scripts/hooks/`.
3. **Downloads Production Governance & Skills**: Pulls all full production files (`AGENTS.md`, 9 skills, rules, workflows, templates, and pre-commit hook scripts) directly from GitHub raw endpoints.
4. **Enforces Line Endings**: Creates `.gitattributes` to enforce Unix LF line endings across Windows, Linux, and WSL.
5. **Configures Verification Gates**: Makes all verification hook scripts executable (`chmod +x scripts/hooks/*.sh`).

---

### **Option 2: Local Clone Initialization**

If you prefer to clone this repository into a new workspace:

```bash
git clone https://github.com/lambertaurelle/autonomous-developer-suite.git my-project
cd my-project
```

Your cloned project comes pre-configured with all governance files, skills, workflows, templates, and hooks!

If you ever want to re-run or re-initialize:
```bash
./scripts/init-project.sh
```

---

### **Next Steps: Start Product Scoping**

Once initialized, launch the interactive product requirements & scoping pipeline:

```text
/interview-me
```

---

## **4. Detailed Workflows, Skills, and Persona Pipelines**

The suite divides responsibility between two primary agent personas and workflows:

### **4.1 Product Owner Persona & Upstream Pipeline (`/interview-me`)**
- **/interview-me (Workflow)**: Upstream scoping pipeline that orchestrates the product owner intake sequence: `/interview-prd` → `/audit-prd` → `/arch-gate` → `/prd2backlog`.
- **/interview-prd (v2.1.0)**: Leads an interactive scoping interview with the Product Owner to generate `docs/PRD.md` following the canonical 12-section structure. Evaluates the 6-pillar 360° Completeness Grid (Functional Vision, Stack & Architecture, Data Strategy, Infra & Deployment, Security & Compliance, Non-Functional & UX), creates multi-pillar User Stories (`US1`..`USn`), and triggers **Augmented Recommendation Mode** (Web Search Matrix & Synthetic Decision Matrix) when technical or architectural choices are unassigned.
- **/audit-prd (v2.0.0)**: Inflexible 5-check linter auditing `docs/PRD.md` against the 12 canonical sections, 6-pillar grid, multi-pillar user story backlog, testable acceptance criteria, and functional/non-functional traceability. Technically blocks downstream execution until 100% compliant, then seals `docs/PRD.md` (`status: sealed`).
- **/prd2backlog (v4.0.0)**: Decomposes the sealed PRD into a prioritized list of atomic user stories and publishes or reconciles them as GitHub Issues via the `github` MCP server using `STORY.template.md`. Stamps hidden `prd-sync` HTML markers (`<!-- prd-sync: key=us<n> src-sha=<short_hash> -->`) and applies GitHub metadata labels (`status:draft`, `must-have`, `should-have`, `could-have`) for 100% idempotent reconciliation without redundant API writes.

### **4.2 Engineering Persona & Autonomous Loop (`/implementation-loop`)**
- **/implementation-loop (Workflow)**: Autonomous execution loop orchestrating the engineering sub-agents sequentially for each backlog story: `/specify` → `/review-spec` → `/tdd-build` → `/e2e-test` → `/ship`.
- **/arch-gate (v3.1.0)**: Analyzes the sealed PRD to produce the immutable blueprint `docs/architecture.md`. Evaluates data volume and query semantics to select the optimal **AI Data Integration Pattern** (Pattern A: Direct Context Injection, Pattern B: Text-to-SQL / Dynamic Tool Use, Pattern C: RAG / Vector Search), enforces Functional Core (`src/core/`) vs. Imperative Shell (`src/shell/`) boundaries, presents a single-screen decision matrix to the human architect, and registers the Architecture Drift Watcher Hook.
- **/specify (v4.0.0)**: Intakes user story acceptance criteria from GitHub via the `github` MCP server with strict input context boundaries (reading ONLY the target Issue, `templates/SPEC.template.md`, and active `SPEC.md`). Scaffolds `.agents/conventions/code-layout.md` and `code-layout.env` if missing. Runs **fully autonomously** inside `/implementation-loop`, using the adversarial `/review-spec` sub-agent for zero-HITL specification audits before landing `SPEC.md` on an `issue/<number>-<title>` branch and updating the GitHub Project Stage to **`Ready`**.
- **/review-spec (v4.0.0)**: Dedicated adversarial reviewer sub-agent that audits `SPEC.md` drafts against `templates/SPEC.template.md`, `docs/PRD.md`, and `docs/architecture.md` across 5 checks: Canonical Template Compliance, Sequential Rule Integrity (`R1`, `R2`, ...), Self-Sufficiency Audit, Strict Scope-Creep Defense, and Architectural Boundary Alignment. On `VERDICT: APPROVED`, transitions GitHub Project Stage to **`Spec Reviewed`**.
- **/tdd-build (v3.1.0)**: Executes a strict **TDD Red-Green-Refactor** cycle using stateless sub-agents. Writes 2-level tests (Unit isolation + Engine compositional assertions `evaluate(input) -> outcome, ["Rn"]`), enforces pure Functional Core isolation (zero DB/IO imports in `src/core/`), central linter configuration discipline, log trimming/error feeding, strike-5 circuit breaker lockout, and **Eval-Driven Development (EDD)** golden dataset testing for embedded AI features. Updates GitHub Project Stage to **`In Progress`**.
- **/e2e-test (v3.0.0)**: Deploys a headless browser agent running Playwright to simulate end-to-end user journeys, happy paths, edge cases, and rollback flows against the integrated application. Includes an automated zombie process port resolver (default port 3000) and 5-attempt circuit breaker. On success, updates GitHub Project Stage to **`In Review`**.
- **/ship (v3.2.0)**: Executes pre-commit verification gates (linting, zero TODOs, FC purity, >=90% test coverage, Trivy security scans), creates Pull Request via `gh pr create` with `Closes #n`, monitors remote CI checks via `gh pr checks --watch`, and performs remote squash-merge (`gh pr merge --squash --delete-branch`), automatically closing the issue and updating GitHub Project Stage to **`Done`**. Automatically syncs local workspace back to `main` (`git checkout main && git pull`). Enforces a strict **FORBIDDEN FALLBACK** policy against local squash-merging when GitHub authentication fails.

---

## **5. Zero-Token Hook Gates & Tool Security Shell**

Our hooks act as immediate circuit-breakers to protect repository integrity:

### **1. Pre-Commit Lint & Commit Traceability (`pre-commit-lint.sh`)**
- Scans staged files on commit.
- Enforces mandatory commit message rule traceability convention: `type(scope): summary [Rn] (#issue_id)`.
- Runs `ruff` or `pylint` on Python files (falling back to `.agents/default-ruff.toml`); runs `eslint` on JS/TS (falling back to `.agents/default-eslint.json`); runs `shellcheck` on `.sh` scripts.
- Falls back to native compiler validation (e.g. `py_compile`, `node -c`) if premium tooling is absent.

### **2. Pre-Commit Test Runner (`pre-commit-test.sh`)**
- Detects the active project framework and runs `pytest` or `jest`/`npm test` automatically.
- **Log Trimming Protocol**: On failure, strips framework stack traces and dumps *only* the file name, line index, and precise assertion error message to optimize token usage.

### **3. 90% Test Coverage Gate (`pre-commit-coverage.sh`)**
- Evaluates test suite coverage from coverage reports (`.coverage`, `coverage.xml`, or Jest `coverage-summary.json`).
- If total line coverage is below **90%**, it blocks the commit, forcing the agent to write comprehensive test suites before shipping.

### **4. Security & Secrets Scan (`pre-commit-security.sh`)**
- Scans files for hardcoded secrets, passwords, or API keys using localized high-entropy regex matchers.
- Triggers Trivy filesystem checks (`trivy fs . --severity HIGH,CRITICAL`) to discover dependency vulnerabilities.

### **5. Environment Intercept Hook (`on-interrupt.sh`)**
- Triggers upon background execution interrupts (e.g. missing API credentials).
- Scans environment variables and local `.env` files for mandatory variables (e.g., `GEMINI_API_KEY`), raising warnings and pausing execution loop state.

### **6. Strike 5 Circuit Breaker (`on-circuit-breaker.sh`)**
- Activated when the autonomous TDD loop fails for 5 recursive attempts on the same bug.
- Suspends the loop, saves all code modifications, takes a snapshot dump into `.agents/circuit_breaker_state.log`, checkouts to an emergency isolation branch (`drift/circuit-breaker-<timestamp>`), and halts the pipeline for human developer takeover.

### **7. Architecture Drift Protection (`on-architecture-drift.sh`)**
- Intercepts any staged changes modifying the sealed, immutable `docs/architecture.md` document.
- Rejects unauthorized commits to enforce that AI agents cannot unilaterally alter tech stacks or architecture.

### **8. Pre-Tool Database Protection (`PreToolUse` in `hooks.json`)**
- Intercepts tool execution calls outside the LLM context.
- Parses `$TOOL_ARGUMENTS` and blocks destructive SQL statements (e.g. `DROP DATABASE`, `DROP TABLE`, `DELETE FROM users`).

---

## **6. Rule Traceability Commit Format**

To maintain absolute compliance and clear trace lines from stakeholder requirements down to production code, all commits generated by the suite must match:

```
<type>(<scope>): <summary> [Rn] (#issue_id)
```

- **Types**: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`
- **Scope**: `core` (for business logic), `shell` (for technical wrappers/IO)
- **Trace tag `[Rn]`**: Explicitly lists the PRD requirement ID (e.g., `[R12]`).
- **Issue ID `(#xxx)`**: The mapped task or GitHub issue number.

*Example Commit:*
```bash
feat(core): implement compound interest penalty logic [R14] (#102)
```

---

## **7. Testing and Manual Verification**

To confirm all gates are fully active:

1. **Verify Lint Gate**:
   - Create a python file with deliberate syntax errors, stage it, and commit:
     ```bash
     echo "def invalid_func(" > src/core/test_err.py
     git add src/core/test_err.py
     git commit -m "test(core): commit syntax error [R1] (#1)"
     ```
   - *Expected Outcome*: Linter hook catches the error and blocks the commit.

2. **Verify Architecture Integrity**:
   - Try to modify the architecture document directly:
     ```bash
     echo "Modified db to SQLite" >> docs/architecture.md
     git add docs/architecture.md
     git commit -m "refactor(shell): change db contract [R2] (#2)"
     ```
   - *Expected Outcome*: Hook intercepts the staged file change and blocks the commit to prevent architecture drift.

3. **Verify Secrets Protection**:
   - Add a mock secret key to a source file:
     ```bash
     echo "GEMINI_API_KEY = \"AIzaSyB-vX_DeliberateSecretKey12345\"" >> src/shell/adapter.py
     git add src/shell/adapter.py
     git commit -m "chore(shell): configure credentials [R3] (#3)"
     ```
   - *Expected Outcome*: Security hook intercepts high-entropy secret string and aborts commit.
