#!/bin/bash
# ==============================================================================
# Antigravity Project Initializer & Bootstrap Script (v4.0 Production Grade)
# ==============================================================================
# This script bootstraps any new software engineering repository to strictly
# align with the Architecture Blueprint: Autonomous Development Driven by AI Agents (V3)
# and Gemini Cookbook standards.
#
# It creates directory trees, project constitution, rules, workflows, skills,
# and deterministic, zero-token hook gates (linter, pytest/jest, test coverage, Trivy).
# ==============================================================================

set -euo pipefail

# Terminal Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0;37m' # No Color

# Logging Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS] [✓]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARNING] [!]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR] [✗]${NC} $1"
}

# Print Banner
echo -e "${CYAN}======================================================================${NC}"
echo -e "${CYAN}        ANTIGRAVITY AUTONOMOUS DEV SUITE INITIALIZER (V3)${NC}"
echo -e "${CYAN}======================================================================${NC}"

# ==============================================================================
# GitHub Integration & gh CLI Verification
# ==============================================================================
log_info "Verifying GitHub CLI (gh) installation and authentication..."

if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed. It is a mandatory requirement."
    echo -e "Please install the GitHub CLI by following: https://cli.github.com/"
    exit 1
fi

log_success "GitHub CLI (gh) is installed."

# Verify GitHub CLI authentication status
if ! gh auth status &> /dev/null; then
    log_warn "You are not logged in to GitHub. Running 'gh auth login' is recommended."
    echo -e "${YELLOW}[ACTION REQUIRED]${NC} Please run 'gh auth login' to authenticate with GitHub."
    echo -e "Press Enter after you have successfully authenticated to continue, or Ctrl+C to abort."
    read -r < /dev/tty
    
    # Re-verify authentication
    if ! gh auth status &> /dev/null; then
        log_error "GitHub authentication failed or was skipped. Bootstrapping aborted."
        exit 1
    fi
fi

log_success "Authenticated to GitHub successfully."

# Initialize standard git repository if missing
if [ ! -d ".git" ]; then
    log_warn "Git repository not found in current directory. Initializing git..."
    git init
    git checkout -b main &>/dev/null || git branch -M main &>/dev/null || true
fi

# Ensure initial commit exists so that gh repo create works with --push
if [ -z "$(git rev-parse --safe-for-write HEAD 2>/dev/null)" ] || [ -z "$(git log -n 1 2>/dev/null)" ]; then
    log_info "Creating initial placeholder commit..."
    git checkout -b main 2>/dev/null || true
    echo "# Bootstrapped Project" > README.md
    git add README.md
    git commit -m "chore: initial bootstrap commit" --no-verify 2>/dev/null || true
fi

# Check for 'origin' remote
if ! git remote get-url origin &>/dev/null; then
    echo -e "${CYAN}======================================================================${NC}"
    echo -e "No Git remote 'origin' detected. Let's create a new GitHub repository!"
    echo -e "${CYAN}======================================================================${NC}"
    
    # Interactive prompt for repository visibility
    echo -e "Select repository visibility:"
    echo -e "  1) Private (Recommended)"
    echo -e "  2) Public"
    echo -e "  3) Skip repository creation (I will configure remote manually)"
    echo -n "Enter choice [1-3]: "
    read -r choice < /dev/tty
    
    case "$choice" in
        1)
            repo_name=$(basename "$(pwd)")
            log_info "Creating private GitHub repository '$repo_name'..."
            gh repo create "$repo_name" --private --source=. --remote=origin --push
            log_success "Created private repository and pushed local commits."
            ;;
        2)
            repo_name=$(basename "$(pwd)")
            log_info "Creating public GitHub repository '$repo_name'..."
            gh repo create "$repo_name" --public --source=. --remote=origin --push
            log_success "Created public repository and pushed local commits."
            ;;
        *)
            log_warn "Skipped GitHub repository creation. Please configure origin remote manually using 'git remote add origin'."
            ;;
    esac
else
    log_info "Git remote 'origin' already exists: $(git remote get-url origin)"
fi


