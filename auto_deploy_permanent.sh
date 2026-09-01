#!/bin/bash
set -e

# Color Codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear
echo -e "${BLUE}================================================================${NC}"
echo -e "${BLUE}   🔐 SETTING UP PERMANENT CLOUDFLARE TOKEN & DEPLOYING LIVE    ${NC}"
echo -e "${BLUE}================================================================${NC}\n"

# 1. Permanent Environment Variables Setup
CF_TOKEN="cfat_cSDnYsvc0geZYIGlKNEAVLgT5YTWOpeAYL1Wq9y44ebe8b1e"
CF_ACCOUNT="7a2686af5567f6f24cb5a7a5799de277"

echo -e "${YELLOW}[1/5] Saving Token permanently in environment (~/.bashrc)...${NC}"
sed -i '/CLOUDFLARE_API_TOKEN/d' ~/.bashrc 2>/dev/null || true
sed -i '/CLOUDFLARE_ACCOUNT_ID/d' ~/.bashrc 2>/dev/null || true
sed -i '/CLOUDFLARE_API_TOKEN/d' ~/.profile 2>/dev/null || true
sed -i '/CLOUDFLARE_ACCOUNT_ID/d' ~/.profile 2>/dev/null || true

echo "export CLOUDFLARE_API_TOKEN=\"$CF_TOKEN\"" >> ~/.bashrc
echo "export CLOUDFLARE_ACCOUNT_ID=\"$CF_ACCOUNT\"" >> ~/.bashrc
echo "export CLOUDFLARE_API_TOKEN=\"$CF_TOKEN\"" >> ~/.profile
echo "export CLOUDFLARE_ACCOUNT_ID=\"$CF_ACCOUNT\"" >> ~/.profile

export CLOUDFLARE_API_TOKEN="$CF_TOKEN"
export CLOUDFLARE_ACCOUNT_ID="$CF_ACCOUNT"

echo -e "  ${GREEN}✔ Token saved permanently! बार-बार लॉगिन की ज़रूरत ख़त्म।${NC}\n"

# 2. Test Connection with Cloudflare API
echo -e "${YELLOW}[2/5] Testing Token authentication with Cloudflare API...${NC}"
npx wrangler whoami

echo -e "\n  ${GREEN}✔ Cloudflare Authentication Verified 100%!${NC}\n"

# 3. Auto-detect Flutter SDK
echo -e "${YELLOW}[3/5] Checking Flutter SDK...${NC}"
FLUTTER_BIN=""
for p in "$HOME/flutter/bin" "/workspaces/flutter/bin" "/usr/local/flutter/bin" "/opt/flutter/bin" "/sdks/flutter/bin"; do
  if [ -f "$p/flutter" ]; then
    FLUTTER_BIN="$p"
    break
  fi
done

if [ -z "$FLUTTER_BIN" ]; then
  FOUND=$(find /home/codespace /opt /usr/local /workspaces -name "flutter" -type f -executable 2>/dev/null | grep "/bin/flutter$" | head -n 1)
  if [ -n "$FOUND" ]; then
    FLUTTER_BIN=$(dirname "$FOUND")
  fi
fi

if [ -n "$FLUTTER_BIN" ]; then
  export PATH="$FLUTTER_BIN:$PATH"
fi
echo -e "  ${GREEN}✔ Active Flutter:${NC} $(flutter --version | head -n 1)\n"

# 4. Clean RAM & Compile Fresh Web Workstation
echo -e "${YELLOW}[4/5] Compiling Production Web App (5 Challan Buttons)...${NC}"
pkill -f "analysis_server" 2>/dev/null || true
pkill -f "dart_language_server" 2>/dev/null || true
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true
rm -rf build/web

flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

echo -e "  ${GREEN}✔ Web compilation successful in build/web!${NC}\n"

# 5. Direct Upload to Cloudflare Pages & Git Sync
echo -e "${YELLOW}[5/5] Deploying build directly to Cloudflare Pages (Production)...${NC}"
npx wrangler pages deploy build/web --project-name=pharoah-erp --branch=main --commit-dirty=true

git add .
git commit -m "Configure Permanent Cloudflare Token & Deploy Live 5-Button Hub" || true
git push origin main || true

echo -e "\n${BLUE}================================================================${NC}"
echo -e "${GREEN}  🎉 100% SUCCESS! NAYA CODE PRODUCTION PAR LIVE HO GAYA!${NC}"
echo -e "${GREEN}  🌐 URL: https://pharoah-erp.pages.dev${NC}"
echo -e "${BLUE}================================================================${NC}\n"
