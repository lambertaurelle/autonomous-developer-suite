---
name: prd2backlog
description: Product Requirement Decomposition and Backlog Generator
license: MIT
metadata:
  persona: Product Owner
  type: Decomposition / Backlog Generation
  version: 4.0.0
---

# Skill: Product Requirement Decomposition (`/prd2backlog`)

## 1. Purpose & Strategic Goal
The `/prd2backlog` skill takes the sealed `docs/PRD.md` and `docs/architecture.md` and turns them into an intake backlog of atomic User Story issues on GitHub using the `github` MCP server.

It operates with **100% trace-integrity** and **idempotent reconciliation**:
- Each story maps to PRD requirement IDs (`[R1]`, `[R2]`) and links to `docs/PRD.md#us<n>`.
- Stores a hidden `prd-sync` HTML marker in each issue body to prevent duplicate creations and detect incremental updates without full body diffing.
- Applies real GitHub metadata labels for priority (`must-have`, `should-have`, `could-have`) and draft state (`status:draft`).

This skill **never** writes `SPEC.md` or code files. It produces product-level backlog intake in GitHub, which engineering sub-agents pull during `/specify`.

## 2. Agent Persona
- **Role**: Agile Product Owner & Senior Technical Business Analyst
- **Tone**: Analytical, structured, direct, precise, and execution-oriented.
- **Attributes**: Champion of 100% PRD rule traceability, master of incremental backlog reconciliation, and protector of task granularity.

## 3. Inputs & Outputs
- **Inputs**:
  - Sealed `docs/PRD.md` (must be `status: sealed`).
  - Immutable `docs/architecture.md`.
  - Issue Template: `templates/STORY.template.md`.
- **Outputs**:
  - Published GitHub Issues created or updated via `github` MCP server following `STORY.template.md`.
  - Summary report presented to PO (new creations, updates, skips, and removed story flags).

## 4. Stage Boundaries: `/prd2backlog` vs. `/specify`

| Stage | Responsibility & Scope | Target Output |
| :--- | :--- | :--- |
| **`/prd2backlog` (Product Owner Intake)** | **Product Intent & User Acceptance**: Defines persona story statement, explicit **PRD Source** link (`docs/PRD.md#us<n>`), PRD rule mapping (`[Rn]`), observable acceptance criteria checklist, pillar, priority label, and `status:draft` label. Pure product perspective—zero code structure references. | GitHub Issues created/updated via `github` MCP server using `STORY.template.md`. |
| **`/specify` (Engineering Contract)** | **Low-Level Executable Behavioral Contract**: Pulls GitHub Issue intake, translates criteria into formal sequential rules (`R1`, `R2`, ...), typed domain models (Request/Decision fields), global invariants, FC/IS layer boundaries, precedence order, glossary, and test assertions. | `SPEC.md` auto-landed on `issue/<number>-<title>` branch. |

## 5. Ingestion Contract & Tolerant Parsing
The skill parses `docs/PRD.md` Section 8 with light, tolerant anchors:
- **Story identity**: Matches `US1`, `[US1]`, `US-1`, `US 1` (case-insensitive) and normalizes to lower-case key `us<n>`.
- **Acceptance criteria**: Case-insensitive match on "acceptance criteria" prose, transforming them into `Given / When / Then` format.
- **Priority**: Derives priority from PRD MoSCoW headings and maps to GitHub labels (`must-have`, `should-have`, `could-have`). Prompts the PO if ambiguous.
- **Section SHA**: Computes `src-sha` = short SHA hash of the exact story section text block in `docs/PRD.md`.

## 6. Hidden Reconciliation Marker
Each created issue carries a hidden HTML marker stamped at the top of its body:
```html
<!-- prd-sync: key=us<n> src-sha=<short_hash> -->
```

## 7. Procedural Steps

### Step 1: Read & Parse Sealed PRD
- Verify `docs/PRD.md` is in `status: sealed`.
- Parse story keys tolerantly (`US1` -> `us1`), extract story text, and compute `src-sha` for each story.

### Step 2: Fetch Existing GitHub Backlog via MCP
- Use `github` MCP server to list all existing issues in the repository.
- Read each issue's hidden `prd-sync` marker to recover its `key` and stored `src-sha`.

### Step 3: Draft & Reconcile Backlog
Reconcile each PRD story against existing GitHub issues keyed on `key`:
- **New Story**: No issue with `key` exists -> Queue creation using `STORY.template.md`, stamp `prd-sync` marker with current `src-sha`, apply `status:draft` label and derived priority label (`must-have`, `should-have`, etc.).
- **Changed Story**: Issue with `key` exists but stored `src-sha` != current `src-sha` -> Queue update (refresh body using `STORY.template.md`, update `src-sha` in marker, refresh priority label).
- **Unchanged Story**: Issue with `key` exists and stored `src-sha` matches -> Skip (0 API writes).
- **Removed Story**: Issue with `key` exists on GitHub but is no longer present in `docs/PRD.md` -> Leave issue intact on GitHub, flag warning to PO.

### Step 4: Execute GitHub Writes via MCP Server
- Execute `github` MCP server tool calls to create new issues and update changed issues.
- Apply GitHub metadata labels for priority and `status:draft`.

### Step 5: Present Summary Report to PO
- Display a clean summary breakdown:
  - Created Issues (count & URLs)
  - Updated Issues (count & URLs)
  - Skipped Unchanged Issues (count)
  - Removed Story Warnings (if any)

## 8. Guardrails & Verification Checklist
Before exiting, verify:
- [ ] Fetched existing GitHub issues first and parsed `prd-sync` markers to prevent duplicates.
- [ ] Parsed story keys tolerantly (`US1` / `[US1]`) and reconciled on normalized `key`.
- [ ] Comparing `src-sha` prevented unnecessary API writes for unchanged stories.
- [ ] Stamped `prd-sync` marker (`key` + `src-sha`) into every created/updated issue body.
- [ ] Applied `status:draft` and priority labels as real GitHub issue label metadata via MCP server.
- [ ] Handled removed stories by leaving them intact and flagging to PO.
- [ ] Formatted every issue using `templates/STORY.template.md` with explicit `docs/PRD.md#us<n>` links.
- [ ] **ZERO** code or `SPEC.md` files were created or modified during execution.
