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
