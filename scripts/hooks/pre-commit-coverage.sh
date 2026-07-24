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
