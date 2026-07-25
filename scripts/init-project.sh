#!/bin/bash
# ==============================================================================
# Antigravity Project Initializer & Bootstrap Script (v5.0 Remote-Ready)
# ==============================================================================
# This script bootstraps any new software engineering repository to strictly
# align with the Architecture Blueprint: Autonomous Development Driven by AI Agents (V3)
# and Gemini Cookbook standards.
#
# Can be run locally OR remotely via curl/wget:
#   curl -fsSL https://raw.githubusercontent.com/lambertaurelle/autonomous-developer-suite/main/scripts/init-project.sh | bash
# ==============================================================================

set -euo pipefail

# GitHub Raw Repository Base URL
RAW_BASE="https://raw.githubusercontent.com/lambertaurelle/autonomous-developer-suite/main"

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
echo -e "${CYAN}        ANTIGRAVITY AUTONOMOUS DEV SUITE INITIALIZER (V5.0)${NC}"
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

# Verify GitHub CLI authentication status and required token scope
verify_gh_auth_and_scope() {
    if ! gh auth status &> /dev/null; then
        return 1
    fi
    if ! gh project list --owner "@me" &> /dev/null; then
        return 1
    fi
    return 0
}

if ! verify_gh_auth_and_scope; then
    log_error "GitHub CLI authentication or mandatory 'project' scope is missing."
    echo -e "${YELLOW}[ACTION REQUIRED]${NC} Please authenticate and grant the 'project' scope by running:"
    echo -e "  ${CYAN}gh auth refresh -s project${NC}"
    echo -e "or"
    echo -e "  ${CYAN}gh auth login -s project${NC}"
    echo -e ""
    echo -e "Press Enter after you have successfully authenticated to retry, or Ctrl+C to abort."
    read -r < /dev/tty 2>/dev/null || true
    
    # Re-verify authentication and project scope
    if ! verify_gh_auth_and_scope; then
        log_error "GitHub authentication / 'project' scope verification failed again. Bootstrapping aborted."
        echo -e "${RED}[ABORTED]${NC} Please run '${CYAN}gh auth refresh -s project${NC}' to authenticate and re-run this script."
        exit 1
    fi
fi

log_success "Authenticated to GitHub with 'project' scope successfully."

# Initialize standard git repository if missing
if [ ! -d ".git" ]; then
    log_warn "Git repository not found in current directory. Initializing git..."
    git init
    git checkout -b main &>/dev/null || git branch -M main &>/dev/null || true
fi

# Ensure initial commit exists with explicit fallback user authoring
if [ -z "$(git log -n 1 2>/dev/null)" ]; then
    log_info "Creating initial placeholder commit..."
    git branch -M main 2>/dev/null || true
    echo "# Bootstrapped Project" > README.md
    git add README.md
    
    GIT_AUTHOR_NAME="$(git config user.name 2>/dev/null || echo "Antigravity Agent")"
    GIT_AUTHOR_EMAIL="$(git config user.email 2>/dev/null || echo "agent@antigravity.ai")"
    
    GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" \
    GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL" \
    GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" \
    GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
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
    read -r choice < /dev/tty || choice="3"
    
    case "$choice" in
        1)
            repo_name=$(basename "$(pwd)")
            log_info "Creating private GitHub repository '$repo_name'..."
            if gh repo create "$repo_name" --private --source=. --remote=origin 2>/dev/null; then
                log_success "Created private GitHub repository '$repo_name'."
            else
                log_warn "GitHub repository creation via gh CLI was skipped or repository already exists."
            fi
            log_info "Pushing initial commit to GitHub..."
            git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || log_warn "Initial push skipped or failed. You can push manually using 'git push -u origin main'."
            ;;
        2)
            repo_name=$(basename "$(pwd)")
            log_info "Creating public GitHub repository '$repo_name'..."
            if gh repo create "$repo_name" --public --source=. --remote=origin 2>/dev/null; then
                log_success "Created public GitHub repository '$repo_name'."
            else
                log_warn "GitHub repository creation via gh CLI was skipped or repository already exists."
            fi
            log_info "Pushing initial commit to GitHub..."
            git push -u origin main 2>/dev/null || git push -u origin master 2>/dev/null || log_warn "Initial push skipped or failed. You can push manually using 'git push -u origin main'."
            ;;
        *)
            log_warn "Skipped GitHub repository creation. Please configure origin remote manually using 'git remote add origin'."
            ;;
    esac
