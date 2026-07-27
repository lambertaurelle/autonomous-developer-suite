#!/bin/bash
# ==============================================================================
# Antigravity Git Pre-Commit Hook Installer Script
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_DIR="$(git rev-parse --git-dir 2>/dev/null || echo ".git")"
HOOKS_DIR="$GIT_DIR/hooks"
TARGET_HOOK="$HOOKS_DIR/pre-commit"

if [ ! -d "$HOOKS_DIR" ]; then
    mkdir -p "$HOOKS_DIR"
fi

cat << 'EOF' > "$TARGET_HOOK"
#!/bin/bash
# Antigravity Pre-Commit Enforcement Hook Wrapper
set -e

SCRIPT_DIR="$(git rev-parse --show-toplevel)/scripts/hooks"

if [ -f "$SCRIPT_DIR/pre-commit-lint.sh" ]; then
    echo -e "\033[0;34m[ANTIGRAVITY HOOK]\033[0m Running pre-commit-lint.sh..."
    bash "$SCRIPT_DIR/pre-commit-lint.sh"
fi

if [ -f "$SCRIPT_DIR/pre-commit-test.sh" ]; then
    echo -e "\033[0;34m[ANTIGRAVITY HOOK]\033[0m Running pre-commit-test.sh..."
    bash "$SCRIPT_DIR/pre-commit-test.sh"
fi

if [ -f "$SCRIPT_DIR/pre-commit-coverage.sh" ]; then
    echo -e "\033[0;34m[ANTIGRAVITY HOOK]\033[0m Running pre-commit-coverage.sh..."
    bash "$SCRIPT_DIR/pre-commit-coverage.sh"
fi

if [ -f "$SCRIPT_DIR/pre-commit-security.sh" ]; then
    echo -e "\033[0;34m[ANTIGRAVITY HOOK]\033[0m Running pre-commit-security.sh..."
    bash "$SCRIPT_DIR/pre-commit-security.sh"
fi

exit 0
EOF

chmod +x "$TARGET_HOOK"
echo -e "\033[0;32m[SUCCESS]\033[0m Registered Antigravity pre-commit verification hooks in '$TARGET_HOOK'."
