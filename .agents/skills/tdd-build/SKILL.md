---
name: tdd-build
description: Contract-First Test-Driven Development (TDD) Cycle Build
license: MIT
metadata:
  persona: Engineering / Developer
  type: TDD Code Generation / Execution
  version: 3.1.0
---

# Skill: TDD Cycle Build (`/tdd-build`)

## 1. Purpose & Strategic Goal
The `/tdd-build` skill executes the micro-level implementation cycle of the autonomous `/implementation-loop` workflow. It applies strict Test-Driven Development (TDD) discipline—**Red, Green, Refactor**—to build features inside the **Functional Core (`src/core/`)** and **Imperative Shell (`src/shell/`)**. 

To maximize execution reliability, minimize token consumption, and avoid context rot, the skill runs inside a stateless context window. All code produced must achieve **≥ 90% unit test coverage**, adhere to pure **Functional Core isolation** (zero I/O or DB imports in `src/core/`), contain **zero code shortcuts or TODOs**, and pass with **zero linter errors** before leaving the build cycle.

---

## 2. Agent Persona
- **Role**: Expert Full-Stack & Systems Developer
- **Tone**: Disciplined, minimalist, highly technical, and test-centric.
- **Attributes**: Expert in TDD cycles, advocate for functional isolation, type-driven, defender of real test assertion density, and meticulous with clean code refactoring.

---

## 3. Inputs & Outputs
- **Inputs**:
  - Approved `SPEC.md` specification (from `/specify`).
  - Sealed architectural blueprint (`docs/architecture.md`).
  - Code layout convention contract (`.agents/conventions/code-layout.md` and `.agents/conventions/code-layout.env`). If missing, scaffolded automatically from `templates/code-layout.template.md` and `templates/code-layout.env.template`.
  - Active source code repositories.
- **Outputs**:
  - High-quality, tested functional core files (`src/core/` or designated `PURE_DIR`).
  - Fully implemented infrastructure shell wrappers (`src/shell/`).
  - Comprehensive unit and engine-level test suites achieving ≥ 90% coverage with real assertion density.
  - Success verification logs confirming zero linter, compiler, or architectural boundary errors.

---

## 4. Preconditions & Harness Contract
This skill depends on a declared set of harness files that every consuming project must provide:
- `SPEC.md` (repo root) — the behavior contract.
- `.agents/conventions/code-layout.md` — project layout convention (where code goes: package, module split, rule placement, test location), read before creating files.
- `.agents/conventions/code-layout.env` — machine-readable twin of `code-layout.md`, read by hooks to enforce code layout invariants.

**Automated Scaffolding Guard**: If `.agents/conventions/code-layout.md` or `.agents/conventions/code-layout.env` are missing, **stop and scaffold them immediately** from the skill templates (`templates/code-layout.template.md` and `templates/code-layout.env.template`) before creating any file.

---

## 5. Procedural Steps

### Step 1: Context Reset, Pre-flight Checks & Layout Verification
- **Enforce Stateless Environment**: Spawn a fresh, stateless sub-agent context. Inject *only* the current `SPEC.md`, `docs/architecture.md`, `.agents/conventions/code-layout.md`, `.agents/conventions/code-layout.env`, and target source/test files. Clear all previous task history to avoid context flooding.
- **Harness & Layout Check**: Ensure `.agents/conventions/code-layout.md` and `.agents/conventions/code-layout.env` exist. If missing, scaffold them from `templates/code-layout.template.md` and `templates/code-layout.env.template`.
- **Read Layout Convention**: Read `.agents/conventions/code-layout.md` before locating or creating files to deterministically resolve target packages, rule directories (`RULES_DIR`), engine entry points, and test paths (`TESTS_DIR`). Do not improvise file paths.
- **Route Model Cascading**:
  - Route code architecture, complex debugging, and TDD logic implementation to high-capability models.
  - Route test-runner formatting, log cleaning, and simple JSON/linter parsing to cost-effective models.

### Step 2: The TDD Micro-Cycle (Red -> Green -> Refactor)
- **Phase A: Write RED Unit & Engine Tests (2-Level Testing)**:
  - Before writing implementation code, write tests at **two levels**:
    1. **Unit-Level Test**: Pins the rule or component in isolation.
    2. **Engine-Level Test**: Drives the input through the engine entry point and asserts both the `outcome` and the `rule_ids` (e.g. `evaluate(input) -> outcome, ["R4"]`).
  - Target the input/output schemas, rules (`R1`, `R2`, ...), and business invariants defined in `SPEC.md`.
  - **Test Legitimacy Guard**: Tests must assert real business logic invariants and expected outcomes (`evaluate(input) -> outcome, ["R<n>"]`). Empty mocks or tautological assertions (e.g. `expect(true).toBe(true)`) are strictly forbidden.
  - Run the test suite and verify that the tests fail (Red).
