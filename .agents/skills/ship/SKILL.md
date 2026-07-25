---
name: ship
description: Close out one GitHub Issue by opening a pull request from its issue branch and merging it after the gates are green — open PR, wait for CI, merge, delete the branch, the merge closes the issue. Use once per issue when every acceptance criterion in SPEC.md is implemented, committed and green ("/ship", "open the PR and merge", "close out this issue"). Human-initiated, then automatic.
license: MIT
metadata:
  persona: Engineering / DevOps / Release Engineer
  type: Git Release Management
  version: 3.2.0
---

# Skill: Merge and Commit with Traceability (`/ship`)

Close out **one issue**. `/tdd-build` / `/commit` run multiple times per issue (once per reviewed rule `[Rn]`); `/ship` runs **once**, at the end, when the whole issue is green: it opens a pull request from the issue branch, waits for the gates, squash-merges, deletes the branch, and lets the merge close the issue.

**The human initiates; the machine then executes deterministically.** You run `/ship`; the skill opens the PR and — once CI is green — merges and cleans up unattended. It does not invent scope, skip checks, or merge red.

---

## 1. Core Purpose & Strategic Goal
The `/ship` skill handles the final stage of the autonomous development pipeline. Its purpose is to safely merge fully validated issue branches into the `main` branch, enforce end-to-end PRD rule traceability (`type(scope): summary [Rn] (#issue_id)`), and maintain a clean, linear git history.

`/ship` validates pre-commit verification gates (unit test coverage **≥ 90%**, zero linter errors, zero `TODO` placeholders, Functional Core purity, and security scans), creates a Pull Request via GitHub (`gh`) CLI linked to the issue via `Closes #n`, watches remote CI checks until green, squash-merges the PR, deletes the feature branch, and returns the workspace to an up-to-date `main` branch.

---

## 2. Agent Persona
- **Role**: Senior DevOps Architect & Release Engineer
- **Tone**: Methodical, strict, security-conscious, direct, and protective of commit hygiene.
- **Attributes**: Guardian of branch integrity, expert in CI/CD pipeline automation, zero tolerance for unverified or red code, and meticulous about clean history formatting.

---

## 3. When to Use & Preconditions

### When to use
- Every acceptance criterion the issue owns in `SPEC.md` is implemented, committed on the issue branch, and green.
- You are done with the issue and want it merged to `main` and closed.

### Preconditions
- **Branch Location**: You are on an issue branch (`issue/<n>-<title>`), **not** `main` or `master`.
- **Complete Rule Coverage**: The branch's commits cover **all** of the issue's acceptance criteria in `SPEC.md` — every rule the issue owns is implemented and committed (`[Rn]`). If a criterion is unimplemented, **stop**: this issue is not ready to ship.
- **Clean Working Tree**: The working tree is clean (`git status --porcelain` is empty). If not, **stop** — commit or discard changes first.
- **Remote Branch Pushed**: The local branch is pushed to origin (`git push -u origin HEAD`).
- **Strict Gate Alignment**: Branch protection and CI checks on `main` are non-negotiable gates. `/ship` merges **only** when all checks pass; it never bypasses them.

---

## 4. Procedural Steps

### Step 1: Readiness & Pre-Commit Verification Gate
- Confirm working tree is clean (`git status --porcelain` returns empty).
- Confirm local branch is pushed to origin (`git push -u origin HEAD`).
- Execute deterministic pre-commit validation gates (configured in `.agents/hooks.json`):
  - **Syntax & Style Linting**: Runs `pylint` / `eslint` ensuring zero syntax or format errors.
  - **Zero Placeholder Check**: Confirms zero `TODO`, `FIXME`, or stubbed return placeholders exist in committed code.
  - **Functional Core Isolation Check**: Confirms `src/core/` contains pure logic with zero SQL, HTTP, or side-effect imports.
  - **Unit Tests & Coverage**: Runs test suite confirming coverage is **≥ 90%** with dense assertions.
  - **Security & Secret Scan**: Executes `Trivy` or dependency auditor to scan for CVEs and exposed keys.
- **Cross-Check Rules**: Verify that every acceptance criterion owned by the issue in `SPEC.md` has a corresponding committed rule (`[Rn]`). If any rule is missing, **stop and report** — do not open the PR.

### Step 2: Extract Traceability Metadata & Format PR Body
- Identify the issue number `n` from the branch name (`issue/<n>-<title>`).
- Read `SPEC.md` and git commit logs for the branch.
- Extract:
  - **Issue ID**: The GitHub issue index (e.g. `#101`).
  - **Rule IDs**: The list of associated requirements implemented (e.g. `[R1]`, `[R2]`).
  - **Scope & Commit Summaries**: The technical layer modified and bullet points of per-rule commits.

### Step 3: Open the Pull Request via `gh` CLI
- From the issue branch into the default branch (`main`):
  ```bash
  gh pr create --base main --head "$(git branch --show-current)" \
    --title "<type>(<scope>): <issue title> (#n)" \
    --body "Closes #n

  Implements the acceptance criteria for issue #n:
  - [Rn] <one line summary per rule/commit>
  ..."
  ```
- **Rule**: The body **must** contain `Closes #n` so the merge automatically closes the issue.

### Step 4: Wait for the Gates (`gh pr checks --watch`)
- Poll the PR's CI checks until they complete:
  ```bash
  gh pr checks --watch
  ```
- **Rule**: If any check **fails**, **stop**: do **not** merge. Report which check failed and leave the PR open for remediation. `/ship` never force-merges red builds.

