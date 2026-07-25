---
name: specify
description: Pull a user story from GitHub via the GitHub MCP server, extract its acceptance criteria, translate them into SPEC.md updates and test cases, validate automatically via /review-spec, and auto-land on the issue branch for autonomous execution. Use when starting work from an issue ("/specify #124", "pull the story", "what does this ticket need").
license: MIT
metadata:
  persona: Engineering / Tech Lead
  type: Autonomous Contract Drafting / Behavioral Specification
  version: 4.0.0
---

# Skill: Detailed Behavioral Specification Drafting (`/specify`)

Bring intent **in** from GitHub and turn it into the artifacts engineering actually works from. GitHub is intake; `SPEC.md` is the contract the agent obeys. This skill runs **fully autonomously inside the development loop**, using the adversarial `/review-spec` sub-agent to validate specifications without stopping for human-in-the-loop chat prompts.

## When to use
- Starting an autonomous execution cycle or a task from a GitHub Issue inside `/implementation-loop`.

## Inputs — and ONLY these (keep the context tight)
`/specify` produces one file, `SPEC.md`. To do that it needs exactly three inputs:
1. the **GitHub Issue** (via the `github` MCP) — the intake;
2. **`templates/SPEC.template.md`** (this skill's own template) — the required shape;
3. the **current `SPEC.md`**, *only if it already exists* — to edit in place and assign the next rule id.

**Do not read the rest of the repository to "understand" it.** Reading unrelated files wastes tokens and risks importing scope that is not in the Issue. In particular do **not** open:
- `docs/PRD.md` — the Product Owner's artifact; your intake is the **Issue**, not the PRD;
- `.agents/conventions/code-layout.*`, `pyproject.toml`, `src/`, `AGENTS.md` — these are about *where code goes* and are `/tdd-build`'s concern, irrelevant to a behavioral spec;
- any filled-in **sample/example** spec — **derive the spec from the Issue**; never copy an example.

If you catch yourself listing or reading files beyond the three inputs above, stop — you have what you need.

**Structure is mandatory, content is derived.** Conform to `SPEC.template.md`'s sections exactly (Overview, Domain model, Global constraints, Rules, Precedence order, Glossary) — this fixed shape is what makes specs reproducible and is **enforced by linter gates** (the gate denies a `SPEC.md` that is missing a canonical section). Every word of *content* must come from the Issue, not from a template placeholder or an example.

## Pre-Flight Authentication & Issue Verification

Before drafting `SPEC.md`, you MUST verify GitHub issue accessibility:

- Execute `gh issue view #<number>` or query via the `github` MCP server.
- **HTTP 401 / Auth Errors**: If `gh` returns an authentication error or `HTTP 401: Bad credentials`, **HALT IMMEDIATELY**. Do NOT fall back to local-only drafting or default issue numbers. Inform the user to run `gh auth login`.
- **Missing Issue**: If the issue does not exist on GitHub, **HALT IMMEDIATELY**. Report that the story must be seeded via `/prd2backlog` first.


## Tools & Sub-Agents
- **GitHub MCP server** (`github`) — used to fetch the issue and update its state/labels.
- **`/review-spec` Sub-Agent** — adversarial quality gatekeeper that automatically validates drafted `SPEC.md` updates against `docs/PRD.md` and `docs/architecture.md`.

## Spec structure
`SPEC.md` follows the canonical format in `templates/SPEC.template.md`, **resolved relative to this skill's own directory** (the folder containing this `SKILL.md`). The template defines: an overview, a domain model, global constraints, a list of **rules** with stable sequential IDs (`R1`, `R2`, …), a precedence order, and a glossary. Rule IDs are never reused or renumbered. Read the template before editing so your changes conform to it.

## Procedure
1. **Fetch** the story by number (e.g. `#124`) via the `github` MCP server.
2. **Evaluate quality**: The story must have (a) an explicit acceptance-criteria section, and (b) at least one outcome stated in testable terms (a concrete input → expected result). If either is missing, or the story is otherwise unimplementable, comment on the issue requesting clarification and stop execution. Resume once the story is updated.
3. **Extract** the acceptance criteria and any constraints; restate them as a checklist in your own words.
4. **Draft the proposed `SPEC.md`**:
   - Create or update the draft artifact based on `templates/SPEC.template.md` or the current `SPEC.md`.
   - Assign each new rule the **next sequential `rule_id`** (`R1`, `R2`, …); never reuse or renumber existing IDs.
   - **Keep the spec self-sufficient.** `/tdd-build` reads only `SPEC.md`, never the issue. Update **Domain model**, **Global constraints**, **Precedence order**, and **Glossary** in the *same* edit.
   - **Stay strictly within THIS issue's criteria.** Model only what the acceptance criteria require.
5. **Map to tests**: List the test cases the criteria imply, including edge/precedence cases and the expected `outcome` and `rule_ids`.
6. **Automated Adversarial Review (`/review-spec`) — NO HITL PAUSE**:
   - Invoke the `/review-spec` sub-agent to audit the drafted `SPEC.md` against `docs/PRD.md` and `docs/architecture.md`.
   - **If Approved**: Proceed immediately to step 7.
   - **If Rejected**: Read the reviewer feedback, auto-revise `SPEC.md` (return to step 4), and re-submit to `/review-spec` (up to the 5-attempt circuit breaker limit).
7. **Auto-Land on Branch & Commit**:
   - Create and check out `issue/<number>-<short-kebab-case-title>` (e.g. `git checkout -b issue/124-contractor-review`).
   - Write the approved content directly to `SPEC.md` in the repo and commit:
     `feat(spec): add rules for issue #<number> [Rn] (#<number>)`
8. **Mark Issue In-Progress**: Via the `github` MCP server, transition the GitHub issue state to `in-progress`.
9. **Seamless Handoff**: Pass control directly to the autonomous coding loop (`/tdd-build`).

## GitHub Issue Status Lifecycle

For each user story issue `#<number>` being processed:

1. **Intake (`in-progress`)**:
   When `/specify` picks up issue `#<number>`, update its status state to `in-progress`:
   - **GitHub MCP Server**: Call `update_issue(issue_number=<number>, status="in-progress")`.
   - **CLI Fallback**: `gh issue edit #<number> --add-label "in-progress" --remove-label "ready,backlog"`

2. **Handoff to Build/Review (`in-review`)**:
   When `SPEC.md` passes review and hands off to `/tdd-build`, update status state to `in-review`:
   - **GitHub MCP Server**: Call `update_issue(issue_number=<number>, status="in-review")`.
   - **CLI Fallback**: `gh issue edit #<number> --add-label "in-review" --remove-label "in-progress"`


## Guardrails
- **100% Autonomous**: Executes without pausing for human chat confirmation. Quality is enforced by `/review-spec`.
- The story is **intake only**. If the story and `SPEC.md` disagree, surface the conflict on the issue; `SPEC.md` decides.
- **Never widen scope beyond the criteria.** Add no field, `outcome`, rule, or invariant that THIS issue's acceptance criteria do not require.
- Circuit breaker hard limit: max 5 spec revision attempts if rejected by `/review-spec`.

## Verification
Before exiting this skill, you MUST verify:
- [ ] You fetched the issue using the `github` MCP server.
- [ ] The story passed the quality check (explicit criteria + testable outcome).
- [ ] `SPEC.md` conforms to `templates/SPEC.template.md`, with new rules assigned the next sequential `rule_id`.
- [ ] The spec is **self-sufficient**: any new field, outcome, or term is reflected in the Domain model / Global constraints / Precedence order / Glossary.
- [ ] The spec passed automated adversarial audit via `/review-spec`.
- [ ] Created/checked out `issue/<number>-<title>` branch, wrote `SPEC.md` to the repo, and committed it.
- [ ] Used `github` MCP server to transition issue state to `in-progress`.
- [ ] Passed control to `/tdd-build` with zero HITL interruption.
