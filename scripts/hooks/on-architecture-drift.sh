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
