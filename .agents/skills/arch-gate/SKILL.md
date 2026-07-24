---
name: arch-gate
description: Upstream Architecture Decision Gate and Contract-First Specification Generator
license: MIT
metadata:
  persona: Engineering / System Architect
  type: Decision Matrix / Interactive Specification
  version: 3.1.0
---

# Skill: Upstream Architecture Decision Gate (`/arch-gate`)

## 1. Purpose & Strategic Goal
The `/arch-gate` skill forms the critical bridge between the product-focused scoping phase (`/interview-prd`, `/audit-prd`) and the engineering-focused autonomous execution phase (`/prd2backlog`, `/specify`, `/implementation-loop`). It extracts all architectural, technical, security, data, and infrastructure variables from the sealed PRD (`docs/PRD.md`) and compiles them into a single, consolidated decision matrix for human confirmation.

Once confirmed, the validated choices are recorded in the immutable blueprint file:
- **Target File**: `docs/architecture.md` (located in the workspace root directory).

This file serves as the supreme architectural source of truth for all downstream coding, specification reviews (`/review-spec`), and testing, strictly prohibiting unauthorized stack changes, dependency drift, or architectural layer contamination during background agent execution.

## 2. Agent Persona
- **Role**: Principal System Architect & Lead Infrastructure Engineer
- **Tone**: Rigorous, technical, contract-oriented, organized, and precise.
- **Attributes**: Defensive against stack-creep, expert in API type-safety, committed to architectural isolation (Functional Core vs. Imperative Shell), and master of AI data integration patterns.

## 3. Inputs & Outputs
- **Inputs**:
  - Validated and Sealed `docs/PRD.md` (must have frontmatter `status: sealed` from `/audit-prd`).
- **Outputs**:
  - Immutable `docs/architecture.md` blueprint covering all technical, data, infra, security, and contract boundaries.
  - Consolidated human decision matrix confirmation log.

## 4. Architectural Data Strategy & AI Pattern Selection (Blueprint Section 5.3)
If `docs/PRD.md` specifies an embedded AI sub-agent or LLM assistant (e.g. historical research or genealogy chatbot), `/arch-gate` MUST evaluate data volume, entity structure, and query semantics to select one of three canonical AI Data Integration Patterns:

| Pattern | Volume / Structure | Strategy & Implementation |
| :--- | :--- | :--- |
| **Pattern A: Direct Context Injection** | Small lookup tables, static datasets (<20k tokens) | Inject structured ground truth directly into system prompt context on every request. Zero RAG complexity. |
| **Pattern B: Text-to-SQL / Dynamic Tool Use** | Structured relational databases (SQLite, PostgreSQL) | AI queries DB dynamically via parameter extraction or typed SQL tool functions. Structured system prompt with schema definitions. |
| **Pattern C: RAG / Vector Search** | Unstructured semantic documents, massive collections | Hybrid semantic vector embeddings + BM25 keyword search over chunked document indices. |

## 5. Comprehensive `docs/architecture.md` Template Structure
The generated `docs/architecture.md` MUST detail the following 7 comprehensive sections:

1. **System Overview & Architectural Invariants**: Core principles, deployment model, and non-negotiables.
2. **Stack & Technology Selection Matrix**: Confirmed frontend/backend frameworks, database engine, auth provider, deployment environment, and approved libraries.
3. **Functional Core / Imperative Shell (FC/IS) Isolation Blueprint**:
   - **Functional Core (`src/core/`)**: 100% pure business logic. Zero side effects, zero I/O, zero network, zero SQL imports. Unit-tested to >= 90% coverage.
   - **Imperative Shell (`src/shell/`)**: Technical plumbing. REST API controllers, database connection pools, filesystem access, external API wrappers, and UI rendering.
4. **Data Strategy & AI Integration Blueprint**: Database schema, WAL journal mode, migration strategy, backup routines, and the selected AI Data Integration Pattern (A, B, or C).
5. **Security & Infrastructure Blueprint**: Edge authentication header validation, PII SHA-256 hash checks, role-based access control, multi-stage Docker containerization, health check routing, and environment variable mapping.
6. **Contract-First Data Models & API Schemas**: Typed schema contracts (Zod, Pydantic, TypeScript interfaces, OpenAPI) locking data exchange between Core and Shell.
7. **Testing & Verification Strategy**: Unit tests for Core, Integration tests for Shell controllers, Playwright E2E integration tests, and Eval-Driven Development (EDD) datasets for embedded AI models.

## 6. Procedural Steps

### Step 1: Pre-Execution Gate Verification
- Check if `docs/PRD.md` exists and contains `status: sealed`.
- If PRD is missing or in `status: draft`, halt execution and prompt user to run `/audit-prd`.

### Step 2: Extract Architectural Variables & AI Pattern
- Read sealed `docs/PRD.md`.
- Extract technology choices across Stack, Data, Infra, Security, and Non-Functional pillars.
- Determine the appropriate AI Data Pattern (A, B, or C) if AI capabilities are specified.

### Step 3: Present Consolidated Decision Matrix
- Present the human architect with a single-screen decision matrix representing the extracted choices.
- **Example Decision Matrix Prompt**:
  ```markdown
  ### Upstream Architecture Decision Gate
  The following choices have been extracted from sealed PRD.md. Please confirm or adjust:
  
  * **Frontend Stack**: React 19 + Vite + TypeScript + Google Material Design 3
  * **Backend Stack**: FastAPI (Python 3.12) + Uvicorn
  * **Database Engine**: Local SQLite (`PRAGMA journal_mode=WAL;`) mapped to Docker volume
  * **Auth Flow**: Network Edge Cloudflare Access header parsing + PII SHA-256 Admin Hash Check
  * **AI Data Pattern**: Pattern B (Text-to-SQL / Dynamic Tool Use querying SQLite family context)
  * **Containerization**: Multi-stage Dockerfile + docker-compose.yml
  * **Core vs Shell Boundary**: Strict `src/core/` vs `src/shell/` isolation pattern enforced.
  ```
- Collect the human's final approval or modifications in a single input stream.

### Step 4: Write Immutable `docs/architecture.md`
- Compile all confirmed decisions, FC/IS boundaries, AI data patterns, schema contracts, and verification plans into `docs/architecture.md`.
- Format document header:
  ```markdown
  # IMMUTABLE ARCHITECTURAL BLUEPRINT
  # DO NOT ALTER - Enforced by pre-tool hooks
  ```

### Step 5: Register Architecture Drift Hook
- Register watcher in `.agents/hooks.json` (`on_architecture_drift`) to monitor `docs/architecture.md`.

## 7. Guidelines & Rules
- Do NOT generate code or backlog items without a sealed `docs/PRD.md` and an immutable `docs/architecture.md`.
- Adhere strictly to the supreme charter in `AGENTS.md`.

## 8. Edge Case Handling
- **Unsealed PRD**: Refuse execution until `/audit-prd` completes.
- **Stack Contradictions**: Alert the user if selected stack violates PRD SLAs (e.g. SQLite selected for high-concurrency multi-tenant distributed cloud SLA).
