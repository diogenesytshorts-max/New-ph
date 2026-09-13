#!/bin/bash
set -e

export PATH="$HOME/flutter/bin:$PATH"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}====================================================${NC}"
echo -e "${BLUE}   📱 DEPLOYING RESPONSIVE WEB ENGINE (#REV-131)   ${NC}"
echo -e "${BLUE}====================================================${NC}\n"

# 1. Update web/index.html with Zoom-Enabled & Responsive Viewport
echo -e "${YELLOW}[1/9] Updating web/index.html for Smooth Viewport & Pinch-to-Zoom...${NC}"
cat << 'HTML_EOF' > web/index.html
<!DOCTYPE html>
<html>
<head>
  <base href="$FLUTTER_BASE_HREF">
  <meta charset="UTF-8">
  <meta content="IE=Edge" http-equiv="X-UA-Compatible">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=5.0, user-scalable=yes">
  <meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate, max-age=0">
  <meta http-equiv="Pragma" content="no-cache">
  <meta http-equiv="Expires" content="0">
  <title>Pharoah ERP Web Workstation</title>
  <link rel="manifest" href="manifest.json">
</head>
<body style="background-color: #0F172A; margin: 0; padding: 0;">
  <script>
    if ('serviceWorker' in navigator) {
      navigator.serviceWorker.getRegistrations().then(function(registrations) {
        for (let registration of registrations) {
          registration.unregister();
        }
      });
    }
    if ('caches' in window) {
      caches.keys().then(function(names) {
        for (let name of names) {
          caches.delete(name);
        }
      });
    }
    var script = document.createElement('script');
    script.src = 'flutter_bootstrap.js?v=' + new Date().getTime();
    script.async = true;
    document.body.appendChild(script);
  </script>
</body>
</html>
HTML_EOF

# 2. Update Top Bar with Responsive Wrapping & #PH-REV-131 Badge
echo -e "${YELLOW}[2/9] Updating web_top_bar.dart...${NC}"
cat << 'TOPBAR_EOF' > lib/web_live_sync/components/web_top_bar.dart
// FILE: lib/web_live_sync/components/web_top_bar.dart

import 'package:flutter/material.dart';
import '../pharoah_web_manager.dart';

class WebTopBar extends StatelessWidget implements PreferredSizeWidget {
  final PharoahWebManager webPh;
  final ValueChanged<String>? onSearchChanged;

