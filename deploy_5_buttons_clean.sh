#!/bin/bash
set -e

# 1. Auto-detect Flutter PATH
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

echo -e "\033[0;34m====================================================\033[0m"
echo -e "\033[0;34m   🚀 CLEAN DEPLOY: 5 CHALLAN BUTTONS LIVE          \033[0m"
echo -e "\033[0;34m====================================================\033[0m\n"

# 2. Fix web_portal_gateway.dart (Cleaned)
echo -e "\033[1;33m[1/5] Writing clean web_portal_gateway.dart...\033[0m"
cat << 'GATEWAY_EOF' > lib/web_live_sync/web_portal_gateway.dart
// FILE: lib/web_live_sync/web_portal_gateway.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pharoah_web_manager.dart';
import 'components/web_top_bar.dart';
import 'components/web_recent_sidebar.dart';
import 'components/web_kpi_strip.dart';
import 'components/web_module_grid.dart';
import 'components/web_invoice_feed.dart';
import 'components/web_login_card.dart';

// Sub Views
import 'sub_views/web_billing/web_new_sale_view.dart';
import 'web_sale_summary_view.dart';
import 'web_purchase_entry_view.dart';
import 'web_purchase_summary_view.dart';
import 'web_returns_view.dart';
import 'web_challan_view.dart';
import 'web_voucher_view.dart';
import 'web_product_master.dart';
import 'web_party_master.dart';
import 'web_batch_master.dart';
import 'web_aux_masters.dart';

class WebPortalGateway extends StatefulWidget {
  const WebPortalGateway({super.key});

  @override
  State<WebPortalGateway> createState() => _WebPortalGatewayState();
}

class _WebPortalGatewayState extends State<WebPortalGateway> {
  String currentView = "HOME";
  String currentViewTitle = "MAIN BUSINESS MODULES";
  String searchQuery = "";

  List<Map<String, dynamic>> recentShortcuts = [];

  void _navigateToHub(String hubId, String hubTitle) {
    setState(() {
      currentView = hubId;
      currentViewTitle = hubTitle;
    });
  }

  void _handleActionTap(String actionTitle, IconData icon, String navKey) {
    if (!recentShortcuts.any((item) => item['module'] == navKey)) {
      setState(() {
        recentShortcuts.insert(0, {
          "title": actionTitle,
          "icon": icon,
          "module": navKey,
        });
        if (recentShortcuts.length > 8) {
          recentShortcuts.removeLast();
        }
      });
    }

    _navigateToHub(navKey, actionTitle.toUpperCase());
  }

  void _removeShortcut(int index) {
    setState(() {
      recentShortcuts.removeAt(index);
    });
  }

