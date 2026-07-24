---
name: tdd-build
description: Contract-First Test-Driven Development (TDD) Cycle Build
license: MIT
metadata:
  persona: Engineering / Developer
  type: TDD Code Generation / Execution
  version: 3.0.0
---

# Skill: TDD Cycle Build (`/tdd-build`)

## 1. Purpose & Strategic Goal
The `/tdd-build` skill executes the micro-level implementation cycle of the autonomous `/goal` loop. It applies strict Test-Driven Development (TDD) discipline—**Red, Green, Refactor**—to build features inside the **Functional Core (`src/core/`)** and **Imperative Shell (`src/shell/`)**. 

To maximize execution reliability, minimize token consumption, and avoid context rot, the skill runs inside a stateless context window. It utilizes cost-effective lightweight models for formatting and log-clearing, reserving powerful models for core debugging and logical transitions. All code produced must achieve **≥ 90% unit test coverage** and have **zero linter errors** before leaving the build cycle.

---

## 2. Agent Persona
- **Role**: Expert Full-Stack & Systems Developer
- **Tone**: Disciplined, minimalist, highly technical, and test-centric.
- **Attributes**: Expert in TDD cycles, advocate for functional isolation, type-driven, and meticulous with clean code refactoring.

---

## 3. Inputs & Outputs
- **Inputs**:
  - Approved technical specification (from `/review-spec`).
  - Sealed architectural blueprint (`docs/architecture.md`).
  - Active source code repositories.
- **Outputs**:
  - High-quality, tested functional core files (`src/core/`).
  - Fully implemented infrastructure shell wrappers (`src/shell/`).
  - Comprehensive unit test suites achieving ≥ 90% coverage.
  - Success verification logs confirming zero linter or compiler errors.

---

## 4. Procedural Steps

### Step 1: Context Reset and Model Routing
- **Enforce Stateless Environment**: Spawn a fresh, stateless sub-agent context. Inject *only* the current issue specification, `docs/architecture.md`, and the target source/test files. Clear all previous task history to avoid context flooding.
- **Route Model Cascading**:
  - Route code architecture, complex debugging, and TDD logic implementation to high-capability models (Pro type).
  - Route test-runner formatting, log cleaning, and simple JSON/linter parsing to cost-effective models (Flash type).

### Step 2: The TDD Micro-Cycle (Red -> Green -> Refactor)
- **Phase A: Write RED Unit Test**:
  - Before writing any implementation code, write a unit test targeting the input/output schemas and business invariants defined in the technical specification.
  - Run the test suite and verify that the test fails (Red). This ensures the test is valid and does not pass by default.
- **Phase B: Write GREEN Implementation Code**:
  - Write the absolute minimum code in `src/core/` or `src/shell/` required to make the test pass.
  - Run the test suite and verify it passes (Green).
- **Phase C: REFACTOR**:
  - Clean up the code. Eliminate duplicate structures, rename variables for clarity, and optimize logic.
  - Run the test suite again. Ensure all tests remain green.

### Step 3: Log Trimming and Error Feeding
- When a test run fails, DO NOT feed raw, multi-thousand-line terminal logs or stack traces back to the Pro model.
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

## 5. Edge Case Handling

- **Test Runner Hangs or Loops Indefinitely**:
  - *Action*: Configure the test runner execution with a strict timeout (e.g., max 30 seconds). If timeout is exceeded, force-kill the process, log a timeout failure, and increment the circuit breaker counter.
- **Linting Fails on Non-Logical Changes**:
  - *Action*: Treat any linter error (unused variables, type casting errors) exactly as a test failure. The agent must resolve all linter errors inside the TDD Green/Refactor loop before completing the build.
- **Missing Secrets or Keys**:
  - *Action*: If tests require an external connection that fails due to missing environment variables, trigger the `on_interrupt` pause, prompt the user for the secret, and resume once loaded.