  const WebTopBar({
    super.key,
    required this.webPh,
    this.onSearchChanged,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    bool isTight = MediaQuery.of(context).size.width < 700;

    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0x332563EB),
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: const Icon(Icons.storefront_rounded, color: Color(0xFF38BDF8), size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                webPh.companyName.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Text(
                    "FY: ${webPh.financialYear}",
                    style: const TextStyle(
                      fontSize: 9,
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0x2610B981),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.greenAccent, width: 0.5),
                    ),
                    child: const Text(
                      "#PH-REV-131 (RESPONSIVE)",
                      style: TextStyle(color: Colors.greenAccent, fontSize: 7.5, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 12),
          if (!isTight)
            Expanded(
              child: Container(
                height: 36,
                constraints: const BoxConstraints(maxWidth: 340),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white12),
                ),
                child: TextField(
                  onChanged: onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 11.5),
                  decoration: const InputDecoration(
                    hintText: "Search Medicines, Customers...",
                    hintStyle: TextStyle(color: Colors.white38, fontSize: 10.5),
                    prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 16),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 9),
                  ),
                ),
              ),
            )
          else
            const Spacer(),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Colors.white70, size: 20),
            tooltip: "Refresh Live Cloud",
            onPressed: () {
              webPh.refreshStoreData();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("🔄 Live Cloud Database Refreshed!"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
            tooltip: "Sign Out",
            onPressed: () => _confirmSignOut(context, webPh),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, PharoahWebManager webPh) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.white10),
        ),
        title: const Text("Sign Out Workstation?", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        content: const Text(
          "Are you sure you want to disconnect from this store workstation?",
          style: TextStyle(color: Colors.white70, fontSize: 12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(c);
              webPh.signOut();
            },
            child: const Text("SIGN OUT", style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
TOPBAR_EOF

# 3. Update web_kpi_strip.dart for Auto-Wrapping Responsive Grid
echo -e "${YELLOW}[3/9] Updating web_kpi_strip.dart with dynamic layout...${NC}"
cat << 'KPI_EOF' > lib/web_live_sync/components/web_kpi_strip.dart
// FILE: lib/web_live_sync/components/web_kpi_strip.dart

import 'package:flutter/material.dart';
import '../pharoah_web_manager.dart';

class WebKpiStrip extends StatelessWidget {
  final PharoahWebManager webPh;

  const WebKpiStrip({super.key, required this.webPh});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    double todaySales = 0.0;
    int todaySalesCount = 0;
    for (var s in webPh.sales) {
      if (s.date.year == now.year && s.date.month == now.month && s.date.day == now.day && s.status == "Active") {
        todaySales += s.totalAmount;
        todaySalesCount++;
      }
    }

    double todayPurchases = 0.0;
    int todayPurCount = 0;
    for (var p in webPh.purchases) {
      if (p.date.year == now.year && p.date.month == now.month && p.date.day == now.day) {
        todayPurchases += p.totalAmount;
        todayPurCount++;
      }
    }

    double totalStockVal = 0.0;
    for (var m in webPh.medicines) {
      totalStockVal += (m.stock * m.purRate);
    }

    double totalOutstanding = 0.0;
    int debtorsCount = 0;
    for (var p in webPh.parties) {
      if (p.opBal > 0 && p.group == "Sundry Debtors") {
        totalOutstanding += p.opBal;
        debtorsCount++;
      }
    }

    String salesDisplay = todaySales > 0 ? "₹${todaySales.toStringAsFixed(0)}" : (webPh.sales.isNotEmpty ? "₹${_totalSales(webPh).toStringAsFixed(0)}" : "₹0");
    String salesSub = todaySalesCount > 0 ? "$todaySalesCount Bills Today" : "${webPh.sales.length} Total Bills";

    String purDisplay = todayPurchases > 0 ? "₹${todayPurchases.toStringAsFixed(0)}" : (webPh.purchases.isNotEmpty ? "₹${_totalPur(webPh).toStringAsFixed(0)}" : "₹0");
    String purSub = todayPurCount > 0 ? "$todayPurCount Inwards Today" : "${webPh.purchases.length} Total Inwards";

    String stockDisplay = totalStockVal > 0 ? "₹${totalStockVal.toStringAsFixed(0)}" : "${webPh.medicines.length} Items";
    String stockSub = "${webPh.medicines.length} Catalog Items";

    String outDisplay = totalOutstanding > 0 ? "₹${totalOutstanding.toStringAsFixed(0)}" : "${webPh.parties.length} Parties";
    String outSub = "$debtorsCount Debtors";

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 950;
        bool isMedium = constraints.maxWidth > 550;

        if (isWide) {
          return Row(
            children: [
              Expanded(child: _kpiCard("TODAY SALES", salesDisplay, salesSub, Icons.trending_up_rounded, const Color(0xFF10B981))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard("TODAY PURCHASES", purDisplay, purSub, Icons.shopping_cart_rounded, const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard("STOCK VALUATION", stockDisplay, stockSub, Icons.inventory_2_rounded, const Color(0xFF06B6D4))),
              const SizedBox(width: 12),
              Expanded(child: _kpiCard("OUTSTANDING", outDisplay, outSub, Icons.account_balance_wallet_rounded, const Color(0xFF8B5CF6))),
            ],
          );
        } else if (isMedium) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(child: _kpiCard("TODAY SALES", salesDisplay, salesSub, Icons.trending_up_rounded, const Color(0xFF10B981))),
                  const SizedBox(width: 10),
                  Expanded(child: _kpiCard("TODAY PURCHASES", purDisplay, purSub, Icons.shopping_cart_rounded, const Color(0xFFF59E0B))),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _kpiCard("STOCK VALUATION", stockDisplay, stockSub, Icons.inventory_2_rounded, const Color(0xFF06B6D4))),
                  const SizedBox(width: 10),
                  Expanded(child: _kpiCard("OUTSTANDING", outDisplay, outSub, Icons.account_balance_wallet_rounded, const Color(0xFF8B5CF6))),
                ],
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _kpiCard("TODAY SALES", salesDisplay, salesSub, Icons.trending_up_rounded, const Color(0xFF10B981)),
              const SizedBox(height: 8),
              _kpiCard("TODAY PURCHASES", purDisplay, purSub, Icons.shopping_cart_rounded, const Color(0xFFF59E0B)),
              const SizedBox(height: 8),
              _kpiCard("STOCK VALUATION", stockDisplay, stockSub, Icons.inventory_2_rounded, const Color(0xFF06B6D4)),
              const SizedBox(height: 8),
              _kpiCard("OUTSTANDING", outDisplay, outSub, Icons.account_balance_wallet_rounded, const Color(0xFF8B5CF6)),
            ],
          );
        }
      },
    );
  }

  double _totalSales(PharoahWebManager ph) => ph.sales.where((s) => s.status == "Active").fold(0.0, (sum, s) => sum + s.totalAmount);
  double _totalPur(PharoahWebManager ph) => ph.purchases.fold(0.0, (sum, p) => sum + p.totalAmount);

  Widget _kpiCard(String title, String value, String sub, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19243B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(90), width: 1.2),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              Icon(icon, color: color, size: 16),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(sub, style: const TextStyle(color: Colors.white38, fontSize: 8.5)),
        ],
      ),
    );
  }
}
KPI_EOF

