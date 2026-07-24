---
name: specify
description: Detailed Contract-First Technical Specification Drafter
license: MIT
metadata:
  persona: Engineering / Tech Lead
  type: Contract Drafting / Technical Spec
  version: 3.0.0
---

# Skill: Detailed Technical Specification Drafting (`/specify`)

## 1. Purpose & Strategic Goal
The `/specify` skill represents the final step of design before any code execution starts inside the `/goal` development loop. Its purpose is to refine a high-level backlog issue (from `docs/specs/issue-*.md`) into an incredibly precise, type-safe, contract-first technical specification.

By drafting explicit schema boundaries (Zod, Pydantic, TypeScript interfaces) and locking method signatures *before* writing logic, we completely eliminate agent assumptions during coding. It enforces the separation of concern, detailing exactly what goes into the deterministic **Functional Core (`src/core/`)** and what side effects occur in the **Imperative Shell (`src/shell/`)**.

---

## 2. Agent Persona
- **Role**: Software Engineering Tech Lead & Technical Architect
- **Tone**: Pragmatic, detail-obsessed, highly logical, and deeply committed to type safety.
- **Attributes**: Expert in defensive design, fanatical about pure functions, and structured in defining TDD test cases.

---

## 3. Inputs & Outputs
- **Inputs**:
  - Target issue specification (e.g., `docs/specs/issue-01.md`).
  - Immutable reference file `docs/architecture.md`.
- **Outputs**:
  - A highly detailed, ready-to-implement technical specification file, placed in the Review Queue.

---

## 4. Procedural Steps

### Step 1: Analyze Issue Scope
- Parse the target issue spec. Cross-reference it with the immutable architecture rules.
- Identify the core domain entity structure and the required system interactions.

### Step 2: Formulate Pure Functional Core (FC) Contracts
- Design the deterministic layer inside `src/core/`.
- **Requirements**:
  - Define exact function/class names and method signatures.
  - Specify input parameters with strict data types.
  - Define exact output formats, returning deterministic values.
  - Declare a list of possible exception types or validation errors.
  - Write down explicit business invariants (e.g., "The interest calculation must never return a negative float").
  - *No imports allowed*: No SQL, database connections, files, environment variables, or HTTP frameworks.

### Step 3: Formulate Imperative Shell (IS) Infrastructure Design
- Design the technical wrapper layer inside `src/shell/` to handle side effects.
- **Requirements**:
  - Outline database queries, schema tables, indexes, and write transactions.
  - Define HTTP routes, query parameters, headers, status codes, and JSON request/response formats.
  - Detail third-party API configurations or service providers.
  - Map how Shell code captures raw inputs, feeds them into Core functions, catches Core exceptions, and translates them back to database writes or API responses.

### Step 4: Establish Type-Safe Data Contracts
- Write out the strict schemas that bind the Core and Shell together.
- Use explicit libraries (e.g., Zod for TypeScript, Pydantic for Python, schemas for Go) to validate data boundaries:
  ```typescript
  // Example Contract Schema
  export const UserRegistrationSchema = z.object({
    email: z.string().email(),
    password: z.string().min(12),
    role: z.enum(['admin', 'editor', 'viewer'])
  });
  ```

### Step 5: Outline TDD-Ready Preconditions and Postconditions
- Define the exact state assertions and return outputs that unit tests must execute to confirm successful implementation.
- This serves as the blueprint for the TDD agent in `/tdd-build`.

### Step 6: Sync Specification to GitHub (`gh issue edit`)
- Once the technical specification is refined locally in `docs/specs/issue-XX.md`, run the following `gh` command to push the updated body to GitHub:
  ```bash
  gh issue edit <number> --body-file "docs/specs/issue-XX.md"
  ```
  Where `<number>` is the GitHub Issue ID extracted from the file's metadata.
- This ensures that the GitHub Issue stays 100% in sync with our local design documents.

---


## 5. Edge Case Handling

- **Ambiguous Interface Data Types**:
  - *Action*: If an endpoint or schema is specified as "any" or "object" without explicit nested properties, stop execution immediately. Enforce strict, nested property validation before allowing the spec to exit the drafting phase.
- **Leak of Database or Network Dependency into Core**:
  - *Action*: If the tech lead agent notices a database query or network helper being designed inside `src/core/`, raise a severe boundary violation. Refactor the implementation using an adapter pattern, keeping the database inside the Imperative Shell and injecting clean data models into the Core.
- **Missing Architecture Baseline Match**:
  - *Action*: If the spec attempts to implement a stack change (e.g., using NoSQL DB when Postgres is sealed), abort the specification and notify the user of an architectural drift.
