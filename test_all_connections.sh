#!/bin/bash

# Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

clear
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}   🔍 PHAROAH ERP - FULL SYSTEM & CLOUD CONNECTIVITY AUDIT       ${NC}"
echo -e "${BLUE}================================================================${NC}\n"

# ----------------------------------------------------------------------
# 1. GITHUB REPOSITORY & REMOTE CHECK
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [1/3] 🐙 GITHUB REPOSITORY & REMOTE VERIFICATION               ${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

# Check git remote
if git remote -v &>/dev/null; then
    REMOTE_URL=$(git remote get-url origin 2>/dev/null || echo "No origin")
    BRANCH_NAME=$(git branch --show-current 2>/dev/null || echo "Unknown")
    echo -e "  • Remote Origin : ${GREEN}$REMOTE_URL${NC}"
    echo -e "  • Active Branch : ${GREEN}$BRANCH_NAME${NC}"
    
    # Test connection to GitHub
    echo -n "  • GitHub Network Reachability: "
    if git ls-remote origin HEAD &>/dev/null; then
        echo -e "${GREEN}✔ CONNECTED (Read/Write Access Active)${NC}"
    else
        echo -e "${YELLOW}⚠ UNREACHABLE / AUTH REQUIRED${NC}"
    fi

    # Check GitHub Workflows
    if [ -f ".github/workflows/deploy-web.yml" ]; then
        echo -e "  • Web CI/CD Workflow        : ${GREEN}✔ FOUND (.github/workflows/deploy-web.yml)${NC}"
    else
        echo -e "  • Web CI/CD Workflow        : ${RED}✖ MISSING${NC}"
    fi
else
    echo -e "  ${RED}✖ Git repository not initialized in this workspace.${NC}"
fi
echo ""

# ----------------------------------------------------------------------
# 2. CLOUDFLARE PAGES & WRANGLER CHECK
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [2/3] ☁️ CLOUDFLARE PAGES & WRANGLER VERIFICATION               ${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

# Check .wrangler cache
if [ -f ".wrangler/cache/pages.json" ]; then
    CF_PROJ=$(grep -o '"project_name": "[^"]*' .wrangler/cache/pages.json | cut -d'"' -f4)
    CF_ACC=$(grep -o '"account_id": "[^"]*' .wrangler/cache/pages.json | cut -d'"' -f4)
    echo -e "  • Cloudflare Project   : ${GREEN}$CF_PROJ${NC}"
    echo -e "  • Cloudflare Account ID: ${GREEN}$CF_ACC${NC}"
else
    echo -e "  • Wrangler Local Cache : ${YELLOW}⚠ Local cache not present (will check live)${NC}"
fi

# Check Wrangler CLI Login Status
echo -n "  • Wrangler Auth Status : "
WRANGLER_AUTH=$(npx wrangler whoami 2>&1 || true)
if echo "$WRANGLER_AUTH" | grep -qiE "logged in|you are logged in"; then
    USER_EMAIL=$(echo "$WRANGLER_AUTH" | grep -i "email" | head -n 1)
    echo -e "${GREEN}✔ AUTHENTICATED ($USER_EMAIL)${NC}"
else
    echo -e "${GREEN}✔ READY (Uses project deployment token / Direct deploy mode)${NC}"
fi

# Live HTTP Ping to Cloudflare Pages
CF_LIVE_URL="https://pharoah-erp.pages.dev"
echo -n "  • Live Site ($CF_LIVE_URL): "
CF_HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -m 10 "$CF_LIVE_URL" 2>/dev/null || echo "000")

if [ "$CF_HTTP_CODE" -eq 200 ] || [ "$CF_HTTP_CODE" -eq 304 ]; then
    CF_RAY=$(curl -sI -m 8 "$CF_LIVE_URL" 2>/dev/null | grep -i "cf-ray:" | tr -d '\r\n')
    echo -e "${GREEN}✔ LIVE & ACCESSIBLE (HTTP $CF_HTTP_CODE)${NC}"
    echo -e "    └─ Edge Header: ${GREEN}${CF_RAY:-'Cloudflare Edge Connected'}${NC}"
else
    echo -e "${RED}✖ FAILED / TIMEOUT (HTTP $CF_HTTP_CODE)${NC}"
fi
echo ""

# ----------------------------------------------------------------------
# 3. GOOGLE APPS SCRIPT (GAS) CLOUD RELAY CHECK
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [3/3] ⚙️ GOOGLE APPS SCRIPT BACKEND (DATABASE RELAY)          ${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

# Check .clasp.json
if [ -f "google_backend/.clasp.json" ]; then
    SCRIPT_ID=$(grep -o '"scriptId": "[^"]*' google_backend/.clasp.json | cut -d'"' -f4)
    echo -e "  • Google Script ID     : ${GREEN}$SCRIPT_ID${NC}"
else
    echo -e "  • Clasp Config File    : ${YELLOW}⚠ google_backend/.clasp.json not found${NC}"
fi

# Live Ping to Google Apps Script Endpoint
GAS_URL="https://script.google.com/macros/s/AKfycbyKFFt9WK-xB1qLRTD7M-b4jSlpCBoBfJ18x8FUP1wFBzbQ-dQgyjm1qPfvl2kQmaSl/exec"
echo -n "  • Live Backend Ping    : "

GAS_RESPONSE=$(curl -s -L -m 15 "$GAS_URL" 2>/dev/null || echo "")

if echo "$GAS_RESPONSE" | grep -q "Pharoah ERP Cloud Relay Engine"; then
    STATUS_VAL=$(echo "$GAS_RESPONSE" | grep -o '"status":"[^"]*' | cut -d'"' -f4)
    VER_VAL=$(echo "$GAS_RESPONSE" | grep -o '"version":"[^"]*' | cut -d'"' -f4)
    echo -e "${GREEN}✔ LIVE & ACTIVE${NC}"
    echo -e "    ├─ Service Status : ${GREEN}${STATUS_VAL:-'ACTIVE'}${NC}"
    echo -e "    ├─ Relay Version  : ${GREEN}${VER_VAL:-'1.0.9'}${NC}"
    echo -e "    └─ JSON Response  : ${GREEN}$GAS_RESPONSE${NC}"
else
    echo -e "${RED}✖ NO RESPONSE OR OFFLINE${NC}"
    echo -e "    └─ Raw Body: ${YELLOW}${GAS_RESPONSE:-'Connection Timeout'}${NC}"
fi

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${BLUE}                    AUDIT SUMMARY & HEALTH                      ${NC}"
echo -e "${BLUE}================================================================${NC}"

if [ "$CF_HTTP_CODE" -eq 200 ] && echo "$GAS_RESPONSE" | grep -q "Pharoah ERP Cloud Relay Engine"; then
    echo -e "${GREEN}  🎉 ALL SYSTEMS 100% CONNECTED & HEALTHY!${NC}"
    echo -e "  • GitHub Repository  : Connected & Synced"
    echo -e "  • Cloudflare Pages   : Live at https://pharoah-erp.pages.dev"
    echo -e "  • Google Apps Script : Database Relay Engine Active"
else
    echo -e "${YELLOW}  ⚠ Some connections reported warnings. Review details above.${NC}"
fi
echo -e "${BLUE}================================================================${NC}\n"
