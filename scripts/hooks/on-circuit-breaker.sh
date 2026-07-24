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
