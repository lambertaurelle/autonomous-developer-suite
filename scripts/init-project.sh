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
    ".agents/workflows/goal.md"
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
