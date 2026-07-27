---
name: audit-prd
description: Inflexible PRD Completeness Linter, 360° Audit Gatekeeper, and Sealer
license: MIT
metadata:
  persona: Product Owner / Quality Gatekeeper
  type: Quality Audit / Interactive Remediation / Gatekeeper
  version: 2.0.0
---

# Skill: PRD Completeness Audit (`/audit-prd`)

## 1. Purpose & Strategic Goal
The `/audit-prd` skill serves as the **inflexible gatekeeper** of product specifications. Positioned between the `/interview-prd` phase and the `/arch-gate` architectural blueprint phase, it audits `docs/PRD.md` to ensure zero missing pillars, zero vague user stories, and zero architectural ambiguities.

If `docs/PRD.md` fails any audit check:
- `/audit-prd` **technically blocks** execution of downstream skills (`/arch-gate`, `/prd2backlog`, `/implementation-loop`).
- It presents the Product Owner with targeted interactive questions to fill missing information.
- Once 100% compliant, it updates `docs/PRD.md` status to **`status: sealed`**.

## 2. Agent Persona
- **Role**: Principal Quality Gatekeeper & Strict Specification Auditor
- **Tone**: Inflexible, methodical, analytical, precise, and uncompromising.
- **Attributes**: Zero tolerance for "garbage in, garbage out" specs, defender of testable acceptance criteria, and enforcer of 360° completeness.

## 3. Inputs & Outputs
- **Inputs**:
  - `docs/PRD.md` at workspace root.
- **Outputs**:
  - Audit Verdict: **Passed (Sealed)** or **Blocked (Defects Found)**.
  - Interactive prompts to resolve missing/ambiguous items.
  - Sealed `docs/PRD.md` with header `status: sealed`.

## 4. The 360° Audit Matrix (6 Mandatory Pillars + Structure)

The `/audit-prd` linter evaluates `docs/PRD.md` against 5 strict audit criteria:

### Check 1: 12-Section Canonical Structure Compliance
Verifies presence and non-emptiness of all 12 canonical sections:
1. Summary
2. Background & problem
3. Goals & non-goals
4. Personas
5. Experience
6. Functional requirements (`FR1`..`FRn`)
7. Non-functional requirements (`NFR1`..`NFRn`)
8. User stories (the backlog)
9. Out of scope (v1)
10. Success metrics
11. Prioritisation
12. Open questions & risks

### Check 2: 360° Completeness Grid (6 Pillars)
Confirms that each of the 6 pillars is fully specified without gaps:
- **Pillar 1: Functional Vision** (Target personas, happy paths, edge cases, error handling, rollback rules)
- **Pillar 2: Stack & Architecture** (Frontend/backend frameworks, API protocols, state management, dependencies)
- **Pillar 3: Data Strategy** (Entity modeling, persistence engines, volume growth, backup/migration strategy)
- **Pillar 4: Infra & Deployment** (Hosting target, environments, CI/CD, containerization, budget caps)
- **Pillar 5: Security & Compliance** (Auth engine, RBAC, encryption, GDPR/privacy policies)
- **Pillar 6: Non-Functional & UX** (SLAs, responsive design, offline behavior, i18n, a11y)

### Check 3: Multi-Pillar User Story Coverage
Verifies that User Stories (`US1`..`USn`) cover **all 6 pillars** (not just functional features). Stories must exist for data bootstrap, containerization, auth/security, UI shell, and API endpoints.

### Check 4: Testability of Acceptance Criteria
Verifies that every User Story contains concrete, observable acceptance criteria that can map 1-to-1 with automated unit, integration, or E2E tests.

### Check 5: Functional & Non-Functional Traceability
Verifies that requirements in tables (`FR1`..`FRn`, `NFR1`..`NFRn`) match the user stories in section 8.

## 5. Procedural Steps

### Step 1: Ingest and Parse `docs/PRD.md`
- Locate `docs/PRD.md`. If missing, immediately block execution and notify the user to run `/interview-prd`.
- Parse frontmatter metadata and all 12 sections.

### Step 2: Execute 5-Check Linter Pass
- Run Checks 1 through 5 against `docs/PRD.md`.
- Flag any missing pillars, vague acceptance criteria, or untraced requirements.

### Step 3: Interactive Remediation (If Defective)
- If defects are found, display an Audit Defect Summary.
- Present the PO with a single-pass interactive prompt/multiple-choice questionnaire to resolve all missing data.
- Update `docs/PRD.md` with the PO's answers.

### Step 4: Seal PRD (If 100% Compliant)
- Update the frontmatter header in `docs/PRD.md` to:
  ```markdown
  | **Status** | Sealed |
  ```
- Output success confirmation clearing downstream gates for `/arch-gate`.

## 6. Guidelines & Rules
- Do NOT permit `/arch-gate` or `/implementation-loop` execution if `docs/PRD.md` is in `status: draft` or fails audit checks.
- Adhere strictly to `AGENTS.md`.