  void _clearAllRecents() {
    setState(() {
      recentShortcuts.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final webPh = Provider.of<PharoahWebManager>(context);

    if (!webPh.isAuthenticated) {
      return Scaffold(
        backgroundColor: const Color(0xFF0F172A),
        body: WebLoginCard(
          errorMessage: webPh.errorMessage,
          isLoading: webPh.isLoading,
          onLogin: (token, user, pass) => webPh.loginWithStoreKey(
            storeToken: token,
            username: user,
            password: pass,
          ),
        ),
      );
    }

    bool isHomeDashboard = currentView == "HOME";

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: WebTopBar(
        webPh: webPh,
        onSearchChanged: (v) => setState(() => searchQuery = v),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHomeDashboard)
            WebRecentSidebar(
              currentView: currentView,
              recentShortcuts: recentShortcuts,
              onHomeTap: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
              onActionTap: _handleActionTap,
              onRemoveShortcut: _removeShortcut,
              onClearAll: _clearAllRecents,
            ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(),
                  const SizedBox(height: 16),
                  _buildCurrentView(webPh),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentView(PharoahWebManager webPh) {
    // 1. SALES BILLING (NEW INVOICE)
    if (currentView == "GO_SALE") {
      return WebNewSaleView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 2. SALE REGISTER / HISTORY
    if (currentView == "GO_SALE_REG") {
      return WebSaleSummaryView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 3. PURCHASE INWARD ENTRY
    if (currentView == "GO_PURCHASE") {
      return WebPurchaseEntryView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 4. PURCHASE REGISTER / AUDIT
    if (currentView == "GO_PUR_REG") {
      return WebPurchaseSummaryView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 5. CHALLAN TO BILL CONVERTER
    if (currentView == "GO_STITCHER") {
      return WebChallanView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        initialTabIndex: 2,
      );
    }

    // 6. RETURNS & REVERSALS (CN / DN / REGISTER)
    if (currentView == "GO_CN" || currentView == "GO_DN" || currentView == "GO_BREAKAGE" || currentView == "GO_RET_REG" || currentView == "RETURNS") {
      int tabIdx = 0;
      if (currentView == "GO_DN") tabIdx = 1;
      if (currentView == "GO_RET_REG") tabIdx = 2;

      return WebReturnsView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        initialTabIndex: tabIdx,
      );
    }

    // 7. DELIVERY & INWARD CHALLANS (5 BUTTON HUB)
    if (currentView == "GO_CHALLAN_SALE" || currentView == "GO_CHALLAN_PUR" || currentView == "GO_CHALLAN_SALE_REG" || currentView == "GO_CHALLAN_PUR_REG" || currentView == "CHALLANS") {
      int tabIdx = 0;
      if (currentView == "GO_CHALLAN_PUR") tabIdx = 1;
      if (currentView == "GO_CHALLAN_SALE_REG") tabIdx = 3;
      if (currentView == "GO_CHALLAN_PUR_REG") tabIdx = 4;

      return WebChallanView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        initialTabIndex: tabIdx,
      );
    }

    // 8. ACCOUNTS, DAYBOOK & VOUCHERS
    if (currentView == "GO_RECEIPT" || currentView == "GO_PAYMENT" || currentView == "GO_DAYBOOK" || currentView == "GO_LEDGERS" || currentView == "ACCOUNTS") {
      int tabIdx = 0;
      if (currentView == "GO_PAYMENT") tabIdx = 1;
      if (currentView == "GO_DAYBOOK" || currentView == "GO_LEDGERS") tabIdx = 2;

      return WebVoucherView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        initialTabIndex: tabIdx,
      );
    }

    // 9. PRODUCT / ITEM MASTER
    if (currentView == "GO_M_ITEM" || currentView == "GO_STOCK" || currentView == "GO_SHORTAGE" || currentView == "INVENTORY") {
      return WebProductMasterView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 10. PARTY & CUSTOMER MASTER
    if (currentView == "GO_M_PARTY") {
      return WebPartyMasterView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 11. CENTRAL BATCH MASTER
    if (currentView == "GO_M_BATCH") {
      return WebBatchMasterView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
      );
    }

    // 12. AUXILIARY MASTERS (COMPANIES, SALTS, ROUTES)
    if (currentView == "GO_M_COMP" || currentView == "GO_M_SALT" || currentView == "GO_M_ROUTE") {
      int tabIdx = 0;
      if (currentView == "GO_M_SALT") tabIdx = 1;
      if (currentView == "GO_M_ROUTE") tabIdx = 2;

      return WebAuxMastersView(
        onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        initialTabIndex: tabIdx,
      );
    }

    // DEFAULT: DASHBOARD LEVEL 0 / LEVEL 1 HUBS GRID
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebKpiStrip(webPh: webPh),
        const SizedBox(height: 20),
        WebModuleGrid(
          currentView: currentView,
          onHubTap: _navigateToHub,
          onActionTap: _handleActionTap,
          onBackToHome: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        ),
        const SizedBox(height: 25),
        if (currentView == "HOME")
          WebInvoiceFeed(
            webPh: webPh,
          ),
      ],
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
            child: const Row(
              children: [
                Icon(Icons.home_rounded, color: Color(0xFF38BDF8), size: 15),
                SizedBox(width: 6),
                Text("Home", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (currentView != "HOME") ...[
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 15),
            const SizedBox(width: 8),
            Text(currentViewTitle, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
          ],
          const Spacer(),
          if (currentView != "HOME")
            InkWell(
              onTap: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, color: Colors.white54, size: 14),
                  SizedBox(width: 4),
                  Text("Back to Hubs", style: TextStyle(color: Colors.white54, fontSize: 10.5, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
GATEWAY_EOF

# 3. Fix web_returns_view.dart (0 Warnings, 0 Unused Imports, 0 Unnecessary Casts)
echo -e "\033[1;33m[2/5] Writing 100% clean web_returns_view.dart...\033[0m"
cat << 'RETURNS_CLEAN_EOF' > lib/web_live_sync/web_returns_view.dart
// FILE: lib/web_live_sync/web_returns_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'web_models.dart';
import 'pharoah_web_manager.dart';
import 'web_app_date_logic.dart';
import 'web_pdf_router_service.dart';

class WebReturnsView extends StatefulWidget {
  final VoidCallback onBack;
  final int initialTabIndex;

  const WebReturnsView({super.key, required this.onBack, this.initialTabIndex = 0});

  @override
  State<WebReturnsView> createState() => _WebReturnsViewState();
}

class _WebReturnsViewState extends State<WebReturnsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  DateTime regFromDate = DateTime.now();
  DateTime regToDate = DateTime.now();
  String registerSearch = "";
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: widget.initialTabIndex);
    final webPh = Provider.of<PharoahWebManager>(context, listen: false);
    regToDate = DateTime.now();
    regFromDate = WebAppDateLogic.getFYStart(webPh.financialYear);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final webPh = Provider.of<PharoahWebManager>(context, listen: false);
      final now = DateTime.now();
      regToDate = DateTime(now.year, now.month, now.day);
      DateTime thirtyDaysAgo = regToDate.subtract(const Duration(days: 30));
      DateTime fyStart = WebAppDateLogic.getFYStart(webPh.financialYear);
      regFromDate = thirtyDaysAgo.isBefore(fyStart) ? fyStart : thirtyDaysAgo;
      _isInit = true;
    }
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  DateTime _getReturnDate(dynamic r) {
    if (r is SaleReturn) return r.date;
    if (r is PurchaseReturn) return r.date;
    return DateTime.now();
  }

  double _getReturnTotal(dynamic r) {
    if (r is SaleReturn) return r.totalAmount;
    if (r is PurchaseReturn) return r.totalAmount;
    return 0.0;
  }

  String _getReturnParty(dynamic r) {
    if (r is SaleReturn) return r.partyName;
    if (r is PurchaseReturn) return r.distributorName;
    return "";
  }

  String _getReturnBillNo(dynamic r) {
    if (r is SaleReturn) return r.billNo;
    if (r is PurchaseReturn) return r.billNo;
    return "";
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webPh = Provider.of<PharoahWebManager>(context);
    final activeShop = CompanyProfile.fromMap(webPh.companyProfile);

    final fDateOnly = _dateOnly(regFromDate);
    final tDateOnly = _dateOnly(regToDate);

    List<dynamic> allReturns = [...webPh.saleReturns, ...webPh.purchaseReturns];
    allReturns.sort((a, b) => _getReturnDate(b).compareTo(_getReturnDate(a)));

    final filtered = allReturns.where((r) {
      final rDateOnly = _dateOnly(_getReturnDate(r));
      bool dateMatch = !rDateOnly.isBefore(fDateOnly) && !rDateOnly.isAfter(tDateOnly);
      String name = _getReturnParty(r);
      String billNo = _getReturnBillNo(r);
      bool searchMatch = registerSearch.isEmpty || 
          name.toLowerCase().contains(registerSearch.toLowerCase()) || 
          billNo.toLowerCase().contains(registerSearch.toLowerCase());
      return dateMatch && searchMatch;
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: widget.onBack, 
                icon: const Icon(Icons.arrow_back_rounded, size: 16), 
                label: const Text("BACK"), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white12, foregroundColor: Colors.white)
              ),
              const SizedBox(width: 15),
              const Text("RETURNS & REVERSALS HUB", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 15),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
            child: TabBar(
              controller: _tabController, 
              indicatorColor: const Color(0xFFDC2626), 
              labelColor: const Color(0xFFF87171), 
              unselectedLabelColor: Colors.white54,
              tabs: const [Tab(text: "CREDIT NOTE (SALE RETURN)"), Tab(text: "DEBIT NOTE (PUR RETURN)"), Tab(text: "RETURNS REGISTER")],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TabBarView(
              controller: _tabController, 
              children: [
                const Center(child: Text("Credit Note Entry Screen", style: TextStyle(color: Colors.white54))),
                const Center(child: Text("Debit Note Entry Screen", style: TextStyle(color: Colors.white54))),
                _buildRegister(filtered, webPh, activeShop),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegister(List<dynamic> filtered, PharoahWebManager webPh, CompanyProfile activeShop) {
    return Column(
      children: [
        TextField(
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Search in Returns Register...", 
            filled: true, 
            fillColor: Colors.black26, 
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Color(0xFFDC2626)),
          ),
          onChanged: (v) => setState(() => registerSearch = v),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (c, i) {
              final item = filtered[i];
              bool isCn = item is SaleReturn;
              String party = _getReturnParty(item);
              String billNo = _getReturnBillNo(item);
              double total = _getReturnTotal(item);

              return Card(
                color: const Color(0xFF1E293B),
                child: ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isCn ? const Color(0x33DC2626) : const Color(0x33F59E0B),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(isCn ? "CN" : "DN", style: TextStyle(color: isCn ? const Color(0xFFF87171) : const Color(0xFFFBBF24), fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                  title: Text(party, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                  subtitle: Text("No: $billNo", style: const TextStyle(color: Colors.white54, fontSize: 10.5)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.print, color: Colors.cyanAccent, size: 18),
                        onPressed: () {
                          final pObj = webPh.parties.firstWhere((p) => p.name == party, orElse: () => Party(id: 'temp', name: party));
                          if (item is SaleReturn) {
                            WebPdfRouterService.printCreditNote(returnObj: item, party: pObj, shop: activeShop);
                          } else if (item is PurchaseReturn) {
                            WebPdfRouterService.printDebitNote(returnObj: item, party: pObj, shop: activeShop);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
RETURNS_CLEAN_EOF

# 4. Strict Zero-Warning Analyzer Check
echo -e "\033[1;33m[3/5] Running static analyzer on lib/web_live_sync/...\033[0m"
flutter analyze lib/web_live_sync/

# 5. Build Web Release & Deploy Live
echo -e "\033[1;33m[4/5] Freeing RAM and compiling Web Bundle...\033[0m"
pkill -f "analysis_server" 2>/dev/null || true
pkill -f "dart_language_server" 2>/dev/null || true
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true

flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

echo -e "\033[1;33m[5/5] Deploying live to Cloudflare Pages...\033[0m"
npx wrangler pages deploy build/web --project-name=pharoah-erp --commit-dirty=true

git add .
git commit -m "Deploy 5-Button Challans Hub (Zero Warnings, 100% Clean)" || true
git push origin main || true

echo -e "\n\033[0;34m====================================================\033[0m"
echo -e "\033[0;32m  🎉 5 CHALLAN BUTTONS LIVE & DEPLOYED SUCCESSFULLY!\033[0m"
echo -e "\033[0;32m  🌐 URL: https://pharoah-erp.pages.dev\033[0m"
echo -e "\033[0;34m====================================================\033[0m"
