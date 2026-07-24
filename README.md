# **Autonomous Developer Suite — Production-Grade Agentic Blueprint**

This repository contains the complete, production-grade implementation of the **Autonomous Development Driven by AI Agents (V3)** architecture. By pairing structured specification-driven skills with deterministic, zero-token verification hooks, this suite bridges the gap between AI autonomy and absolute engineering rigor.

Developed under the standards of **Google Antigravity**, **Conductor**, and the **Gemini Cookbook**, this package enables any repository to immediately instantiate a self-documenting, self-testing, and self-securing development environment.

---

## **1. Architectural Philosophy: "A Skill Asks; A Hook Imposes"**

The suite relies on a strict dual-control plane model:
1. **Interactive Skills (Method Plane)**: Specialized workflows carrying business judgment, persona-driven interviews, and adversarial code generation. Written in Markdown and executed inside the AI context.
2. **Deterministic Hooks (Enforcement Plane)**: Zero-token, ultra-fast bash execution blocks running completely outside the LLM. If tests fail, coverage drops below **90%**, or security scans detect vulnerabilities, the Git loop is locked.

```
                          ┌───────────────────────────┐
                          │    Human Product Owner    │
                          └─────────────┬─────────────┘
                                        │
                                 /interview-prd
                                        ▼
                          ┌───────────────────────────┐
                          │   docs/PRD.md & specs/    │
                          └─────────────┬─────────────┘
                                        │
                                      /goal
                                        ▼
                          ┌───────────────────────────┐
                          │  Engineering Sub-Agents   │
                          └─────────────┬─────────────┘
                                        │
                          ┌─────────────▼─────────────┐
                          │      src/core & shell     │
                          └─────────────┬─────────────┘
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
├── AGENTS.md                    # Project Constitution (FC/IS, cascading, circuit breakers)
├── .agents/
│   ├── hooks.json               # Deterministic trigger definitions
│   ├── rules/                   # Supreme agent compliance rules
│   │   ├── fc-is-architecture.md# [R-ARCH] Functional Core vs Imperative Shell
│   │   ├── model-cascading.md   # [R-MODEL] Gemini model cascading & token routing (https://ai.google.dev/gemini-api/docs/latest-model)
│   │   ├── circuit-breakers.md  # [R-BREAK] Strike counters and takeover action
│   │   └── traceability.md      # [R-TRACE] PRD Rule to commit mapping
│   ├── workflows/               # Pre-defined orchestration procedures
│   │   ├── goal.md              # Autonomous development goal loop sequence
│   │   └── interview-prd.md     # Guided scoping and interview sequence
│   └── skills/                  # Procedural skill files per persona
│       ├── interview-prd/       # [PO] Guided scoping and web search matrix
│       ├── audit-prd/           # [PO] 360° completeness grid audit
│       ├── arch-gate/           # [PO/ENG] Upstream technology decision gate
│       ├── prd2backlog/         # [PO] Backlog generator
│       ├── specify/             # [ENG] Specification drafter
│       ├── review-spec/         # [ENG] Adversarial spec reviewer
│       ├── tdd-build/           # [ENG] Test-driven core/shell builder
│       ├── e2e-test/            # [ENG] Playwright E2E validator
│       └── ship/                # [ENG] Main branch rule-traceability merger
├── docs/                        # Specifications, contracts, and state
│   ├── PRD.md                   # Validated PRD (100% 360° completeness)
│   ├── architecture.md          # Infrastructure contracts sealed by arch-gate
│   └── specs/                   # Detailed specifications per issue
├── scripts/
│   ├── init-project.sh          # Automated project initializer script
│   └── hooks/                   # Zero-token hook scripts
│       ├── pre-commit-lint.sh   # Syntactic and styling checker
│       ├── pre-commit-test.sh   # Run tests + apply isomorphic log trimming
│       ├── pre-commit-coverage.sh # Validate >=90% test coverage floor
│       ├── pre-commit-security.sh # Run Trivy security checks + secrets search
│       ├── on-interrupt.sh      # Environment credential validator
│       ├── on-circuit-breaker.sh# Coordinated human takeover state log
│       └── on-architecture-drift.sh # Architectural contract defender
└── src/                         # System Source Code
    ├── core/                    # Functional Core (Pure deterministic logic, 0 IO)
    └── shell/                   # Imperative Shell (IO, DB, HTTP APIs)
```

