#!/bin/bash
set -e

# 1. Flutter PATH सेट करना
export PATH="$HOME/flutter/bin:$PATH"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   🚀 PHAROAH ERP WEB - LIVE DEPLOYMENT             ${NC}"
echo -e "${BLUE}====================================================${NC}\n"

# 2. बैकग्राउंड प्रोसेसेस बंद करके RAM क्लीन करना (Codespaces Safety)
echo -e "${YELLOW}[1/5] Freeing Codespaces RAM & killing background locks...${NC}"
pkill -f "analysis_server" 2>/dev/null || true
pkill -f "dart_language_server" 2>/dev/null || true
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true

# 3. पुराना बिल्ड कैशे हटाना
echo -e "${YELLOW}[2/5] Cleaning old build cache...${NC}"
rm -rf build/web

# 4. वेब फाइलों का स्टैटिक एनालिसिस चेक (Strict 0-Error Check)
echo -e "${YELLOW}[3/5] Verifying Web Modules (lib/web_live_sync/)...${NC}"
flutter analyze lib/web_live_sync/

if [ $? -ne 0 ]; then
    echo -e "\n${RED}✖ Analyzer error detected in web files!${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Zero errors found in Web Modules!${NC}\n"

# 5. प्रोडक्शन वेब बंडल कंपाइल करना (RAM-Optimized O1 Mode)
echo -e "${YELLOW}[4/5] Compiling Production Web App...${NC}"
flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

if [ ! -f "build/web/main.dart.js" ]; then
    echo -e "\n${RED}✖ Web build failed!${NC}"
    exit 1
fi
echo -e "  ${GREEN}✔ Web compilation SUCCESSFUL!${NC}\n"

# 6. Cloudflare Pages पर डायरेक्ट अपलोड & Git सिंक
echo -e "${YELLOW}[5/5] Deploying to Cloudflare Pages & Git Sync...${NC}"
npx wrangler pages deploy build/web --project-name=pharoah-erp --commit-dirty=true

git add .
git commit -m "Deploy Live Web Workstation #PH-REV-130" || true
git push origin main || true

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}  🎉 DEPLOYED LIVE SUCCESSFULLY!${NC}"
echo -e "${GREEN}  🌐 URL: https://pharoah-erp.pages.dev${NC}"
echo -e "${BLUE}====================================================${NC}"