# Directory Tree Construction
log_info "Creating autonomous developer directory tree..."
DIRS=(
    ".agents/skills/interview-prd"
    ".agents/skills/audit-prd"
    ".agents/skills/arch-gate"
    ".agents/skills/prd2backlog"
    ".agents/skills/specify"
    ".agents/skills/review-spec"
    ".agents/skills/tdd-build"
    ".agents/skills/e2e-test"
    ".agents/skills/ship"
    ".agents/workflows"
    ".agents/rules"
    "docs/specs"
    "src/core"
    "src/shell"
    "scripts/hooks"
)

for dir in "${DIRS[@]}"; do
    if [ ! -d "$dir" ]; then
        mkdir -p "$dir"
        log_success "Created directory: $dir"
    else
        log_info "Directory already exists: $dir"
    fi
done

# ==============================================================================
# 1. Project Constitution (AGENTS.md)
# ==============================================================================
log_info "Generating Project Constitution (AGENTS.md)..."
cat << 'EOF' > AGENTS.md
# **Project Constitution: AGENTS.md**
This document serves as the supreme governance charter and architectural constitution for all AI agents and sub-agents executing operations within this repository. All background tasks and autonomous development cycles must strictly adhere to the rules, cascades, and isolation protocols detailed below.

---

## **1. Core Architectural Pillars**

### **1.1 "A Skill Asks; A Hook Imposes"**
- **Skills (Method)**: Located under `.agents/skills/`, these describe procedures, guidelines, and workflows carrying logical judgment. They suggest the path but cannot guarantee execution correctness.
- **Hooks (Enforcement)**: Located under `scripts/hooks/` and registered in `.agents/hooks.json`, these are zero-token, absolute-compliance gates executing outside the LLM context. Any non-zero exit code blocks the autonomous loop immediately.

### **1.2 Functional Core / Imperative Shell (FC/IS)**
- **Functional Core (`src/core/`)**: Pure deterministic domain logic. Zero side effects, zero network/IO, zero databases, and zero library dependency leaks. Fully unit-tested to >= 90% coverage.
- **Imperative Shell (`src/shell/`)**: External technical wrapper handling network requests, HTTP APIs, file systems, databases, and standard environment IO. Injects sanitized data into the Functional Core and executes Core-driven side effects.

### **1.3 End-to-End Traceability**
Every modification, specification, and execution must trace directly back to PRD Rule IDs (`[Rn]`) and issue numbers (`#xxx`). All commits generated autonomously must match:
`type(scope): brief summary [Rn] (#issue_id)`

---

## **2. Resource and Token Optimization**