else
    log_info "Git remote 'origin' already exists: $(git remote get-url origin)"
fi

# ==============================================================================
# GitHub Project Board (V2) & Status Field Initialization
# ==============================================================================
log_info "Verifying GitHub Project Board & Status Stage Transitions..."

# JSON Parsing Helper Functions
json_extract_project_number() {
    local json="$1"
    local title="$2"
    if command -v jq &>/dev/null; then
        echo "$json" | jq -r ".projects[]? | select(.title | contains(\"$title\")) | .number" 2>/dev/null | head -n 1
    elif command -v python3 &>/dev/null; then
        python3 -c "import sys, json; data=json.load(sys.stdin); print(next((str(p['number']) for p in data.get('projects',[]) if '$title' in p.get('title','')), ''))" <<< "$json" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import sys, json; data=json.load(sys.stdin); print(next((str(p['number']) for p in data.get('projects',[]) if '$title' in p.get('title','')), ''))" <<< "$json" 2>/dev/null
    else
        echo "$json" | grep -o '"number":[0-9]*' | head -n 1 | cut -d':' -f2
    fi
}

json_extract_number() {
    local json="$1"
    if command -v jq &>/dev/null; then
        echo "$json" | jq -r '.number // empty' 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "import sys, json; data=json.load(sys.stdin); print(str(data.get('number','')))" <<< "$json" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import sys, json; data=json.load(sys.stdin); print(str(data.get('number','')))" <<< "$json" 2>/dev/null
    else
        echo "$json" | grep -o '"number":[0-9]*' | head -n 1 | cut -d':' -f2
    fi
}

json_extract_field_id_by_name() {
    local json="$1"
    local field_name="$2"
    if command -v jq &>/dev/null; then
        echo "$json" | jq -r ".fields[]? | select(.name == \"$field_name\") | .id" 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "import sys, json; data=json.load(sys.stdin); print(next((f['id'] for f in data.get('fields',[]) if f.get('name')=='$field_name'), ''))" <<< "$json" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import sys, json; data=json.load(sys.stdin); print(next((f['id'] for f in data.get('fields',[]) if f.get('name')=='$field_name'), ''))" <<< "$json" 2>/dev/null
    else
        echo "$json" | grep -o '"id":"PVT[A-Za-z0-9_]*"' | head -n 1 | cut -d'"' -f4
    fi
}

json_extract_issue_urls() {
    if command -v jq &>/dev/null; then
        jq -r '.[].url' 2>/dev/null
    elif command -v python3 &>/dev/null; then
        python3 -c "import sys, json; data=json.load(sys.stdin); print('\n'.join(item['url'] for item in data if 'url' in item))" 2>/dev/null
    elif command -v python &>/dev/null; then
        python -c "import sys, json; data=json.load(sys.stdin); print('\n'.join(item['url'] for item in data if 'url' in item))" 2>/dev/null
    else
        grep -o '"url":"https://[^"]*"' | cut -d'"' -f4
    fi
}

REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
REPO_OWNER=""
REPO_NAME=""
REPO_SLUG=""

if [ -n "$REMOTE_URL" ]; then
    REPO_SLUG="$(echo "$REMOTE_URL" | sed -E 's/.*[:\/]([^\/]+\/[^\/]+?)(\.git)?$/\1/')"
    REPO_SLUG="${REPO_SLUG%.git}"
    REPO_OWNER="$(echo "$REPO_SLUG" | cut -d'/' -f1)"
    REPO_NAME="$(echo "$REPO_SLUG" | cut -d'/' -f2)"