---

## **3. Getting Started (Installation & Initialization)**

### **Prerequisites**
- Git installed and initialized.
- Standard developer runtime (Python 3.8+ or Node.js 16+).
- Recommended global packages (optional, but automatically utilized by hooks if present):
  - Python: `ruff`, `pylint`, `pytest`, `coverage`
  - JS: `eslint`, `jest`
  - Container / Security: `trivy`, `shellcheck`, `jq`

### **Initialization Steps**

1. Clone or import this suite into your workspace:
   ```bash
   git clone <repository_url> agentic-suite
   cd agentic-suite
   ```

2. Bootstap your existing or new project repository using the high-rigor initializer script:
   ```bash
   ./scripts/init-project.sh
   ```

   *The script will programmatically:*
   - Verify/initialize your Git repository.
   - Construct the standard directory tree (Skills, Rules, Workflows, Docs, Src).
   - Write the constitutional `AGENTS.md` and specialized Markdown rules.
   - Generate default template schemas for all **9 skills** and **2 workflows**.
   - Create and configure **7 custom bash hook scripts** under `scripts/hooks/`.
   - Register and link verification hooks locally in `.git/hooks/pre-commit` and `.agents/hooks.json`.

---

## **4. Detailed Skills and Persona Workflows**

The suite divides responsibility between two primary agent personas:

### **4.1 Product Owner Persona**
- **/interview-prd**: Leads an interactive interview with the user. In the event of an ambiguous engineering decision, the agent activates Web Search, evaluates state-of-the-art options, and renders a comparative analysis decision matrix.
- **/audit-prd**: Rigid linter auditing the **6 Scoping Pillars** (Functional Vision, Architecture, Data Strategy, Deployment, Security, and UX/Non-Functional). Prevents downstream execution if sections are missing.
- **/prd2backlog**: Decomposes the sealed PRD into a prioritized list of atomic, isolated issue files in `docs/specs/`.

### **4.2 Engineering Persona**
- **/arch-gate**: Analyzes the PRD to produce the immutable contract `docs/architecture.md`. Once accepted by the human, any modifications to this file without bypass validation will trigger the Architecture Drift Hook.
- **/specify**: Drafts exact technical specifications (inputs, outputs, database contracts) for the target issue before a single line of code is produced.
- **/review-spec**: An independent adversarial reviewer sub-agent. Rejects the draft if there is drift from `docs/architecture.md` or PRD rules.
- **/tdd-build**: Executes a strict **TDD Red-Green-Refactor** cycle using stateless sub-agents. Isolates business rules to `src/core/` and side effects to `src/shell/`. Enforces >=90% test coverage.
- **/e2e-test**: Deploys a browser agent running Playwright to simulate end-to-end user journeys against the integrated application.
- **/ship**: Automates merging to the main branch, validating trace IDs, and formatting commits to ensure full auditability.

---

## **5. Zero-Token Hook Gates (Enforcement Shell)**

Our hooks act as immediate circuit-breakers to protect repository integrity:

### **1. Pre-Commit Lint (`pre-commit-lint.sh`)**
- Scans staged files on commit.
- Runs `ruff` or `pylint` on Python files; runs `eslint` on JS/TS; runs `shellcheck` on `.sh` scripts.
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
- Unless bypass files are provided, it rejects the commit to enforce that the AI agent does not unilaterally modify technology stacks or databases during code generation.

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
