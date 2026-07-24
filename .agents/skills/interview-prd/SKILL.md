# Skill: /interview-prd

## Persona
$( [[ "interview-prd" =~ ^(interview-prd|audit-prd|prd2backlog)$ ]] && echo "Product Owner" || echo "Software Engineer" )

## Objective
Standardized procedural definition for the /interview-prd skill execution.

## Inputs
- Relevant documents: docs/PRD.md, docs/architecture.md, docs/specs/
- Workspace repository files.

## Guidelines & Rules
- Adhere to the supreme charter in `AGENTS.md`.
- Enforce the rules in `.agents/rules/`.
- Check deterministic gates before and after executing changes.

## Outputs
- Structured updates modifying target project configurations or files.
- Clear, auditable traceability identifiers in output summaries.
