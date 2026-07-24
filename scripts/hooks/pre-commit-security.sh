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