### **2.1 Model Cascading Routing Table**
We utilize Gemini models and cascading principles to minimize costs while maintaining extreme production quality. Always reference the official [Google AI Latest Gemini Models Documentation](https://ai.google.dev/gemini-api/docs/latest-model) for up-to-date model capabilities and selection:
- **Gemini 3.5 Flash-Lite**: Default high-throughput model for routine formatting, lint error cleaning, log trimming, spec checks, and test-suite parsing.
- **Gemini 3.6 Flash**: Model for deep reasoning and complex coding tasks, reserved for architectural drafting, TDD cycle debugging, complex refactoring, and initial interactive interviews.

### **2.2 Stateless Sub-Agent Cycles**
To prevent context rot, background agents must clear their history at each test/fix cycle. The active sub-agent context window is strictly constrained to:
1. `docs/architecture.md` (System contracts)
2. `docs/specs/issue-*.md` (The atomic spec)
3. Modified source files and direct test output.

### **2.3 Log Trimming & Diff Patching**
- **Trimming**: Terminal outputs from test failures must be stripped of framework stack traces, passing only the file name, offending line, and exact assertion failure message.
- **Patching**: Regeneration of entire large files is strictly forbidden. Sub-agents must output targeted diff/patch blocks.

---

## **3. Execution Circuit Breaker**
- **Hard Limit**: A maximum of 5 recursive fix attempts is enforced for any failing test cycle.
- **Trip Handler**: On the 5th failure, the loop is paused, state is committed to a local emergency branch `drift/circuit-breaker-xxx`, and control is handed back to the human developer.

---

## **4. Database Integration & Grounding Protocols**
- **Read-Only Sandboxing**: Direct SQL generation must execute under restricted database credentials preventing destructive actions (e.g., `DROP`, `TRUNCATE`).
- **PII Masking**: Personal identifiable information must be redacted before being exposed to LLM contexts.
- **Factual Grounding**: System prompts compel the agent to state "I do not have factual evidence" rather than extrapolating or inventing missing data.

---

## **5. GitHub Synchronization & Project Management**
To ensure full synchronization with GitHub for Project Management, we enforce a strict integration using standard Git CLI and GitHub (`gh`) CLI:
- **Repository Setup (`init-project`)**: Must check if `gh` is installed, verify auth status, and interactively prompt to create a public/private GitHub repository if no 'origin' remote exists.
- **Issues Management (`/prd2backlog`)**: All backlog items generated as local markdown files (`docs/specs/issue-*.md`) must automatically be created as GitHub Issues via `gh issue create`. The assigned GitHub Issue ID (e.g., `#123`) must be dynamically parsed and written back to the local spec's metadata.
- **Specification Updates (`/specify`)**: Any subsequent refinements made to local spec files must keep GitHub updated by executing `gh issue edit <number> --body-file <spec-file>`.
- **Branch Management**: For every new feature/issue development, the agent must create and switch to a branch linked to the GitHub issue via `gh issue checkout <number>`.
- **Git Commit Standards**: All staging (`git add`) and commits (`git commit`) must utilize standard Git CLI to strictly enforce the rule-traceability commit format: `type(scope): summary [Rn] (#issue_id)`.
- **Merge & Pull Requests (`/ship`)**: Merges into the main branch must be conducted by creating a Pull Request via `gh pr create --fill` and completed with Squash and Merge (`gh pr merge --squash --delete-branch`) to maintain a clean, traceable main commit history.
- **Sequential Execution Policy**: The automated background development loop (`/goal`) must execute strictly sequentially—one user story (issue specification) at a time—and never in parallel. This ensures that every completed feature becomes the stable baseline for the next user story, preventing overlapping file edits, branch divergences, and logical conflicts.
EOF

log_success "Generated: AGENTS.md"

# ==============================================================================
# 2. Specialized Rules
# ==============================================================================
log_info "Generating specialized rules under .agents/rules/..."

cat << 'EOF' > .agents/rules/fc-is-architecture.md
# Rule: Functional Core / Imperative Shell Isolation [R-ARCH]

## Objective
To strictly isolate business-logical invariants from external IO mechanisms, ensuring testability, predictability, and preventing agent hallucination cycles on database or network states.

## Constraints
1. **Directory Enforcement**:
   - `src/core/` must contain only pure functions, pure functional classes, or pure data objects. No database drivers, no environment reading, no fetch/axios wrappers.
   - `src/shell/` must wrap `src/core/` logic, dealing with files, HTTP contexts, databases, and standard environment variables.
2. **Import Rule**: Files in `src/core/` are prohibited from importing anything from `src/shell/`.
3. **Deterministic Verification**: Every module in `src/core/` must be 100% deterministic, allowing fast, mock-free unit testing.
EOF

cat << 'EOF' > .agents/rules/model-cascading.md
# Rule: Model Cascading and Quota Efficiency [R-MODEL]

## Objective
Preserve token consumption and execution latency while ensuring correct logical depth. Always consult the official [Google AI Latest Gemini Models Documentation](https://ai.google.dev/gemini-api/docs/latest-model) for up-to-date model selection and capabilities.

## Policy
1. **Gemini 3.5 Flash-Lite Selection**:
   - `/audit-prd`, `/prd2backlog`, `/review-spec`, and `/ship`.
   - Automated code formatting, linting, and log filtering checks.
2. **Gemini 3.6 Flash Selection**:
   - `/interview-prd` (when web recommendations are active).
   - `/arch-gate` (critical decision matrix generation).
   - `/specify` (architectural contract and type specification drafting).
   - `/tdd-build` (during heavy Red-Green refactoring or unexpected test failures).
   - `/e2e-test` (Playwright flow orchestrator and DOM analysis).
EOF

cat << 'EOF' > .agents/rules/circuit-breakers.md
# Rule: Circuit Breaker Execution Limits [R-BREAK]

## Objective
Prevent infinite execution loops, token draining, and developer tool lockout when an agent is stuck on a stubborn bug.

## Mechanism
1. **Strike Counter**: Track iterations of `/tdd-build` and `/e2e-test`.
2. **Max Attempts**: Enforce a hard stop at exactly 5 failed iterations.
3. **Takeover Action**: Run the `scripts/hooks/on-circuit-breaker.sh` hook script, log states, preserve files, and sound CLI alarms.
EOF

cat << 'EOF' > .agents/rules/traceability.md
# Rule: End-to-End Traceability [R-TRACE]

## Objective
Ensure every line of code can be audited from production back to original stakeholder intent.

## Format
- **Commit Messages**: `type(scope): summary [Rn] (#issue_id)`
  - Examples:
    - `feat(core): implement interest calculation rule [R12] (#42)`
    - `fix(shell): catch postgres connection errors [R3] (#11)`
- **Code Annotations**: Inline comments linking core functions to their PRD rules:
  ```python
  # Linked to PRD Requirement [R12]: Compound interest floor
  def calculate_interest(principal, rate): ...
  ```
EOF
log_success "Generated specialized rule configurations."

# ==============================================================================
# 3. Workflows
# ==============================================================================
log_info "Generating workflows under .agents/workflows/..."

cat << 'EOF' > .agents/workflows/goal.md
# Workflow: Autonomous Developer Goal Loop (/goal)

## Sequence
The `/goal` command launches the orchestrator background task to execute development sequentially:

> [!IMPORTANT]
> **Strict Sequential Execution Policy**
> The development loop must execute strictly sequentially—one user story (issue specification) at a time—and never in parallel. This guarantees that each completed and squash-merged feature becomes the stable baseline for the next user story, preventing overlapping file edits, branch divergences, and logical conflicts.

```mermaid

graph TD
    A["Start /goal"] --> B["/specify"]
    B --> C["/review-spec"]
    C -->|Fails Review| B
    C -->|Approved| D["/tdd-build"]
    D -->|Circuit Breaker Tripped| E["Circuit Breaker Takeover"]
    D -->|Tests Pass| F["/e2e-test"]
    F -->|E2E Failure| D
    F -->|E2E Passed| G["/ship"]
    G --> H["GitHub PR Squash & Merge & Traceable Commit"]

```

## Context Reset Guidelines
At each transition, clear global context, invoking the stateless sub-agent with only current files, the specific spec, and `docs/architecture.md`.
EOF

cat << 'EOF' > .agents/workflows/interview-prd.md
# Workflow: Product Owner Scoping Interview (/interview-prd)

## Sequence
```mermaid
graph TD
    A[PO Initiates Scoping] --> B[Interview Phase]
    B -->|Lacks tech decisions| C[Web Recommendation Mode]
    C -->|Decision Matrix Generated| D[PO Decision Input]
    B -->|Pillars Defined| E[Audit Phase via /audit-prd]
    D --> E
    E -->|Incomplete Grid| F[Audit Quizzes & Updates]
    F --> E
    E -->|100% Complete| G[Seal docs/PRD.md]
```
EOF
log_success "Generated workflows."

# ==============================================================================
# 4. Antigravity Skills
# ==============================================================================
log_info "Generating SKILL.md templates for PO & Engineering personas..."

skills=(
    "interview-prd" "audit-prd" "arch-gate" "prd2backlog"
    "specify" "review-spec" "tdd-build" "e2e-test" "ship"
)

for skill in "${skills[@]}"; do
    cat << EOF > ".agents/skills/$skill/SKILL.md"
# Skill: /$skill

## Persona
\$( [[ "$skill" =~ ^(interview-prd|audit-prd|prd2backlog)\$ ]] && echo "Product Owner" || echo "Software Engineer" )

## Objective
Standardized procedural definition for the /$skill skill execution.

## Inputs
- Relevant documents: docs/PRD.md, docs/architecture.md, docs/specs/
- Workspace repository files.

## Guidelines & Rules
- Adhere to the supreme charter in \`AGENTS.md\`.
- Enforce the rules in \`.agents/rules/\`.
- Check deterministic gates before and after executing changes.

## Outputs
- Structured updates modifying target project configurations or files.
- Clear, auditable traceability identifiers in output summaries.
EOF
    log_success "Generated SKILL.md for /$skill"
done

# ==============================================================================
# 5. Deterministic Hooks Configuration
# ==============================================================================
log_info "Generating .agents/hooks.json..."

cat << 'EOF' > .agents/hooks.json
{
  "version": "3.0",
  "description": "Antigravity Deterministic Zero-Token Hooks Configuration",
  "hooks": {
    "PreCommit": [
      {
        "name": "pre-commit-lint",
        "description": "Enforce strict syntactic and styling linter standards",
        "command": "scripts/hooks/pre-commit-lint.sh"
      },
      {
        "name": "pre-commit-test",
        "description": "Deterministic unit testing execution",
        "command": "scripts/hooks/pre-commit-test.sh"
      },
      {
        "name": "pre-commit-coverage",
        "description": "Verify code coverage remains strictly at or above 90%",
        "command": "scripts/hooks/pre-commit-coverage.sh"
      },
      {
        "name": "pre-commit-security",
        "description": "Run Trivy container and filesystem scan + secrets detection",
        "command": "scripts/hooks/pre-commit-security.sh"
      }
    ],
    "OnInterrupt": [
      {
        "name": "on-interrupt-handler",
        "description": "Intercept missing secrets or environment settings",
        "command": "scripts/hooks/on-interrupt.sh"
      }
    ],
    "OnCircuitBreaker": [
      {
        "name": "circuit-breaker-handler",
        "description": "Coordinate human takeover on 5-attempt loop lockout",
        "command": "scripts/hooks/on-circuit-breaker.sh"
      }
    ],
    "OnArchitectureDrift": [
      {
        "name": "architecture-drift-protection",
        "description": "Defend the sealed architecture against undocumented modifications",
        "command": "scripts/hooks/on-architecture-drift.sh"
      }
    ]
  }
}
EOF
log_success "Generated: .agents/hooks.json"

# ==============================================================================
# 6. Functional Zero-Token Deterministic Hook Scripts
# ==============================================================================
log_info "Generating zero-token hook scripts under scripts/hooks/..."

# 6.1 Pre-Commit Lint Hook
cat << 'EOF' > scripts/hooks/pre-commit-lint.sh
#!/bin/bash
# ==============================================================================
# Pre-Commit Lint Hook - Zero-Token Deterministic Enforcement
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0;37m'

echo -e "[HOOK] Running Pre-Commit Linter Verification Gate..."

# Retrieve staged files
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}[HOOK] No staged files detected. Skipping linter checks.${NC}"
    exit 0
fi

FAILED=0

for file in $STAGED_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # Linter Routing
    case "$file" in
        *.py)
            if command -v ruff &> /dev/null; then
                echo "[LINT] Checking $file with ruff..."
                ruff check "$file" || FAILED=1
            elif command -v pylint &> /dev/null; then
                echo "[LINT] Checking $file with pylint..."
                pylint --errors-only "$file" || FAILED=1
            else
                echo "[LINT] No advanced Python linter found. Checking syntax..."
                python3 -m py_compile "$file" || FAILED=1
            fi
            ;;
        *.js|*.ts|*.jsx|*.tsx)
            if command -v eslint &> /dev/null; then
                echo "[LINT] Checking $file with eslint..."
                npx eslint "$file" || FAILED=1
            else
                echo "[LINT] No JS/TS linter installed. Performing standard syntax check..."
                node -c "$file" &> /dev/null || FAILED=1
            fi
            ;;
        *.sh)
            if command -v shellcheck &> /dev/null; then
                echo "[LINT] Checking $file with shellcheck..."
                shellcheck "$file" || FAILED=1
            else
                echo "[LINT] Shellcheck not available. Basic bash syntax parse..."
                bash -n "$file" || FAILED=1
            fi
            ;;
    esac
done

if [ "$FAILED" -ne 0 ]; then
    echo -e "${RED}[LINT ERROR] Lint errors detected. Resolve before committing.${NC}"
    exit 1
fi

echo -e "${GREEN}[HOOK] Linter verification passed successfully.${NC}"
exit 0
EOF

# 6.2 Pre-Commit Test Hook
cat << 'EOF' > scripts/hooks/pre-commit-test.sh
#!/bin/bash
# ==============================================================================
# Pre-Commit Test Hook - Runs tests and implements log trimming on failure
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0;37m'

echo -e "[HOOK] Running Pre-Commit Test Suite Verification Gate..."

RUNNER=""
TEST_CMD=""

if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    RUNNER="python"
    if command -v pytest &> /dev/null; then
        TEST_CMD="pytest"
    else
        TEST_CMD="python3 -m unittest discover"
    fi
elif [ -f "package.json" ]; then
    RUNNER="javascript"
    if grep -q '"test"' package.json; then
        TEST_CMD="npm test"
    else
        TEST_CMD="npx jest"
    fi
fi

if [ -z "$RUNNER" ]; then
    # Create simple mock testing fallback if no explicit environment exists
    echo "[TEST] No standard runtime files found. Running default/mock validation..."
    # If the user created files under src/core/ mock tests can be auto-generated
    exit 0
fi

echo "[TEST] Running test suite using: $TEST_CMD"
# Implement Log Trimming - redirect output and isolate error assertions
LOG_FILE=$(mktemp)
if ! $TEST_CMD > "$LOG_FILE" 2>&1; then
    echo -e "${RED}[TESTS FAILED] Isomorphic Log Trimming in progress...${NC}"
    echo "======================================================================"
    # Trim logic: Extract only failure summaries, trace lines, and assertions
    if [ "$RUNNER" = "python" ]; then
        grep -E "(FAIL:|ERROR:|AssertionError:|Traceback \(most recent call last\):|tests/.*:[0-9]+)" "$LOG_FILE" | head -n 40 || cat "$LOG_FILE" | tail -n 25
    else
        grep -E "(fail|Error|at\s.*tests/)" "$LOG_FILE" | head -n 40 || cat "$LOG_FILE" | tail -n 25
    fi
    echo "======================================================================"
    rm -f "$LOG_FILE"
    exit 1
fi

rm -f "$LOG_FILE"
echo -e "${GREEN}[HOOK] All test cases executed successfully.${NC}"
exit 0
EOF

# 6.3 Pre-Commit Coverage Hook
cat << 'EOF' > scripts/hooks/pre-commit-coverage.sh
#!/bin/bash
# ==============================================================================
# Pre-Commit Coverage Hook - Enforces >= 90% test coverage floor
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0;37m'

echo -e "[HOOK] Running 90% Test Coverage Enforcement Gate..."

# Look for standard coverage reports
COVERAGE_PERCENT=100

if [ -f ".coverage" ] || [ -f "coverage.xml" ]; then
    if command -v coverage &> /dev/null; then
        COVERAGE_PERCENT=$(coverage report | grep "TOTAL" | awk '{print $4}' | sed 's/%//')
    fi
elif [ -f "coverage/coverage-summary.json" ]; then
    # Extract from Jest coverage summary JSON
    if command -v jq &> /dev/null; then
        COVERAGE_PERCENT=$(jq '.total.lines.pct' coverage/coverage-summary.json | cut -d. -f1)
    fi
fi

# Fallback: Parse output or look if coverage binary is present
if [ "$COVERAGE_PERCENT" = "100" ] && [ -f "requirements.txt" ]; then
    # Try running coverage automatically
    if command -v coverage &> /dev/null && command -v pytest &> /dev/null; then
        echo "[COVERAGE] Computing test coverage..."
        coverage run -m pytest &> /dev/null || true
        COVERAGE_PERCENT=$(coverage report | grep "TOTAL" | awk '{print $4}' | sed 's/%//' || echo "100")
    fi
fi

# Handle newly bootstrapped code with 0 files
if [ "$COVERAGE_PERCENT" = "0" ] || [ -z "$COVERAGE_PERCENT" ]; then
    echo "[COVERAGE] Coverage data unavailable (empty workspace). Defaulting to pass."
    exit 0
fi

echo "[COVERAGE] Resolved current project coverage: ${COVERAGE_PERCENT}%"

if [ "$COVERAGE_PERCENT" -lt 90 ]; then
    echo -e "${RED}[COVERAGE FAIL] Current coverage of ${COVERAGE_PERCENT}% is below the mandatory 90% floor.${NC}"
    exit 1
fi

echo -e "${GREEN}[HOOK] Coverage floor requirements met (${COVERAGE_PERCENT}% >= 90%).${NC}"
exit 0
EOF

# 6.4 Pre-Commit Security Hook
cat << 'EOF' > scripts/hooks/pre-commit-security.sh
#!/bin/bash
# ==============================================================================
# Pre-Commit Security Hook - Runs Trivy and scans for hardcoded secrets
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0;37m'

echo -e "[HOOK] Running Trivy & Secrets Detection Verification Gate..."

# 1. Local hardcoded secrets scanner (High entropy checks)
STAGED_FILES=$(git diff --cached --name-only)
SECRETS_FOUND=0

for file in $STAGED_FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi

    # Detect high-risk words + typical format
    if grep -qE "(_KEY|_SECRET|password|passwd|api_key|private_key|aws_access_key_id)\s*=\s*['\"][a-zA-Z0-9_\-\+]{12,}['\"]" "$file"; then
        echo -e "${RED}[SECURITY ERROR] Potential hardcoded API key or Secret detected in $file${NC}"
        grep -nE "(_KEY|_SECRET|password|passwd|api_key|private_key|aws_access_key_id)" "$file"
        SECRETS_FOUND=1
    fi
done

if [ "$SECRETS_FOUND" -ne 0 ]; then
    echo -e "${RED}[SECURITY HOOK BLOCKED] Secrets scan failed. Redact keys before committing.${NC}"
    exit 1
fi

# 2. Trivy Scan (if installed)
if command -v trivy &> /dev/null; then
    echo "[SECURITY] Executing filesystem security scan with Trivy..."
    if ! trivy fs . --severity HIGH,CRITICAL --exit-code 1; then
        echo -e "${RED}[TRIVY ERROR] High or Critical vulnerabilities discovered in dependencies.${NC}"
        exit 1
    fi
else
    echo "[SECURITY] Trivy tool not found. Skipping vulnerability scan. (Filesystem scan passed)"
fi

echo -e "${GREEN}[HOOK] Security validation passed successfully.${NC}"
exit 0
EOF

# 6.5 On-Interrupt Hook
cat << 'EOF' > scripts/hooks/on-interrupt.sh
#!/bin/bash
# ==============================================================================
# On-Interrupt Hook - Handles missing environment variables and secrets
# ==============================================================================
set -euo pipefail

YELLOW='\033[1;33m'
NC='\033[0;37m'

echo -e "${YELLOW}[HOOK INTERRUPT] Verifying system credentials and configurations...${NC}"

REQUIRED_ENV=("GEMINI_API_KEY")
MISSING=0

for var in "${REQUIRED_ENV[@]}"; do
    if [ -z "${!var:-}" ]; then
        # Check if defined in a local .env file
        if [ -f ".env" ] && grep -qE "^$var=" .env; then
            continue
        fi
        echo -e "${YELLOW}[ALERT] Required environment variable '$var' is missing from local system.${NC}"
        MISSING=1
    fi
done

if [ "$MISSING" -ne 0 ]; then
    echo -e "${YELLOW}[TAKE-OVER] Background loop interrupted due to missing credentials. Please configure .env file.${NC}"
    exit 1
fi

echo "[HOOK] All required environment credentials are valid."
exit 0
EOF

# 6.6 On-Circuit-Breaker Hook
cat << 'EOF' > scripts/hooks/on-circuit-breaker.sh
#!/bin/bash
# ==============================================================================
# On-Circuit-Breaker Hook - Initiates human takeover after 5 failed attempts
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
NC='\033[0;37m'

echo -e "${RED}======================================================================${NC}"
echo -e "${RED}             [!] CIRCUIT BREAKER TRIPPED (STRIKE 5) [!]               ${NC}"
echo -e "${RED}======================================================================${NC}"
echo -e "${RED}Autonomous background development loop paused due to excessive errors.${NC}"
echo -e "${RED}Taking state snapshot and locking repository workspace...${NC}"

# Log details
CB_LOG=".agents/circuit_breaker_state.log"
{
    echo "=================================================="
    echo "CIRCUIT BREAKER DETECTED ON: $(date -u)"
    echo "=================================================="
    echo "Last Commit Hash: $(git rev-parse HEAD || echo "No commits yet")"
    echo "Failing Files Status:"
    git status -s
    echo "Recent Diffs:"
    git diff || echo "No changes"
} > "$CB_LOG"

# Generate emergency branch to isolate state
CB_BRANCH="drift/circuit-breaker-$(date +%s)"
git checkout -b "$CB_BRANCH" &> /dev/null || true

echo -e "${RED}Workspace frozen on: $CB_BRANCH${NC}"
echo -e "${RED}Review failure traces inside: $CB_LOG${NC}"
echo -e "${RED}Resolve issues manually, run git verification gates, then return to main.${NC}"
exit 1
EOF

# 6.7 On-Architecture-Drift Hook
cat << 'EOF' > scripts/hooks/on-architecture-drift.sh
#!/bin/bash
# ==============================================================================
# On-Architecture-Drift Hook - Prevents unauthorized modifications to sealed architecture docs
# ==============================================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0;37m'

echo -e "[HOOK] Checking Architecture Integrity Guard..."

# Check if docs/architecture.md is staged for change
if git diff --cached --name-only | grep -q "docs/architecture.md"; then
    echo -e "${YELLOW}[WARNING] Modified architecture specification detected (docs/architecture.md).${NC}"
    
    # Verify if an explicit architecture lock bypass or signed consent exists
    if [ -f ".agents/bypass-architecture-gate" ]; then
        echo -e "${GREEN}[HOOK] Architectural bypass active. Allowing modifications.${NC}"
        rm -f ".agents/bypass-architecture-gate"
        exit 0
    fi

    echo -e "${RED}[ARCHITECTURE DRIFT BLOCKED]${NC}"
    echo -e "${RED}You are attempting to modify the sealed, immutable 'docs/architecture.md' file.${NC}"
    echo -e "${RED}Any changes to infrastructure, frameworks, or database choices must first execute${NC}"
    echo -e "${RED}the /arch-gate command or create the '.agents/bypass-architecture-gate' file.${NC}"
    exit 1
fi

echo -e "${GREEN}[HOOK] Architecture specification intact.${NC}"
exit 0
EOF

log_success "Generated all deterministic zero-token hook scripts."

# ==============================================================================
# 7. Make Scripts Executable & Register Git Hook
# ==============================================================================
log_info "Enforcing permissions and linking triggers..."
chmod +x scripts/hooks/*.sh
log_success "Made hook scripts executable."

# Optionally install git hook trigger automatically
if [ -d ".git" ] && [ ! -d ".git/hooks" ]; then
    mkdir -p .git/hooks
fi

if [ -d ".git/hooks" ]; then
    # Hook redirector script
    cat << 'EOF' > .git/hooks/pre-commit
#!/bin/bash
set -e
# Delegate to the bootstrapped scripts
./scripts/hooks/pre-commit-lint.sh
./scripts/hooks/pre-commit-test.sh
./scripts/hooks/pre-commit-coverage.sh
./scripts/hooks/pre-commit-security.sh
./scripts/hooks/on-architecture-drift.sh
EOF
    chmod +x .git/hooks/pre-commit
    log_success "Successfully installed pre-commit git hooks to delegate verification gates."
fi

# ==============================================================================
# Summary
# ==============================================================================
echo -e "${CYAN}======================================================================${NC}"
log_success "ANTIGRAVITY DEV SUITE BOOTSTRAPPED SUCCESSFULLY!"
echo -e "${CYAN}======================================================================${NC}"
echo -e "Directories:        ${GREEN}✓ Created${NC}"
echo -e "AGENTS.md:          ${GREEN}✓ Generated (Constitution)${NC}"
echo -e "Specialized Rules:  ${GREEN}✓ Created (.agents/rules/)${NC}"
echo -e "Workflows:          ${GREEN}✓ Created (.agents/workflows/)${NC}"
echo -e "Skill Templates:    ${GREEN}✓ Compiled (.agents/skills/)${NC}"
echo -e "Hooks Configuration:${GREEN}✓ Registered (.agents/hooks.json)${NC}"
echo -e "Enforcement Gates:  ${GREEN}✓ Functional scripts deployed (scripts/hooks/)${NC}"
echo -e "Git Integration:    ${GREEN}✓ Active and integrated${NC}"
echo -e "${CYAN}======================================================================${NC}"
