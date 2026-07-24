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