fi

if [ -z "$REPO_OWNER" ]; then
    REPO_OWNER="@me"
    REPO_NAME="$(basename "$(pwd)")"
fi
REPO_NAME="${REPO_NAME%.git}"

log_info "[TRACE] Target Owner: '$REPO_OWNER' | Repo Name: '$REPO_NAME' | Slug: '${REPO_SLUG:-N/A}'"

PROJECT_NAME="autonomous-dev-board"
STATUS_OPTIONS="Backlog,Ready,Spec Reviewed,In Progress,In Review,Done"

log_info "[TRACE] Searching existing GitHub Projects for '$PROJECT_NAME' under owner '$REPO_OWNER'..."
PROJECTS_LIST_OUTPUT="$(gh project list --owner "$REPO_OWNER" --format json 2>&1 || true)"
log_info "[TRACE] gh project list output:\n$PROJECTS_LIST_OUTPUT"

PROJECT_NUM="$(json_extract_project_number "$PROJECTS_LIST_OUTPUT" "$PROJECT_NAME")"
log_info "[TRACE] Found Project Number for '$PROJECT_NAME': '${PROJECT_NUM:-NONE}'"

if [ -z "$PROJECT_NUM" ] || [ "$PROJECT_NUM" = "null" ]; then
    log_info "Creating GitHub Project V2 board: '$PROJECT_NAME'..."
    CREATE_OUTPUT="$(gh project create --owner "$REPO_OWNER" --title "$PROJECT_NAME" --format json 2>&1 || true)"
    log_info "[TRACE] gh project create output:\n$CREATE_OUTPUT"
    PROJECT_NUM="$(json_extract_number "$CREATE_OUTPUT")"
fi

if [ -n "$PROJECT_NUM" ] && [ "$PROJECT_NUM" != "null" ]; then
    log_success "GitHub Project Board '$PROJECT_NAME' (#$PROJECT_NUM) active."
    
    log_info "[TRACE] Linking Project #$PROJECT_NUM to repository..."
    LINK_OUTPUT="$(gh project link "$PROJECT_NUM" --owner "$REPO_OWNER" --repo "$REPO_NAME" 2>&1 || gh project link "$PROJECT_NUM" --repo "${REPO_SLUG:-$REPO_NAME}" 2>&1 || gh project link "$PROJECT_NUM" 2>&1 || true)"
    log_info "[TRACE] gh project link output:\n$LINK_OUTPUT"

    log_info "[TRACE] Fetching fields for Project #$PROJECT_NUM..."
    FIELDS_OUTPUT="$(gh project field-list "$PROJECT_NUM" --owner "$REPO_OWNER" --format json 2>&1 || true)"
    log_info "[TRACE] gh project field-list output:\n$FIELDS_OUTPUT"

    STAGE_FIELD_ID="$(json_extract_field_id_by_name "$FIELDS_OUTPUT" "Stage")"
    log_info "[TRACE] Target Stage Field ID: '${STAGE_FIELD_ID:-NONE}'"

    if [ -z "$STAGE_FIELD_ID" ] || [ "$STAGE_FIELD_ID" = "null" ]; then
        log_info "Creating custom GitHub Project 'Stage' field ($STATUS_OPTIONS)..."
        FIELD_CREATE_OUTPUT="$(gh project field-create "$PROJECT_NUM" --owner "$REPO_OWNER" --name "Stage" --data-type "SINGLE_SELECT" --single-select-options "$STATUS_OPTIONS" 2>&1 || true)"
        log_info "[TRACE] gh project field-create 'Stage' output:\n$FIELD_CREATE_OUTPUT"
        log_success "Created GitHub Project 'Stage' field with stage transitions!"
    else
        log_success "GitHub Project 'Stage' field verified active."
    fi

    # Synchronize existing open repository issues to the project board
    log_info "Synchronizing existing open repository issues to Project Board #$PROJECT_NUM..."
    ISSUES_OUTPUT="$(gh issue list --state open --limit 100 --json url 2>&1 || true)"
    log_info "[TRACE] gh issue list output:\n$ISSUES_OUTPUT"

    EXISTING_ISSUES="$(echo "$ISSUES_OUTPUT" | json_extract_issue_urls 2>/dev/null || true)"
    if [ -z "$EXISTING_ISSUES" ] && [ -n "${REPO_SLUG:-}" ]; then
        SLUG_OUTPUT="$(gh issue list --repo "$REPO_SLUG" --state open --limit 100 --json url 2>&1 || true)"
        log_info "[TRACE] gh issue list --repo output:\n$SLUG_OUTPUT"
        EXISTING_ISSUES="$(echo "$SLUG_OUTPUT" | json_extract_issue_urls 2>/dev/null || true)"
    fi

    log_info "[TRACE] Discovered open issues to link:\n${EXISTING_ISSUES:-NONE}"

    if [ -n "$EXISTING_ISSUES" ] && [ "$EXISTING_ISSUES" != "NONE" ]; then
        for issue_url in $EXISTING_ISSUES; do
            log_info "[TRACE] Adding issue to project: $issue_url"
            ADD_OUTPUT="$(gh project item-add "$PROJECT_NUM" --owner "$REPO_OWNER" --url "$issue_url" 2>&1 || true)"
            log_info "[TRACE] gh project item-add output:\n$ADD_OUTPUT"
        done
        log_success "Synchronized existing open issues to Project Board #$PROJECT_NUM!"
    else
        log_info "No open repository issues found to sync."
    fi