# 4. Update web_portal_gateway.dart with Adaptive Layout on iPad
echo -e "${YELLOW}[4/9] Updating web_portal_gateway.dart for Auto-Adapting iPad screen...${NC}"
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
import 'web_challan_stitcher_wizard.dart';
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

    final screenWidth = MediaQuery.of(context).size.width;
    bool isHomeDashboard = currentView == "HOME";
    bool showSidebar = isHomeDashboard && screenWidth > 900;

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      appBar: WebTopBar(
        webPh: webPh,
        onSearchChanged: (v) => setState(() => searchQuery = v),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (showSidebar)
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
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth > 600 ? 18.0 : 10.0,
                vertical: 14.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBreadcrumbs(),
                  const SizedBox(height: 14),
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
    if (currentView == "GO_SALE") {
      return WebNewSaleView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_SALE_REG") {
      return WebSaleSummaryView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_PURCHASE") {
      return WebPurchaseEntryView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_PUR_REG") {
      return WebPurchaseSummaryView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_STITCHER") {
      return WebChallanStitcherWizard(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_CN" || currentView == "GO_DN" || currentView == "GO_BREAKAGE" || currentView == "GO_RET_REG" || currentView == "RETURNS") {
      int tabIdx = 0;
      if (currentView == "GO_DN") tabIdx = 1;
      if (currentView == "GO_RET_REG") tabIdx = 2;
      return WebReturnsView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"), initialTabIndex: tabIdx);
    }
    if (currentView == "GO_CHALLAN_SALE" || currentView == "GO_CHALLAN_PUR" || currentView == "GO_CHALLAN_SALE_REG" || currentView == "GO_CHALLAN_PUR_REG" || currentView == "CHALLANS") {
      int tabIdx = 0;
      if (currentView == "GO_CHALLAN_PUR" || currentView == "GO_CHALLAN_PUR_REG") tabIdx = 1;
      return WebChallanView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"), initialTabIndex: tabIdx);
    }
    if (currentView == "GO_RECEIPT" || currentView == "GO_PAYMENT" || currentView == "GO_DAYBOOK" || currentView == "GO_LEDGERS" || currentView == "ACCOUNTS") {
      int tabIdx = 0;
      if (currentView == "GO_PAYMENT") tabIdx = 1;
      if (currentView == "GO_DAYBOOK" || currentView == "GO_LEDGERS") tabIdx = 2;
      return WebVoucherView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"), initialTabIndex: tabIdx);
    }
    if (currentView == "GO_M_ITEM" || currentView == "GO_STOCK" || currentView == "GO_SHORTAGE" || currentView == "INVENTORY") {
      return WebProductMasterView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_M_PARTY") {
      return WebPartyMasterView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_M_BATCH") {
      return WebBatchMasterView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"));
    }
    if (currentView == "GO_M_COMP" || currentView == "GO_M_SALT" || currentView == "GO_M_ROUTE") {
      int tabIdx = 0;
      if (currentView == "GO_M_SALT") tabIdx = 1;
      if (currentView == "GO_M_ROUTE") tabIdx = 2;
      return WebAuxMastersView(onBack: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"), initialTabIndex: tabIdx);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WebKpiStrip(webPh: webPh),
        const SizedBox(height: 18),
        WebModuleGrid(
          currentView: currentView,
          onHubTap: _navigateToHub,
          onActionTap: _handleActionTap,
          onBackToHome: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
        ),
        const SizedBox(height: 20),
        if (currentView == "HOME")
          WebInvoiceFeed(webPh: webPh),
      ],
    );
  }

  Widget _buildBreadcrumbs() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                Icon(Icons.home_rounded, color: Color(0xFF38BDF8), size: 14),
                SizedBox(width: 5),
                Text("Home", style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (currentView != "HOME") ...[
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 14),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                currentViewTitle,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          const Spacer(),
          if (currentView != "HOME")
            InkWell(
              onTap: () => _navigateToHub("HOME", "MAIN BUSINESS MODULES"),
              child: const Row(
                children: [
                  Icon(Icons.arrow_back_rounded, color: Colors.white54, size: 13),
                  SizedBox(width: 4),
                  Text("Back", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
GATEWAY_EOF

# 5. Update WebItemEntryCard for Fluid Screen Width Clamping (No fixed 720px)
echo -e "${YELLOW}[5/9] Updating web_item_entry_card.dart with fluid responsive modal width...${NC}"
cat << 'ITEMENTRY_EOF' > lib/web_live_sync/sub_views/web_billing/web_item_entry_card.dart
// FILE: lib/web_live_sync/sub_views/web_billing/web_item_entry_card.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import '../../web_models.dart';
import '../../web_expiry_master.dart';
import 'web_batch_lookup_dialog.dart';

class WebItemEntryCard extends StatefulWidget {
  final Medicine med;
  final int srNo;
  final String partyState;
  final String shopState;
  final List<BatchInfo> availableBatches;
  final BillItem? existingItem;
  final Function(BillItem) onAdd;
  final VoidCallback onCancel;
  final bool allowExpired;

  const WebItemEntryCard({
    super.key,
    required this.med,
    required this.srNo,
    required this.partyState,
    required this.shopState,
    required this.availableBatches,
    this.existingItem,
    required this.onAdd,
    required this.onCancel,
    this.allowExpired = false,
  });

  @override
  State<WebItemEntryCard> createState() => _WebItemEntryCardState();
}

class _WebItemEntryCardState extends State<WebItemEntryCard> {
  final batchC = TextEditingController();
  final expC = TextEditingController();
  final mrpC = TextEditingController();
  final rateC = TextEditingController();
  final rateCDiscC = TextEditingController(text: "0.0");
  final qtyC = TextEditingController(text: "1");
  final freeC = TextEditingController(text: "0");
  final gstC = TextEditingController();
  final normDiscC = TextEditingController(text: "0.0");
  final discAmtC = TextEditingController(text: "0.0");

  String selectedRateType = "A";

  @override
  void initState() {
    super.initState();
    _setupInitialData();
  }

  void _setupInitialData() {
    if (widget.existingItem != null) {
      final i = widget.existingItem!;
      batchC.text = i.batch;
      expC.text = i.exp;
      mrpC.text = i.mrp.toStringAsFixed(2);
      rateC.text = i.rate.toStringAsFixed(2);
      qtyC.text = i.qty.toInt().toString();
      freeC.text = i.freeQty.toInt().toString();
      gstC.text = i.gstRate.toString();
      selectedRateType = i.appliedRateType;
      rateCDiscC.text = i.rateCFormula.toString();
      normDiscC.text = i.discountPer.toString();
      _syncDiscount(true);
    } else {
      mrpC.text = widget.med.mrp.toStringAsFixed(2);
      gstC.text = widget.med.gst.toString();
      _updateRateLogic();
    }
  }

  void _calculateRateC() {
    double mrp = double.tryParse(mrpC.text) ?? 0.0;
    double gst = double.tryParse(gstC.text) ?? 0.0;
    double formulaDisc = double.tryParse(rateCDiscC.text) ?? 0.0;
    double baseTaxable = (mrp / (1 + (gst / 100)));
    double finalRate = baseTaxable - (baseTaxable * (formulaDisc / 100));
    rateC.text = finalRate.toStringAsFixed(2);
    _syncDiscount(true);
  }

  void _updateRateLogic() {
    if (selectedRateType == "C") {
      _calculateRateC();
    } else {
      rateC.text = (selectedRateType == "A" ? widget.med.rateA : widget.med.rateB).toStringAsFixed(2);
      _syncDiscount(true);
    }
  }

  void _syncDiscount(bool isPercentSource) {
    double q = double.tryParse(qtyC.text) ?? 0;
    double r = double.tryParse(rateC.text) ?? 0;
    double gross = q * r;
    if (gross <= 0) return;
    if (isPercentSource) {
      double p = double.tryParse(normDiscC.text) ?? 0;
      discAmtC.text = (gross * (p / 100)).toStringAsFixed(2);
    } else {
      double a = double.tryParse(discAmtC.text) ?? 0;
      normDiscC.text = ((a / gross) * 100).toStringAsFixed(2);
    }
    setState(() {});
  }

  void _formatExpiry(String val) {
    String text = val.replaceAll(RegExp(r'[^0-9]'), '');
    if (text.length >= 2 && !val.contains('/')) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    if (text.length > 5) text = text.substring(0, 5);
    if (expC.text != text) {
      expC.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }
    setState(() {});
  }

  Map<String, double> _calcTotals() {
    double q = double.tryParse(qtyC.text) ?? 0;
    double r = double.tryParse(rateC.text) ?? 0;
    double dAmt = double.tryParse(discAmtC.text) ?? 0;
    double g = double.tryParse(gstC.text) ?? 0;

    double gross = r * q;
    double taxable = gross - dAmt;
    double totalTax = taxable * (g / 100);
    bool isLocal = widget.shopState.trim().toLowerCase() == widget.partyState.trim().toLowerCase();

    return {
      'taxable': taxable,
      'cgst': isLocal ? totalTax / 2 : 0.0,
      'sgst': isLocal ? totalTax / 2 : 0.0,
      'igst': !isLocal ? totalTax : 0.0,
      'total': taxable + totalTax,
      'discountAmt': dAmt,
    };
  }

  void _openBatchLookup() async {
    final selected = await showDialog<dynamic>(
      context: context,
      barrierDismissible: true,
      builder: (context) => WebBatchLookupDialog(
        medicine: widget.med,
        batches: widget.availableBatches,
        prioritizeExpired: widget.allowExpired,
      ),
    );

    if (selected != null) {
      if (selected is BatchInfo) {
        setState(() {
          batchC.text = selected.batch;
          expC.text = selected.exp;
          mrpC.text = selected.mrp.toStringAsFixed(2);
          if (selectedRateType == "A") {
            rateC.text = selected.rateA.toStringAsFixed(2);
          } else if (selectedRateType == "B") {
            rateC.text = selected.rateB.toStringAsFixed(2);
          } else {
            rateC.text = selected.rateC.toStringAsFixed(2);
            rateCDiscC.text = selected.rateCFormula.toStringAsFixed(2);
          }
          _syncDiscount(true);
        });
      } else if (selected == "MANUAL") {
        setState(() {
          batchC.clear();
          expC.clear();
          mrpC.text = widget.med.mrp.toStringAsFixed(2);
          _updateRateLogic();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totals = _calcTotals();
    String expStr = expC.text.trim();
    final expStatus = WebExpiryMaster.getStatus(expStr);
    final statusColor = WebExpiryMaster.getStatusColor(expStr);
    final bool isSaleAllowed = widget.allowExpired || WebExpiryMaster.isSaleAllowed(expStr);

    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 740 ? 680.0 : (screenWidth * 0.94);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 18),
        child: Container(
          width: dialogWidth,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0x802563EB), width: 1.5),
            boxShadow: const [
              BoxShadow(color: Colors.black54, blurRadius: 25, offset: Offset(0, 10))
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF1E293B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0x332563EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.medication_rounded, color: Color(0xFF38BDF8), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "ITEM BILLING & BATCH CONFIG",
                            style: TextStyle(
                              color: Color(0xFF38BDF8),
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "${widget.srNo}. ${widget.med.name.toUpperCase()} (${widget.med.packing})",
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      style: IconButton.styleFrom(backgroundColor: Colors.white10),
                      icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white70),
                      onPressed: widget.onCancel,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 4,
                            child: _spaciousInput(
                              "BATCH NUMBER (CASE-SENSITIVE)",
                              batchC,
                              isHighlight: true,
                              suffix: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2563EB),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  elevation: 0,
                                ),
                                onPressed: _openBatchLookup,
                                icon: const Icon(Icons.layers_rounded, size: 14),
                                label: const Text("BATCHES", style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 3,
                            child: _spaciousInput(
                              "EXPIRY (MM/YY)",
                              expC,
                              isNum: true,
                              textColor: statusColor,
                              onChanged: _formatExpiry,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Text("RATE:", style: TextStyle(color: Colors.white54, fontSize: 9.5, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          _rateSegment("RATE A", selectedRateType == "A", () {
                            setState(() { selectedRateType = "A"; _updateRateLogic(); });
                          }),
                          const SizedBox(width: 6),
                          _rateSegment("RATE B", selectedRateType == "B", () {
                            setState(() { selectedRateType = "B"; _updateRateLogic(); });
                          }),
                          const SizedBox(width: 6),
                          _rateSegment("RATE C", selectedRateType == "C", () {
                            setState(() { selectedRateType = "C"; _updateRateLogic(); });
                          }),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          if (selectedRateType == "C") ...[
                            Expanded(
                              child: _spaciousInput("FORMULA DISC %", rateCDiscC, isNum: true, onChanged: (_) => _calculateRateC()),
                            ),
                            const SizedBox(width: 8),
                          ],
                          Expanded(
                            child: _spaciousInput("MRP ₹", mrpC, isNum: true, onChanged: (_) { if (selectedRateType == "C") _calculateRateC(); }),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _spaciousInput("UNIT RATE ₹", rateC, isNum: true, isReadOnly: selectedRateType == "C", isHighlight: selectedRateType != "C", onChanged: (_) => _syncDiscount(true)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _spaciousInput("GST %", gstC, isNum: true, isReadOnly: true),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _spaciousInput("QTY", qtyC, isNum: true, isHighlight: true, onChanged: (_) => _syncDiscount(true)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _spaciousInput("FREE", freeC, isNum: true),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _spaciousInput("DISC %", normDiscC, isNum: true, onChanged: (_) => _syncDiscount(true)),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _spaciousInput("DISC ₹", discAmtC, isNum: true, onChanged: (_) => _syncDiscount(false)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Taxable: ₹${totals['taxable']!.toStringAsFixed(2)} | GST: ₹${(totals['cgst']! + totals['sgst']! + totals['igst']!).toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "CGST: ₹${totals['cgst']!.toStringAsFixed(2)} | SGST: ₹${totals['sgst']!.toStringAsFixed(2)} | IGST: ₹${totals['igst']!.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text("ITEM TOTAL", style: TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold)),
                                Text(
                                  "₹${totals['total']!.toStringAsFixed(2)}",
                                  style: const TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaleAllowed ? const Color(0xFF2563EB) : Colors.red.shade900,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          onPressed: !isSaleAllowed || qtyC.text.isEmpty || qtyC.text == "0"
                              ? null
                              : () {
                                  double q = double.tryParse(qtyC.text) ?? 1;
                                  double freeQ = double.tryParse(freeC.text) ?? 0;
                                  double r = double.tryParse(rateC.text) ?? 0;

                                  widget.onAdd(BillItem(
                                    id: widget.existingItem?.id ?? DateTime.now().toString(),
                                    srNo: widget.srNo,
                                    medicineID: widget.med.id,
                                    name: widget.med.name,
                                    packing: widget.med.packing,
                                    batch: batchC.text.trim(),
                                    exp: expC.text.trim(),
                                    hsn: widget.med.hsnCode,
                                    mrp: double.tryParse(mrpC.text) ?? 0.0,
                                    qty: q,
                                    freeQty: freeQ,
                                    rate: r,
                                    gstRate: double.tryParse(gstC.text) ?? 0.0,
                                    cgst: totals['cgst']!,
                                    sgst: totals['sgst']!,
                                    igst: totals['igst']!,
                                    total: totals['total']!,
                                    discountRupees: totals['discountAmt']!,
                                    discountPer: double.tryParse(normDiscC.text) ?? 0.0,
                                    appliedRateType: selectedRateType,
                                    rateCFormula: double.tryParse(rateCDiscC.text) ?? 0.0,
                                    isBreakage: widget.allowExpired,
                                  ));
                                },
                          child: Text(
                            expStatus == ExpiryStatus.expired && !widget.allowExpired
                                ? "EXPIRED BATCH - SALE BLOCKED"
                                : (widget.existingItem != null ? "UPDATE INVOICE ITEM" : "CONFIRM & ADD TO INVOICE"),
                            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 0.5),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _spaciousInput(
    String label,
    TextEditingController ctrl, {
    bool isNum = false,
    bool isReadOnly = false,
    bool isHighlight = false,
    Color? textColor,
    Widget? suffix,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: isReadOnly ? Colors.black38 : (isHighlight ? const Color(0x332563EB) : Colors.black26),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isHighlight ? const Color(0xFF38BDF8) : Colors.white12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ctrl,
                  readOnly: isReadOnly,
                  onChanged: onChanged,
                  keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                  style: TextStyle(color: textColor ?? Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                    border: InputBorder.none,
                  ),
                ),
              ),
              if (suffix != null) suffix,
            ],
          ),
        ),
      ],
    );
  }

  Widget _rateSegment(String label, bool isSelected, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF2563EB) : Colors.black26,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: isSelected ? const Color(0xFF60A5FA) : Colors.white10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white54,
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
ITEMENTRY_EOF

# 6. Update quick_add_party_modal.dart (Dynamic Screen Clamped Width)
echo -e "${YELLOW}[6/9] Updating quick_add_party_modal.dart for responsive width...${NC}"
cat << 'PARTYMODAL_EOF' > lib/web_live_sync/sub_views/web_billing/quick_add_party_modal.dart
// FILE: lib/web_live_sync/sub_views/web_billing/quick_add_party_modal.dart

import 'package:flutter/material.dart';
import '../../web_models.dart';
import '../../pharoah_web_manager.dart';

class QuickAddPartyModal extends StatefulWidget {
  final PharoahWebManager webPh;
  final Function(Party newParty) onPartyCreated;

  const QuickAddPartyModal({
    super.key,
    required this.webPh,
    required this.onPartyCreated,
  });

  @override
  State<QuickAddPartyModal> createState() => _QuickAddPartyModalState();
}

class _QuickAddPartyModalState extends State<QuickAddPartyModal> {
  final nameC = TextEditingController();
  final phoneC = TextEditingController();
  final emailC = TextEditingController();
  final addressC = TextEditingController();
  final cityC = TextEditingController();
  final gstC = TextEditingController();
  final panC = TextEditingController();
  final dlC = TextEditingController();
  final dlExpC = TextEditingController();
  final opBalC = TextEditingController(text: "0.0");
  final creditLimitC = TextEditingController(text: "0.0");
  final creditDaysC = TextEditingController(text: "30");

  String selectedGroup = "Sundry Debtors";
  String selectedState = "Rajasthan";
  String selectedPriceLevel = "A";
  String selectedSeriesId = "";

  final List<String> accountGroups = [
    "Sundry Debtors",
    "Sundry Creditors",
    "Bank Accounts",
    "Cash in Hand",
    "Expenses",
  ];

  final List<String> states = [
    "Andhra Pradesh", "Assam", "Bihar", "Chhattisgarh", "Goa", "Gujarat", "Haryana",
    "Himachal Pradesh", "Jharkhand", "Karnataka", "Kerala", "Madhya Pradesh",
    "Maharashtra", "Manipur", "Meghalaya", "Mizoram", "Nagaland", "Odisha",
    "Punjab", "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
    "Uttar Pradesh", "Uttarakhand", "West Bengal", "Delhi",
  ];

  @override
  void initState() {
    super.initState();
    gstC.addListener(() {
      if (gstC.text.length >= 12) {
        String extPan = gstC.text.substring(2, 12).toUpperCase();
        if (panC.text != extPan) {
          panC.text = extPan;
        }
      }
    });
  }

  @override
  void dispose() {
    nameC.dispose();
    phoneC.dispose();
    emailC.dispose();
    addressC.dispose();
    cityC.dispose();
    gstC.dispose();
    panC.dispose();
    dlC.dispose();
    dlExpC.dispose();
    opBalC.dispose();
    creditLimitC.dispose();
    creditDaysC.dispose();
    super.dispose();
  }

  void _saveParty() {
    if (nameC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Firm / Customer Name is required!"), backgroundColor: Colors.orange),
      );
      return;
    }

    final newParty = Party(
      id: 'PARTY-WEB-${DateTime.now().millisecondsSinceEpoch}',
      name: nameC.text.trim().toUpperCase(),
      group: selectedGroup,
      phone: phoneC.text.trim(),
      email: emailC.text.trim().toLowerCase(),
      address: addressC.text.trim(),
      city: cityC.text.trim().toUpperCase(),
      state: selectedState,
      gst: gstC.text.trim().toUpperCase().isEmpty ? 'N/A' : gstC.text.trim().toUpperCase(),
      pan: panC.text.trim().toUpperCase(),
      dl: dlC.text.trim().toUpperCase().isEmpty ? 'N/A' : dlC.text.trim().toUpperCase(),
      dlExp: dlExpC.text.trim(),
      opBal: double.tryParse(opBalC.text) ?? 0.0,
      creditLimit: double.tryParse(creditLimitC.text) ?? 0.0,
      creditDays: int.tryParse(creditDaysC.text) ?? 30,
      priceLevel: selectedPriceLevel,
      defaultSeriesId: selectedSeriesId,
    );

    widget.webPh.addParty(newParty);
    Navigator.pop(context);
    widget.onPartyCreated(newParty);
  }

  @override
  Widget build(BuildContext context) {
    final activeSeries = widget.webPh.numberingSeries.where((s) => s.type == "SALE" && s.isActive).toList();
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 640 ? 600.0 : (screenWidth * 0.94);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white12),
      ),
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0x332563EB),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1_rounded, color: Color(0xFF38BDF8), size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            "QUICK CREATE CUSTOMER / PARTY",
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ipadInput("FIRM / CUSTOMER NAME *", nameC, Icons.business, isCaps: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ipadDropdown(
                      "ACCOUNT GROUP *",
                      selectedGroup,
                      accountGroups.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                      (v) => setState(() => selectedGroup = v!),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ipadDropdown(
                      "STATE (FOR GST)",
                      states.contains(selectedState) ? selectedState : "Rajasthan",
                      states.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      (v) => setState(() => selectedState = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("MOBILE NUMBER", phoneC, Icons.phone, isPhone: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _ipadInput("EMAIL ID", emailC, Icons.email)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("GSTIN NUMBER", gstC, Icons.receipt_long, isCaps: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _ipadInput("PAN (AUTO)", panC, Icons.badge_outlined, isCaps: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("DRUG LICENSE (DL)", dlC, Icons.medical_services, isCaps: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _ipadInput("DL EXPIRY", dlExpC, Icons.event_busy, isCaps: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("CITY", cityC, Icons.location_city, isCaps: true)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ipadDropdown(
                      "PRICING LEVEL",
                      selectedPriceLevel,
                      ["A", "B", "C"].map((p) => DropdownMenuItem(value: p, child: Text("Rate $p"))).toList(),
                      (v) => setState(() => selectedPriceLevel = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ipadInput("OFFICE / SHOP ADDRESS", addressC, Icons.location_on),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("OPENING BAL ₹", opBalC, Icons.account_balance_wallet, isNum: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _ipadInput("LIMIT ₹", creditLimitC, Icons.speed, isNum: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _ipadInput("DAYS", creditDaysC, Icons.timer, isNum: true)),
                ],
              ),
              if (activeSeries.isNotEmpty) ...[
                const SizedBox(height: 12),
                _ipadDropdown(
                  "DEFAULT BILLING SERIES PREFERENCE",
                  selectedSeriesId.isEmpty ? null : selectedSeriesId,
                  activeSeries.map((s) => DropdownMenuItem(value: s.id, child: Text("${s.name} (${s.prefix})"))).toList(),
                  (v) => setState(() => selectedSeriesId = v ?? ""),
                  hint: "Select Default Series (Optional)",
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _saveParty,
          child: const Text("SAVE CUSTOMER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        ),
      ],
    );
  }

  Widget _ipadInput(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isNum = false,
    bool isPhone = false,
    bool isCaps = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF38BDF8), size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: isPhone ? TextInputType.phone : (isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text),
                  textCapitalization: isCaps ? TextCapitalization.characters : TextCapitalization.none,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ipadDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged, {
    String hint = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
              items: items,
              onChanged: onChanged,
              hint: hint.isNotEmpty ? Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 10.5)) : null,
            ),
          ),
        ),
      ],
    );
  }
}
PARTYMODAL_EOF

# 7. Update quick_add_product_modal.dart (Dynamic Screen Clamped Width)
echo -e "${YELLOW}[7/9] Updating quick_add_product_modal.dart for responsive width...${NC}"
cat << 'PRODMODAL_EOF' > lib/web_live_sync/sub_views/web_billing/quick_add_product_modal.dart
// FILE: lib/web_live_sync/sub_views/web_billing/quick_add_product_modal.dart

import 'package:flutter/material.dart';
import '../../web_models.dart';
import '../../pharoah_web_manager.dart';

class QuickAddProductModal extends StatefulWidget {
  final PharoahWebManager webPh;
  final Function(Map<String, dynamic> newMed) onProductCreated;

  const QuickAddProductModal({
    super.key,
    required this.webPh,
    required this.onProductCreated,
  });

  @override
  State<QuickAddProductModal> createState() => _QuickAddProductModalState();
}

class _QuickAddProductModalState extends State<QuickAddProductModal> {
  final nameC = TextEditingController();
  final packC = TextEditingController(text: "10 TAB");
  final hsnC = TextEditingController(text: "3004");
  final gstC = TextEditingController(text: "12");
  final mrpC = TextEditingController(text: "0.0");
  final purRateC = TextEditingController(text: "0.0");
  final rateAC = TextEditingController(text: "0.0");
  final rateBC = TextEditingController(text: "0.0");

  String selectedForm = "TAB";
  String? selectedCompanyId;
  String? selectedSaltId;
  bool isNarcotic = false;
  bool isScheduleH1 = false;

  final List<String> drugForms = ["TAB", "CAP", "SYP", "INJ", "IV", "PCS", "EXT", "OINT", "DROP"];

  @override
  void dispose() {
    nameC.dispose();
    packC.dispose();
    hsnC.dispose();
    gstC.dispose();
    mrpC.dispose();
    purRateC.dispose();
    rateAC.dispose();
    rateBC.dispose();
    super.dispose();
  }

  void _saveProduct() {
    if (nameC.text.trim().isEmpty || packC.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product Name and Packing are required!"), backgroundColor: Colors.orange),
      );
      return;
    }

    double mrp = double.tryParse(mrpC.text) ?? 0.0;
    double pur = double.tryParse(purRateC.text) ?? 0.0;
    double a = double.tryParse(rateAC.text) ?? (mrp > 0 ? mrp : 0.0);
    double b = double.tryParse(rateBC.text) ?? (a > 0 ? a * 0.95 : 0.0);
    double gst = double.tryParse(gstC.text) ?? 12.0;

    String sysId = "PH-W-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    final newMed = Medicine(
      id: sysId,
      systemId: sysId,
      name: nameC.text.trim().toUpperCase(),
      packing: packC.text.trim().toUpperCase(),
      hsnCode: hsnC.text.trim().toUpperCase().isEmpty ? '3004' : hsnC.text.trim().toUpperCase(),
      drugForm: selectedForm,
      gst: gst,
      mrp: mrp,
      purRate: pur,
      rateA: a > 0 ? a : mrp,
      rateB: b,
      rateC: a > 0 ? a * 0.92 : 0.0,
      stock: 0.0,
      isNarcotic: isNarcotic,
      isScheduleH1: isScheduleH1,
      companyId: selectedCompanyId ?? '',
      saltId: selectedSaltId ?? '',
    );

    widget.webPh.addMedicine(newMed);
    Navigator.pop(context);
    widget.onProductCreated(newMed.toMap());
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 620 ? 580.0 : (screenWidth * 0.94);

    return AlertDialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.white12),
      ),
      titlePadding: const EdgeInsets.fromLTRB(18, 16, 18, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0x337C3AED),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add_box_rounded, color: Color(0xFFA78BFA), size: 18),
          ),
          const SizedBox(width: 10),
          const Text(
            "QUICK ADD PRODUCT",
            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ipadInput("PRODUCT / DRUG NAME *", nameC, Icons.medication, isCaps: true),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(flex: 3, child: _ipadInput("PACKING *", packC, Icons.inventory, isCaps: true)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: _ipadDropdown(
                      "DRUG FORM",
                      selectedForm,
                      drugForms.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                      (v) => setState(() => selectedForm = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ipadDropdown(
                      "COMPANY / BRAND",
                      selectedCompanyId,
                      widget.webPh.companies.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                      (v) => setState(() => selectedCompanyId = v),
                      hint: "Select Brand",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ipadDropdown(
                      "SALT COMPOSITION",
                      selectedSaltId,
                      widget.webPh.salts.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                      (v) => setState(() => selectedSaltId = v),
                      hint: "Select Salt",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("HSN CODE", hsnC, Icons.tag, isCaps: true)),
                  const SizedBox(width: 10),
                  Expanded(child: _ipadInput("GST %", gstC, Icons.percent, isNum: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _ipadInput("MRP ₹", mrpC, Icons.currency_rupee, isNum: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _ipadInput("PUR. RATE ₹", purRateC, Icons.shopping_cart, isNum: true)),
                  const SizedBox(width: 8),
                  Expanded(child: _ipadInput("SALE RATE A ₹", rateAC, Icons.sell, isNum: true)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Schedule H1", style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      value: isScheduleH1,
                      activeColor: const Color(0xFF38BDF8),
                      onChanged: (v) => setState(() => isScheduleH1 = v),
                    ),
                  ),
                  Expanded(
                    child: SwitchListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Narcotic (NDPS)", style: TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.bold)),
                      value: isNarcotic,
                      activeColor: Colors.redAccent,
                      onChanged: (v) => setState(() => isNarcotic = v),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("CANCEL", style: TextStyle(color: Colors.white54)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _saveProduct,
          child: const Text("SAVE PRODUCT", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5)),
        ),
      ],
    );
  }

  Widget _ipadInput(
    String label,
    TextEditingController ctrl,
    IconData icon, {
    bool isNum = false,
    bool isCaps = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFA78BFA), size: 15),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: ctrl,
                  keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
                  textCapitalization: isCaps ? TextCapitalization.characters : TextCapitalization.none,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _ipadDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T?> onChanged, {
    String hint = "",
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 8.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.black38,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor: const Color(0xFF1E293B),
              style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.bold),
              items: items,
              onChanged: onChanged,
              hint: hint.isNotEmpty ? Text(hint, style: const TextStyle(color: Colors.white38, fontSize: 10.5)) : null,
            ),
          ),
        ),
      ],
    );
  }
}
PRODMODAL_EOF

# 8. Update web_batch_lookup_dialog.dart (Dynamic Screen Clamped Width)
echo -e "${YELLOW}[8/9] Updating web_batch_lookup_dialog.dart for responsive width...${NC}"
cat << 'BATCHLOOKUP_EOF' > lib/web_live_sync/sub_views/web_billing/web_batch_lookup_dialog.dart
// FILE: lib/web_live_sync/sub_views/web_billing/web_batch_lookup_dialog.dart

import 'package:flutter/material.dart';
import '../../web_models.dart';
import '../../web_expiry_master.dart';

class WebBatchLookupDialog extends StatefulWidget {
  final Medicine medicine;
  final List<BatchInfo> batches;
  final bool prioritizeExpired;

  const WebBatchLookupDialog({
    super.key,
    required this.medicine,
    required this.batches,
    this.prioritizeExpired = false,
  });

  @override
  State<WebBatchLookupDialog> createState() => _WebBatchLookupDialogState();
}

class _WebBatchLookupDialogState extends State<WebBatchLookupDialog> {
  DateTime _parseExpiry(String exp) {
    try {
      final parts = exp.split('/');
      int m = int.parse(parts[0]);
      int y = 2000 + int.parse(parts[1]);
      return DateTime(y, m + 1, 0);
    } catch (_) {
      return DateTime(2100);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedBatches = List<BatchInfo>.from(widget.batches);
    sortedBatches.sort((a, b) => _parseExpiry(a.exp).compareTo(_parseExpiry(b.exp)));

    double grandTotalQty = widget.batches.fold(0.0, (sum, b) => sum + b.qty);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 600 ? 560.0 : (screenWidth * 0.94);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: Colors.white12),
      ),
      backgroundColor: const Color(0xFF1E293B),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: const BoxDecoration(
              color: Color(0x2622D3EE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.layers_rounded, color: Colors.cyanAccent, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.medicine.name,
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "Pack: ${widget.medicine.packing} • Select batch to auto-fill prices",
                  style: const TextStyle(color: Colors.white54, fontSize: 9.5),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      content: SizedBox(
        width: dialogWidth,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: Text("BATCH NO", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("EXPIRY", style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("MRP", textAlign: TextAlign.right, style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
                  Expanded(flex: 2, child: Text("RATE A", textAlign: TextAlign.right, style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
                  Expanded(flex: 3, child: Text("STOCK", textAlign: TextAlign.right, style: TextStyle(color: Colors.white70, fontSize: 9, fontWeight: FontWeight.bold))),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: sortedBatches.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(25),
                      child: Text(
                        "No batch history recorded for this medicine.\nClick 'Manual New Batch' below to enter details.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white38, fontSize: 11),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: sortedBatches.length,
                      itemBuilder: (context, idx) {
                        final b = sortedBatches[idx];
                        final status = WebExpiryMaster.getStatus(b.exp);
                        final statusColor = WebExpiryMaster.getStatusColor(b.exp);
                        String statusLabel = "Safe";
                        if (status == ExpiryStatus.expired) statusLabel = "Expired";
                        if (status == ExpiryStatus.nearExpiry) statusLabel = "Near Exp";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0x0DFFFFFF)),
                          ),
                          child: ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                            onTap: () => Navigator.pop(context, b),
                            title: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(b.batch, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Text(b.exp, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                      const SizedBox(width: 3),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                                        decoration: BoxDecoration(color: statusColor.withAlpha(40), borderRadius: BorderRadius.circular(3)),
                                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 6.5, fontWeight: FontWeight.bold)),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text("₹${b.mrp.toStringAsFixed(2)}", textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text("₹${b.rateA.toStringAsFixed(2)}", textAlign: TextAlign.right, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text("${b.qty.toInt()} Qty", textAlign: TextAlign.right, style: TextStyle(color: b.qty > 0 ? Colors.greenAccent : Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 10.5)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("TOTAL INVENTORY STOCK", style: TextStyle(color: Colors.white54, fontSize: 8, fontWeight: FontWeight.bold)),
                      Text(
                        "${grandTotalQty.toInt()} Units",
                        style: const TextStyle(color: Colors.cyanAccent, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pop(context, "MANUAL"),
                    icon: const Icon(Icons.add_circle_outline, size: 14, color: Colors.orangeAccent),
                    label: const Text("Manual New Batch", style: TextStyle(color: Colors.orangeAccent, fontSize: 10.5, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
BATCHLOOKUP_EOF

# 9. Verify with Strict Analyzer and Deploy
echo -e "${YELLOW}[9/9] Verifying 0 issues with Analyzer & Deploying #PH-REV-131...${NC}"
pkill -f "analysis_server" 2>/dev/null || true
flutter analyze lib/web_live_sync/

# Free RAM
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true

rm -rf build/web
flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

npx wrangler pages deploy build/web --project-name=pharoah-erp --commit-dirty=true

git add .
git commit -m "Deploy Fully Responsive & Zoom-Enabled Web #PH-REV-131" || true
git push origin main || true

echo -e "\n${BLUE}====================================================${NC}"
echo -e "${GREEN}  🎉 100% RESPONSIVE WEB WORKSTATION DEPLOYED!      ${NC}"
echo -e "${GREEN}  🔗 Live at: https://pharoah-erp.pages.dev        ${NC}"
echo -e "${BLUE}====================================================${NC}"
