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
                if [ -f "pyproject.toml" ] || [ -f "ruff.toml" ] || [ -f ".ruff.toml" ]; then
                    echo "[LINT] Checking $file with ruff..."
                    ruff check "$file" || FAILED=1
                else
                    echo "[LINT] Checking $file with ruff (falling back to .agents/default-ruff.toml)..."
                    ruff check --config .agents/default-ruff.toml "$file" || FAILED=1
                fi
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
                HAS_LOCAL_CONFIG=0
                for config in eslint.config.js eslint.config.mjs eslint.config.cjs .eslintrc.json .eslintrc.js .eslintrc.yaml .eslintrc.yml; do
                    if [ -f "$config" ]; then
                        HAS_LOCAL_CONFIG=1
                        break
                    fi
                done

                if [ "$HAS_LOCAL_CONFIG" -eq 1 ]; then
                    echo "[LINT] Checking $file with eslint..."
                    npx eslint "$file" || FAILED=1
                else
                    echo "[LINT] Checking $file with eslint (falling back to .agents/default-eslint.json)..."
                    npx eslint --config .agents/default-eslint.json "$file" || FAILED=1
                fi
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