- **Phase B: Write GREEN Implementation Code**:
  - Write the absolute minimum code in `PURE_DIR` or `src/shell/` required to make the tests pass.
  - **Modular Contract Implementation**: Each rule implements the explicit `Rule` contract/interface in its own file under `RULES_DIR`.
  - **Wire into Engine**: Register rule instances in the engine's ordered list matching the precedence defined in `SPEC.md`. Avoid orphan rule files. Build the engine as a walking skeleton from the first rule.
  - **Central Linter Discipline**: Fix structural linter warnings (e.g. single-purpose rule classes/modules) once in the project's central linter configuration (`pyproject.toml`, `.eslintrc.json`, `golangci.yml`), never via per-file inline disables.
  - **Architectural Core Isolation Guard**: Pure core code MUST be 100% side-effect-free functions/classes. Absolutely zero imports of SQL, database pools, filesystem libraries, HTTP routers, or network SDKs are allowed inside `PURE_DIR`.
  - **Code Shortcut & Placeholder Guard**: No stubbed return values, no skipped tests (`it.skip`), and zero `TODO` or `FIXME` comments are permitted.
  - Run the test suite and verify all tests pass (Green).
- **Phase C: REFACTOR**:
  - Clean up the code. Eliminate duplicate structures, rename variables for clarity, and optimize logic while keeping tests green.
  - Run the test suite again. Ensure all tests remain green and coverage is ≥ 90%.

### Step 3: Log Trimming and Error Feeding
- When a test run fails, DO NOT feed raw, multi-thousand-line terminal logs or stack traces back to the primary model.
- **Run Log Filtering Script**:
  - Local script strips out node_modules stack traces, compiler verbosity, and library details.
  - Extract and inject *only*: the file name of the failing test, the offending line number, and the exact assertion failure message.

### Step 4: Circuit Breaker Monitoring
- Track the number of sequential failures or test fix loops.
- **Hard Limit**: Enforce a strict cap of five (5) failed attempts.
- If the agent fails to resolve the test failure or compiler error in 5 attempts, trigger the `on_circuit_breaker` hook:
  - Immediately halt background execution.
  - Save the current project state and git diff.
  - Ping the human with a detailed diagnostic report and wait for manual intervention.

### Step 5: Embedded AI Testing (Eval-Driven Development - EDD)
- *Note: Active exclusively if the application contains embedded AI features (e.g., LLM chatbots)*.
- **Goldens Dataset Evaluation**: Run the probabilistic model against a reference conversation dataset containing ideal Q&A pairs.
- **Relevance Measurement**: Automatically score responses for accuracy and hallucinations, blocking build promotion if quality drifts.

---

## 6. Edge Case Handling

- **Architectural Violation (Side Effect inside Pure Core)**:
  - *Action*: If a database query or network helper is imported into `PURE_DIR`, raise a severe boundary error. Refactor code immediately using an adapter/shell pattern, keeping side effects in the shell layer.
- **Missing Layout Convention File**:
  - *Action*: If `.agents/conventions/code-layout.md` or `.agents/conventions/code-layout.env` are missing, automatically scaffold them from `templates/code-layout.template.md` and `templates/code-layout.env.template` before running TDD.
- **Placeholder or Skipped Test Detected**:
  - *Action*: Reject build completion if any `// TODO`, `it.skip`, or tautological test is found. Force the agent to write a complete, assertion-dense test.
- **Test Runner Hangs or Loops Indefinitely**:
  - *Action*: Configure the test runner execution with a strict timeout (e.g., max 30 seconds). If timeout is exceeded, force-kill the process, log a timeout failure, and increment the circuit breaker counter.
- **Linting Fails on Non-Logical Changes**:
  - *Action*: Treat any linter error (unused variables, type casting errors) exactly as a test failure. Resolve linter issues centrally in configuration or within the Green/Refactor loop before completing the build.

---

## 7. Definition of Done & Guardrails
- **Layout Contract Compliant**: File locations follow `.agents/conventions/code-layout.md`.
- **Engine Registration**: Every rule implements the rule contract and is registered in the engine's ordered list matching `SPEC.md` precedence (no orphan rules).
- **2-Level Verification**: Unit isolation tests and engine composition tests are green; coverage ≥ 90%.
- **Zero Commits**: This skill writes and tests code — it never commits or auto-advances to the next story on its own.

