#!/bin/bash
set -e

# 1. Flutter PATH Auto-Detect
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

echo -e "\033[0;34m================================================================\033[0m"
echo -e "\033[0;34m   🔐 CLOUDFLARE AUTHENTICATION & LIVE DEPLOYMENT               \033[0m"
echo -e "\033[0;34m================================================================\033[0m\n"

# 2. Check and Perform Cloudflare Login
echo -e "\033[1;33m[1/4] Authenticating with Cloudflare Account...\033[0m"
echo -e "\033[0;36m👉 नीचे दिए गए लिंक पर क्लिक करें या कॉपी करके ब्राउज़र में Allow करें:\033[0m\n"

npx wrangler login

echo -e "\n\033[0;32m✔ Cloudflare Login Verified!\033[0m\n"

# 3. Clean RAM and Compile Fresh Web Workstation
echo -e "\033[1;33m[2/4] Compiling Fresh Web Workstation with 5 Challan Buttons...\033[0m"
pkill -f "analysis_server" 2>/dev/null || true
pkill -f "dart_language_server" 2>/dev/null || true
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true
rm -rf build/web

flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

echo -e "  \033[0;32m✔ Web compilation successful in build/web!\033[0m\n"

# 4. Upload Direct to Cloudflare Pages
echo -e "\033[1;33m[3/4] Uploading build directly to Cloudflare Pages (Production)...\033[0m"
npx wrangler pages deploy build/web --project-name=pharoah-erp --branch=main --commit-dirty=true

# 5. Git Commit & Push
echo -e "\n\033[1;33m[4/4] Syncing to Git Remote...\033[0m"
git add .
git commit -m "Deploy Clean 5-Button Challans Hub to Cloudflare Production" || true
git push origin main || true

echo -e "\n\033[0;34m================================================================\033[0m"
echo -e "\033[0;32m  🎉 DEPLOYED LIVE TO PRODUCTION SUCCESSFULLY!\033[0m"
echo -e "\033[0;32m  🌐 URL: https://pharoah-erp.pages.dev\033[0m"
echo -e "\033[0;34m================================================================\033[0m\n"
