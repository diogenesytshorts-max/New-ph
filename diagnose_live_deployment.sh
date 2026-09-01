#!/bin/bash

# Color Codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}   🔍 CLOUDFLARE LIVE DEPLOYMENT & CACHE DIAGNOSTIC AUDIT       ${NC}"
echo -e "${BLUE}================================================================${NC}\n"

# ----------------------------------------------------------------------
# 1. LOCAL CODE & BUILD ARTIFACTS CHECK
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [1/4] 📦 LOCAL SOURCE CODE & BUILD FILES CHECK                ${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

if [ -f "build/web/main.dart.js" ]; then
    BUILD_TIME=$(stat -c '%y' build/web/main.dart.js 2>/dev/null || stat -f '%Sm' build/web/main.dart.js 2>/dev/null)
    BUILD_SIZE=$(du -sh build/web/main.dart.js | cut -f1)
    echo -e "  • Local Compiled JS File : ${GREEN}EXISTS${NC} (Size: $BUILD_SIZE)"
    echo -e "  • Last Compiled At      : ${GREEN}$BUILD_TIME${NC}"
else
    echo -e "  • Local Compiled JS File : ${RED}MISSING (build/web/main.dart.js not found)${NC}"
fi

# Check Revision Tag in local web_top_bar.dart
LOCAL_TAG=$(grep -o '#PH-REV-[0-9]*' lib/web_live_sync/components/web_top_bar.dart 2>/dev/null || echo "No tag found")
echo -e "  • Local Top Bar Tag     : ${GREEN}$LOCAL_TAG${NC}"
echo ""

# ----------------------------------------------------------------------
# 2. CLOUDFLARE DEPLOYMENT STATUS VIA WRANGLER
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [2/4] ☁️ CLOUDFLARE PAGES WRANGLER DEPLOYMENT HISTORY          ${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

echo "Fetching latest deployments from Cloudflare API..."
DEPLOY_OUTPUT=$(npx wrangler pages deployment list --project-name=pharoah-erp 2>&1 || true)

if echo "$DEPLOY_OUTPUT" | grep -qi "Deployment ID"; then
    echo -e "${GREEN}✔ Deployment History Found:${NC}"
    echo "$DEPLOY_OUTPUT" | head -n 12
else
    echo -e "${YELLOW}$DEPLOY_OUTPUT${NC}"
fi
echo ""

# ----------------------------------------------------------------------
# 3. LIVE EDGE NETWORK FETCH (BYPASSING BROWSER CACHE)
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [3/4] 🌐 LIVE EDGE FETCH (Testing https://pharoah-erp.pages.dev)${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

LIVE_URL="https://pharoah-erp.pages.dev"
TIMESTAMP=$(date +%s)

# Fetch Live Headers
echo "Testing Live HTTP Response Headers..."
HEADERS=$(curl -sI -m 10 "$LIVE_URL/?cache_bypass=$TIMESTAMP" 2>/dev/null || true)

HTTP_STATUS=$(echo "$HEADERS" | grep -i "HTTP/" | head -n 1 | tr -d '\r\n')
CF_RAY=$(echo "$HEADERS" | grep -i "cf-ray:" | tr -d '\r\n')
AGE_HEADER=$(echo "$HEADERS" | grep -i "age:" | tr -d '\r\n')
CACHE_HEADER=$(echo "$HEADERS" | grep -i "cf-cache-status:" | tr -d '\r\n')

echo -e "  • Status Response : ${GREEN}$HTTP_STATUS${NC}"
echo -e "  • Cloudflare Edge : ${GREEN}${CF_RAY:-'N/A'}${NC}"
echo -e "  • Edge Cache Age  : ${YELLOW}${AGE_HEADER:-'Age: 0s'}${NC}"
echo -e "  • Edge Cache Stat : ${YELLOW}${CACHE_HEADER:-'DYNAMIC / BYPASS'}${NC}"

# Fetch Live Index HTML & Check JS script tag
echo ""
echo "Inspecting live index.html for fresh bootstrap script..."
LIVE_HTML=$(curl -s -L -m 10 "$LIVE_URL/?cb=$TIMESTAMP" 2>/dev/null || true)

if echo "$LIVE_HTML" | grep -q "flutter_bootstrap.js"; then
    BOOTSTRAP_LINE=$(echo "$LIVE_HTML" | grep "flutter_bootstrap.js" | head -n 1)
    echo -e "  • Live Script Injection : ${GREEN}✔ OK${NC}"
    echo -e "    └─ Code: ${YELLOW}$BOOTSTRAP_LINE${NC}"
else
    echo -e "  • Live Script Injection : ${RED}✖ Could not find flutter_bootstrap.js in live HTML${NC}"
fi

# Check what Revision Tag is currently LIVE on Cloudflare
echo ""
echo "Scanning live main.dart.js on Cloudflare server for Revision Tags..."
LIVE_JS_TAG=$(curl -s -L -m 15 "$LIVE_URL/main.dart.js?cb=$TIMESTAMP" 2>/dev/null | grep -o 'PH-REV-[0-9]*' | head -n 1 || echo "")

if [ -n "$LIVE_JS_TAG" ]; then
    echo -e "  • Actual Tag on Cloudflare Server : ${GREEN}#$LIVE_JS_TAG${NC}"
else
    echo -e "  • Actual Tag on Cloudflare Server : ${YELLOW}Tag not directly plain-text in JS (Minified)${NC}"
fi
echo ""

# ----------------------------------------------------------------------
# 4. FINAL VERDICT & DIAGNOSIS
# ----------------------------------------------------------------------
echo -e "${CYAN}----------------------------------------------------------------${NC}"
echo -e "${CYAN}  [4/4] 📋 DIAGNOSIS & REASON SUMMARY                           ${NC}"
echo -e "${CYAN}----------------------------------------------------------------${NC}"

if echo "$DEPLOY_OUTPUT" | grep -qi "Production"; then
    echo -e "${GREEN}✔ Wrangler status confirms: Latest build is deployed to PRODUCTION.${NC}"
else
    echo -e "${YELLOW}⚠ Note: Wrangler might be deploying to a Preview URL instead of Production branch.${NC}"
fi

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${BLUE}                     NEXT ACTION RECOMMENDATION                 ${NC}"
echo -e "${BLUE}================================================================${NC}"
echo -e "1. If Cloudflare has the latest deployment, but iPad still shows old screen:"
echo -e "   👉 Safari Settings -> Safari -> Advanced -> Website Data -> Remove 'pharoah-erp.pages.dev'"
echo -e "   👉 Or open Safari in a 'Private Tab' to instantly see the fresh code."
echo -e "${BLUE}================================================================${NC}\n"