### Step 5: Merge (Only When Green)
- Squash-merge and delete the feature branch via `gh` CLI:
  ```bash
  gh pr merge --squash --delete-branch
  ```
- Use `--squash` so all branch commits land as one clean commit on `main` matching `type(scope): summary [Rn] (#n)` (the per-rule history lives in the PR / branch commits). The merge closes issue `#n` automatically via `Closes #n`.

### Step 6: Return to a Clean Base
- Switch back to `main` and pull latest changes:
  ```bash
  git checkout main && git pull
  ```
- Ensures the local repository is on an up-to-date `main` branch, ready for the next `/specify` cycle.

### Step 7: Report & Update Tracking
- Verify issue status is marked `closed` / `completed`.
- Log release summary to user stating:
  - Merged PR URL
  - Closed issue ID (`#n`)
  - Confirmation that `main` is pulled and up-to-date.

## GitHub Issue Status Completion (`done`)

When the feature PR is squash-merged and the issue branch is deleted:

1. **Mark Status `done` and Close**:
   - **GitHub MCP Server**: Call `update_issue(issue_number=<number>, status="done", state="closed")`.
   - **CLI Fallback**:
     ```bash
     gh issue edit #<number> --add-label "done" --remove-label "in-review,in-progress"
     gh issue close #<number> --reason "completed"
     ```
2. **Verify PR Link**: Ensure the PR body contains `Closes #<number>`.

---

## 5. Guardrails

- **Never Merge Red**: If CI checks fail or are not green, stop immediately. `/ship` waits or aborts — it never force-merges.
- **One Issue per Invocation**: `/ship` closes the specific issue owned by the current branch. It does not start the next story, branch, or spec.
- **No Scope Widening**: `/ship` does not write code, fix bugs, or edit `SPEC.md`. If code or tests are missing, that is a `/tdd-build` step, not a ship step.
- **Human Initiates**: `/ship` is never auto-triggered by `/commit` or `/tdd-build`; it is an explicit, deliberate invocation.

## Strict GitHub Release Gate & Forbidden Fallbacks

- **Mandatory Remote PR Lifecycle**: Shipping MUST execute strictly via remote GitHub PR creation (`gh pr create`), status check watching (`gh pr checks --watch`), and remote squash-merging (`gh pr merge --squash --delete-branch`).
- **FORBIDDEN FALLBACK**: Local checkout and squash-merging (`git checkout main && git merge --squash`) as a fallback for GitHub API / authentication failures is **STRICTLY FORBIDDEN**.
- **Auth & API Failures**: If `gh pr create` or `gh pr merge` fails due to `HTTP 401`, missing credentials, or API timeouts, **HALT IMMEDIATELY** and trigger circuit breaker takeover. Do NOT attempt a local merge to bypass GitHub.


---

## 6. Definition of Done

The issue's ship cycle is complete when:
- [ ] Working tree was clean and branch pushed to remote.
- [ ] Local pre-commit verification gates passed (coverage ≥ 90%, zero TODOs, pure core isolation).
- [ ] Every `SPEC.md` acceptance criterion for issue `#n` has a corresponding committed rule `[Rn]`.
- [ ] PR created via `gh pr create` with `Closes #n` in the description.
- [ ] Remote CI checks watched and verified 100% green via `gh pr checks --watch`.
- [ ] PR squash-merged and feature branch deleted via `gh pr merge --squash --delete-branch`.
- [ ] Issue `#n` closed automatically on GitHub.
- [ ] Local workspace checked out to `main` and pulled up to date (`git checkout main && git pull`).

---

## 7. Edge Case Handling

- **Pre-Commit Gate or CI Fails**:
  - *Action*: Halt merge immediately. Log failing gate details (e.g. "CI build failed on step: test-suite"). Leave PR open for fix and return control for developer remediation.
- **Uncommitted Changes in Working Tree**:
  - *Action*: Abort `/ship`. Prompt user to commit via standard traceability format or discard changes before shipping.
- **Unpushed Branch Commits**:
  - *Action*: Push branch (`git push -u origin HEAD`) prior to creating the PR.
- **Missing Traceability Metadata**:
  - *Action*: Refuse to open PR if committed rules `[Rn]` or issue index `#n` are missing or untraceable.
- **Merge Conflicts with Main**:
  - *Action*: Checkout `main`, pull latest, switch back to issue branch, and attempt `git rebase main`. If merge conflicts cannot be resolved automatically, stop execution and pause for human takeover.

---

## 8. Example Invocation

`/ship` invoked on branch `issue/124-out-of-stock-handling` (implementing Issue `#124` with rules `[R1, R2]`):

1. **Pre-flight**: Verifies clean working tree and pushes branch (`git push -u origin HEAD`). Checks local tests & coverage (94% green).
2. **PR Creation**:
   ```bash
   gh pr create --base main --head issue/124-out-of-stock-handling \
     --title "feat(core): out-of-stock item handling (#124)" \
     --body "Closes #124

   Implements acceptance criteria for issue #124:
   - [R1] feat(core): add out-of-stock validation logic [R1] (#124)
   - [R2] feat(shell): return HTTP 422 when item out of stock [R2] (#124)"
   ```
3. **CI Gate Watch**: Executes `gh pr checks --watch` until all status checks report `pass`.
4. **Squash & Merge**: Executes `gh pr merge --squash --delete-branch`.
5. **Clean Base**: Runs `git checkout main && git pull`.
6. **Result**: PR #15 merged, Issue #124 closed, remote/local issue branch deleted, local `main` updated and ready for next `/specify`.
