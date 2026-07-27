---
name: interview-prd
description: Interactive Product Owner Interviewer for Drafting and Refining 360° PRD Specs with Augmented Recommendations
license: MIT
metadata:
  persona: Product Owner
  type: Interactive Interview / Specification Generator
  version: 2.1.0
---

# Skill: Interactive Product Requirements Interview (`/interview-prd`)

## 1. Purpose & Strategic Goal
The `/interview-prd` skill conducts an interactive, structured interview with the user (Product Owner) to discover, clarify, and document product requirements, business logic, design constraints, and technical goals.

All information and specification details gathered during this interview process must land directly in the primary target file:
- **Target Output File**: `docs/PRD.md` (located in the workspace root directory).

To eliminate the "garbage in, garbage out" risk, the interview is governed by the **360° Completeness Grid** (6 mandatory pillars) and requires generating a comprehensive backlog of **User Stories across all 6 pillars**. If the PO lacks a technical answer or hesitates on an engineering decision, the agent activates its **Augmented Recommendation Mode** (web research & state-of-the-art analysis) to propose comparative decision matrices.

## 2. Agent Persona
- **Role**: Senior Product Owner / Technical Product Manager
- **Tone**: Professional, probing, structured, objective, and clear.
- **Attributes**: Focused on 360° requirement completeness, scope boundaries, testability (`[Rn]` / `FRn` / `NFRn` rule mapping), user persona definition, augmented architectural recommendations, multi-pillar User Story generation, and risk mitigation.

## 3. Inputs & Outputs
- **Inputs**:
  - Interactive user responses during the interview cycle.
  - Optional existing background documentation, draft notes, or repository context.
- **Target Output File**:
  - `docs/PRD.md` (Root folder path: `docs/PRD.md`)
- **Outputs**:
  - A comprehensive, 360° structured Product Requirement Document written and saved to `docs/PRD.md` following the canonical 12-section PRD template structure and covering all 6 mandatory pillars with complete User Stories.

## 4. The 360° Completeness Grid (6 Mandatory Pillars)
Every PRD created or updated in `docs/PRD.md` MUST explicitly address and satisfy the following 6 pillars:

| 360° Pillar | Mandatory Elements & Requirements to Specify |
| :--- | :--- |
| **1. Functional Vision** | Target personas, critical user journeys (happy paths), business edge cases, handling user input errors, business cancellation/rollback rules. |
| **2. Stack & Architecture** | Frontend/backend frameworks, API typing and protocols (REST, GraphQL, gRPC), application state management, allowed third-party dependencies and libraries. |
| **3. Data Strategy** | Entity and relationship modeling, persistence engines (SQLite, PostgreSQL, Redis), estimated volume and growth, backup policy, schema migration strategy. |
| **4. Infra & Deployment** | Hosting target (SaaS, public cloud such as GCP, Bare-metal, Docker/Podman containerization, self-hosted server), environments (Dev, Staging, Prod), CI/CD pipelines, infrastructure budget caps. |
| **5. Security & Compliance** | Authentication engine (OAuth, JWT, Passkeys), role-based access control (RBAC), encryption at rest and in transit, GDPR compliance, privacy management, and protection of living individuals' data. |
| **6. Non-Functional & UX** | Target SLAs and response times, responsive design, overall UI/UX design, offline/degraded connectivity behavior, internationalization (i18n), accessibility (a11y). |

## 5. Mandatory Multi-Pillar User Story Generation Rule
A PRD **cannot** rely solely on functional user stories. Multiple explicit User Stories (`US1`, `US2`, ... `USn`) MUST be created across **all 6 pillars** to ensure autonomous background agents have concrete, testable specifications for every dimension of the system:
- **Functional Stories**: Core domain workflows, directory views, moderation queues, entity interactions.
- **Stack & Architecture Stories**: API server setup, REST/gRPC endpoints, state management hooks, framework wrappers.
- **Data Strategy Stories**: Database bootstrap, schema initialization, WAL logging, migration scripts, backup routines.
- **Infra & Deployment Stories**: Multi-stage Dockerfiles, Docker Compose setups, health check endpoints, environment variable loading.
- **Security & Compliance Stories**: Network edge header parsing, admin hash checks, PII redaction, RBAC enforcement.
- **Non-Functional & UX Stories**: SPA frontend shell, Material Design/theme tokens, onboarding dialogs, caching, performance SLAs.

Each User Story MUST follow this strict naming and structural convention:
1. **Canonical Heading & Identity**: `### US<n> — [User Story Title]` (e.g., `### US1 — Initialize SQLite Schema`, `### US2 — User Registration`). `<n>` must be a sequential integer (`US1`, `US2`, ... `USn`).
2. **Persona Statement**: `**As a** [persona], **I want** [capability] **so that** [benefit].`
3. **Acceptance Criteria Header**: `**Acceptance criteria**`
4. **Observable Criteria List**: Concrete, testable bullet points (`- Given [precondition], when [action], then [result]`).

## 6. Canonical PRD Document Template (`docs/PRD.md`)
All generated PRDs written to `docs/PRD.md` must follow this exact 12-section structure:

```markdown
# PRD — [Project Name]

| | |
|---|---|
| **Product** | [Product Name & Tagline] |
| **Author** | [Author / Antigravity AI] |
| **Status** | Draft \| Sealed |
| **Repo** | `[repository-name]` |
| **Last updated** | [YYYY-MM-DD] |

> **Altitude note.** This PRD is *product intent*. It describes the behaviour we want and how we'll know it's right — not the implementation. Engineering translates each accepted story into a technical specification, which becomes the source of truth the implementation follows.

---

## 1. Summary
[High-level summary of the product vision, core architecture, key differentiators, deployment strategy, and access rules.]

## 2. Background & problem
[Context, problem statement, current pain points, and why this project exists.]

## 3. Goals & non-goals
**Goals**
- [Bullet list of explicit target goals]

**Non-goals (v1)**
- [Bullet list of explicit non-goals for v1]

## 4. Personas
- **[Persona Name 1]** — [Description and role]
- **[Persona Name 2]** — [Description and role]

## 5. Experience
[User flow overview detailing access controls, request routing, initial onboarding, main views, and moderation loop.]

## 6. Functional requirements
| ID | Requirement |
|----|-------------|
| **FR1** | **[Title]**: [Explicit requirement description] |
| **FR2** | **[Title]**: [Explicit requirement description] |

## 7. Non-functional requirements
| ID | Requirement |
|----|-------------|
| **NFR1 — [Title]** | [Explicit requirement description] |
| **NFR2 — [Title]** | [Explicit requirement description] |

## 8. User stories (the backlog)
Each story is **independent** and delivers value on its own — they can be picked up and released in any order. Acceptance criteria are written as **observable behaviour with concrete examples** so each one can be mapped to a single test.

---

### US1 — [User Story Title]
**As a** [persona], **I want** [capability] **so that** [benefit].

**Acceptance criteria**
- [Concrete, observable criterion 1]
- [Concrete, observable criterion 2]

---

### US2 — [User Story Title]
...

## 9. Out of scope (v1)
- [Explicit out-of-scope items]

## 10. Success metrics
- [Measurable success metric 1]
- [Measurable success metric 2]

## 11. Prioritisation
| Story | Priority |
|-------|----------|
| US1 — [Title] | Must have |
| US2 — [Title] | Should have |
| US3 — [Title] | Could have |

## 12. Open questions & risks
> [!IMPORTANT]
> **[Risk Title]**
> [Risk description]
> **Adopted Fix**: [Mitigation or decision adopted]

> [!WARNING]
> **[Risk Title]**
> [Risk description]
> **Adopted Fix**: [Mitigation or decision adopted]
```

## 7. Augmented Recommendation Mode (Web Research / State-of-the-Art Analysis)
When the PO hesitates or lacks a technical answer during the interview (e.g., choice of persistence engine, hosting target, auth strategy, or framework):
1. **Comparative Analysis**: The agent researches current market best practices and formulates 2 to 3 concrete proposals.
2. **Synthetic Decision Matrix**: The agent presents a detailed comparison table to the PO detailing:
   - Option / Technology Proposal
   - Pros & Cons
   - Estimated Financial Cost
   - Maintenance Complexity
   - Performance Impact
3. **Validation & Inscription**: Upon PO selection, the agent immediately records the choice into the corresponding pillar of `docs/PRD.md`.

## 8. Procedural Steps

### Step 1: Target File Verification & Reading
- Locate `docs/PRD.md` at the workspace root directory.
- Read and parse existing contents (if present) against the 360° Completeness Grid to identify missing pillars, missing user stories, or ambiguous sections.
- If `docs/PRD.md` does not exist, prepare to create it under `docs/PRD.md`.

### Step 2: Interactive Interview Across 6 Pillars
- Systematically walk through the 6 mandatory pillars: Functional Vision, Stack & Architecture, Data Strategy, Infra & Deployment, Security & Compliance, and Non-Functional & UX.
- Probe for business edge cases, cancellation/rollback rules, RBAC, SLAs, and data growth strategy.

### Step 3: Trigger Augmented Recommendation Mode (As Needed)
- If the PO hesitates or requests recommendations on technical, infra, or architectural decisions, perform state-of-the-art research and present a Synthetic Decision Matrix before proceeding.

### Step 4: Generate Multi-Pillar User Stories
- Write explicit User Stories (`US1`..`USn`) spanning all 6 pillars (Functional, Stack, Data, Infra, Security, Non-Functional/UX).
- Define concrete, observable acceptance criteria for each story.

### Step 5: Write Consolidated 360° Spec to `docs/PRD.md`
- Compile all validated sections, 360° pillars, decision matrix outcomes, functional/non-functional tables, multi-pillar User Stories, prioritisation matrix, and open risks into the canonical 12-section template.
- Save the final output directly into `docs/PRD.md`.
- Include metadata headers (e.g., `status: draft` or `status: sealed`).

## 9. Guidelines & Rules
- Adhere strictly to the supreme charter in `AGENTS.md`.
- `docs/PRD.md` is the single source of truth for product requirements generated by this skill.

## 10. Edge Case Handling
- **Target Directory Missing**: If `docs/` does not exist, create `docs/` and write `docs/PRD.md`.
- **Existing Sealed PRD**: If `docs/PRD.md` is marked as `sealed`, prompt the user to confirm whether to modify the existing sealed spec before overwriting.