else
    log_error "Failed to create or retrieve GitHub Project board for '$REPO_NAME'."
    exit 1
fi


# ==============================================================================
# Directory Tree Construction
# ==============================================================================
log_info "Creating autonomous developer directory tree..."
DIRS=(
    ".agents/skills/interview-prd"
    ".agents/skills/audit-prd"
    ".agents/skills/arch-gate"
    ".agents/skills/prd2backlog"
    ".agents/skills/prd2backlog/templates"
    ".agents/skills/specify"
    ".agents/skills/specify/templates"
    ".agents/skills/review-spec"
    ".agents/skills/tdd-build"
    ".agents/skills/tdd-build/templates"
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
# Remote & Local File Synchronization Engine
# ==============================================================================
log_info "Synchronizing production governance, rules, workflows, skills, and hooks..."

FILES_TO_SYNC=(
    "AGENTS.md"
    ".gitattributes"
    ".agents/hooks.json"
    ".agents/default-eslint.json"
    ".agents/default-ruff.toml"
    ".agents/rules/circuit-breakers.md"
    ".agents/rules/fc-is-architecture.md"
    ".agents/rules/model-cascading.md"
    ".agents/rules/traceability.md"
    ".agents/workflows/implementation-loop.md"
    ".agents/workflows/interview-prd.md"
    ".agents/skills/arch-gate/SKILL.md"
    ".agents/skills/audit-prd/SKILL.md"
    ".agents/skills/e2e-test/SKILL.md"
    ".agents/skills/interview-prd/SKILL.md"
    ".agents/skills/prd2backlog/SKILL.md"
    ".agents/skills/prd2backlog/templates/STORY.template.md"
    ".agents/skills/review-spec/SKILL.md"
    ".agents/skills/ship/SKILL.md"
    ".agents/skills/specify/SKILL.md"
    ".agents/skills/specify/templates/SPEC.template.md"
    ".agents/skills/tdd-build/SKILL.md"
    ".agents/skills/tdd-build/templates/code-layout.env.template"
    ".agents/skills/tdd-build/templates/code-layout.template.md"
    "scripts/hooks/on-architecture-drift.sh"
    "scripts/hooks/on-circuit-breaker.sh"
    "scripts/hooks/on-interrupt.sh"
    "scripts/hooks/pre-commit-coverage.sh"
    "scripts/hooks/pre-commit-lint.sh"
    "scripts/hooks/pre-commit-security.sh"
    "scripts/hooks/pre-commit-test.sh"
)

sync_file() {
    local relative_path="$1"

    if [ -f "$relative_path" ]; then
        log_info "Preserved existing file: $relative_path"
        return 0
    fi

    mkdir -p "$(dirname "$relative_path")"

    # 1. Try local copy if running from within a local suite clone
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
    if [ -n "$SCRIPT_DIR" ]; then
        LOCAL_SRC="$(cd "$SCRIPT_DIR/.." 2>/dev/null && pwd)/$relative_path"
        if [ -f "$LOCAL_SRC" ]; then
            cp "$LOCAL_SRC" "$relative_path"
            log_success "Copied from local suite: $relative_path"
            return 0
        fi
    fi

    # 2. Try downloading directly from GitHub public raw URL
    log_info "Fetching $relative_path from GitHub..."
    if command -v curl &>/dev/null && curl -sSfL "$RAW_BASE/$relative_path" -o "$relative_path" 2>/dev/null; then
        log_success "Downloaded from GitHub: $relative_path"
        return 0
    elif command -v wget &>/dev/null && wget -qO "$relative_path" "$RAW_BASE/$relative_path" 2>/dev/null; then
        log_success "Downloaded from GitHub via wget: $relative_path"
        return 0
    fi

    log_warn "Could not fetch $relative_path from remote repository."
    return 1
}

for file in "${FILES_TO_SYNC[@]}"; do
    sync_file "$file"
done

# Ensure hook scripts are executable
chmod +x scripts/hooks/*.sh 2>/dev/null || true

# Normalize line endings for shell scripts if dos2unix / sed is available
if command -v dos2unix &>/dev/null; then
    dos2unix scripts/hooks/*.sh 2>/dev/null || true
elif command -v sed &>/dev/null; then
    sed -i 's/\r$//' scripts/hooks/*.sh 2>/dev/null || true
fi

# Stage and commit all bootstrapped suite files
log_info "Staging and committing bootstrapped autonomous developer suite files..."
git add . 2>/dev/null || true

GIT_AUTHOR_NAME="$(git config user.name 2>/dev/null || echo "Antigravity Agent")"
GIT_AUTHOR_EMAIL="$(git config user.email 2>/dev/null || echo "agent@antigravity.ai")"

GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME" \
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL" \
GIT_AUTHOR_NAME="$GIT_AUTHOR_NAME" \
GIT_AUTHOR_EMAIL="$GIT_AUTHOR_EMAIL" \
git commit -m "feat(bootstrap): initialize autonomous developer suite [v5.0]" --no-verify 2>/dev/null || true

if git remote get-url origin &>/dev/null; then
    log_info "Pushing bootstrapped suite files to GitHub..."
    git push origin main 2>/dev/null || git push origin master 2>/dev/null || true
fi

echo -e "${GREEN}======================================================================${NC}"
echo -e "${GREEN}    AUTONOMOUS DEVELOPER SUITE INITIALIZATION COMPLETE! [✓]${NC}"
echo -e "${GREEN}======================================================================${NC}"
echo -e "Your workspace is now fully configured with:"
echo -e "  - GitHub issue & PR tracking integration (${CYAN}gh${NC})"
echo -e "  - Agent Constitution (${CYAN}AGENTS.md${NC})"
echo -e "  - 9 Production Skills & Workflows (${CYAN}.agents/skills/${NC})"
echo -e "  - Deterministic Zero-Token Pre-Commit Gates (${CYAN}scripts/hooks/${NC})"
echo -e ""
echo -e "Next Step: Start your product scoping session by typing:"
echo -e "  ${PURPLE}/interview-prd${NC}"
