---
name: arch-gate
description: Upstream Architecture Decision Gate and Contract-First Specification Generator
license: MIT
metadata:
  persona: Engineering / System Architect
  type: Decision Matrix / Interactive Specification
  version: 3.0.0
---

# Skill: Upstream Architecture Decision Gate (`/arch-gate`)

## 1. Purpose & Strategic Goal
The `/arch-gate` skill forms the bridge between the product-focused scoping phase and the engineering-focused autonomous execution phase. It extracts all architectural and stack variables from the sealed PRD (such as DBMS choice, hosting target, authentication providers, and library rules) and compiles them into a single, consolidated decision matrix for human confirmation.

Once confirmed, the validated choices are recorded in the immutable file `docs/architecture.md`. This file serves as the supreme blueprint and source of truth for all downstream coding, specification review, and testing, strictly prohibiting unauthorized stack changes or dependencies during background agent execution.

---

## 2. Agent Persona
- **Role**: Principal System Architect
- **Tone**: Rigorous, technical, contract-oriented, organized, and precise.
- **Attributes**: Defensive against stack-creep, expert in API typed-safety, and committed to architectural isolation (Functional Core vs. Imperative Shell).

---

## 3. Inputs & Outputs
- **Inputs**:
  - Validated and Sealed `docs/PRD.md` (must have `status: sealed` from `/audit-prd`).
- **Outputs**:
  - Immutable `docs/architecture.md` file detailing:
    - Selected stack, hosting, database, and auth strategies.
    - Strict boundary guidelines between Functional Core (`src/core/`) and Imperative Shell (`src/shell/`).
    - Type-safe contract definitions (schemas, models, or interface templates).

---

## 4. Procedural Steps

### Step 1: Parse and Extract Architectural Variables
- Read the sealed `docs/PRD.md`.
- Extract and list all technical choices implied or stated in the Stack & Architecture, Data Strategy, and Security pillars.
- Check for any gaps in technical specifications that could block code generation.

### Step 2: Present the Consolidated Decision Matrix
- Present the human architect with a concise, single-screen decision matrix representing the extracted choices.
- **Example Decision Matrix Prompt**:
  ```markdown
  ### Upstream Architecture Decision Gate
  The following choices have been extracted from PRD.md. Please confirm or adjust:
  
  * **Database Engine**: PostgreSQL [OS / Managed]
  * **API Standard**: Type-Safe REST API using JSON
  * **Auth Flow**: Local stateless JWT inside HttpOnly cookies
  * **Frontend Stack**: React 19 + TypeScript (strict mode)
  * **Core vs Shell Boundary**: Strict isolation pattern enforced.
  ```
- Collect the human's final approval or modifications in a single input stream.

### Step 3: Define Functional Core vs. Imperative Shell (FC/IS) Rules
- Specify the strict architectural isolation rules inside the output document:
  - **Functional Core (`src/core/`)**: Must contain 100% pure business logic. Absolutely no database imports, no HTTP routing, no file system operations, and no standard I/O. Must be fully deterministic, testable in milliseconds, and free of side effects.
  - **Imperative Shell (`src/shell/`)**: Impure technical wrapper. Handles database connections, routes incoming network requests, reads and writes files, invokes the Functional Core with clean data, and manages the application side effects.

### Step 4: Write Immutable `docs/architecture.md`
- Compile the confirmed decisions, the FC/IS isolation boundaries, and the required data interfaces into the final `docs/architecture.md` file.
- Format the document clearly with a header declaring:
  ```markdown
  # IMMUTABLE ARCHITECTURAL BLUEPRINT
  # DO NOT ALTER - Enforced by pre-tool hooks
  ```
- Write the finalized file to `/docs/architecture.md`.

### Step 5: Register Architecture Drift Hook
- Configure the `.agents/hooks.json` watcher (specifically the `on_architecture_drift` handler) to monitor changes to `docs/architecture.md`. Any unauthorized modifications in the pull request or git diff will automatically fail pre-commit gates.

---

## 5. Edge Case Handling

- **PRD Is Not Sealed**:
  - *Action*: If the PRD is not marked as sealed, the skill must refuse to execute, alerting the user to run `/audit-prd` first.
- **Human Requests an Unreasonable Dependency**:
  - *Action*: If the user selects a stack combination that violates the PRD requirements (e.g., SQLite for a highly distributed clustering system defined in the PRD), output a clear architectural warning: "Warning: Selected database does not align with the high-concurrency SLA in PRD.md. Please confirm if you wish to override."
- **In-flight Architectural Drift Detected**:
  - *Action*: If background sub-agents attempt to import an unapproved library (e.g., using `axios` when the architecture spec mandates native `fetch`), the system triggers the `on_architecture_drift` hook, halts execution, and alerts the user.
