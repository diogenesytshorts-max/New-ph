#!/bin/bash
set -e

echo -e "\033[0;34m====================================================\033[0m"
echo -e "\033[0;34m   🔍 DETECTING FLUTTER & DEPLOYING 5 CHALLAN BUTTONS \033[0m"
echo -e "\033[0;34m====================================================\033[0m\n"

# 1. Auto-detect or Setup Flutter SDK
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
  echo -e "  \033[0;32m✔ Found Flutter at:\033[0m $FLUTTER_BIN"
  export PATH="$FLUTTER_BIN:$PATH"
else
  echo -e "  \033[1;33m⚠ Flutter not found in system paths. Installing Flutter 3.27.4...\033[0m"
  cd $HOME
  wget -q https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.27.4-stable.tar.xz
  tar -xf flutter_linux_3.27.4-stable.tar.xz > /dev/null 2>&1
  rm flutter_linux_3.27.4-stable.tar.xz
  export PATH="$HOME/flutter/bin:$PATH"
  cd /workspaces/New-ph || cd /workspaces/* || true
fi

echo -e "  \033[0;32m✔ Active Flutter:\033[0m $(flutter --version | head -n 1)\n"

# 2. Update web_modules_registry.dart with 5 Challan Buttons
echo -e "\033[1;33m[1/4] Registering 5 Challan actions in web_modules_registry.dart...\033[0m"
cat << 'REGISTRY_EOF' > lib/web_live_sync/web_modules_registry.dart
import 'package:flutter/material.dart';

class WebActionItem {
  final String key;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const WebActionItem({
    required this.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });
}

class WebHubItem {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<WebActionItem> subActions;

  const WebHubItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.subActions,
  });
}

class WebModulesRegistry {
  static const List<WebHubItem> allHubs = [
    // 1. BILLING & TRANSACTIONS
    WebHubItem(
      id: "BILLING",
      title: "BILLING & SALES",
      subtitle: "Invoicing, Purchases & Registers",
      icon: Icons.receipt_long_rounded,
      color: Color(0xFF2563EB),
      subActions: [
        WebActionItem(key: "GO_SALE", title: "New Sale Bill", subtitle: "Standard Outward Tax Invoice", icon: Icons.add_shopping_cart, color: Color(0xFF2563EB)),
        WebActionItem(key: "GO_PURCHASE", title: "Purchase Inward", subtitle: "Stock Inward Invoicing", icon: Icons.downloading_rounded, color: Color(0xFFEA580C)),
        WebActionItem(key: "GO_SALE_REG", title: "Sale Register", subtitle: "Outward Bills Summary & Audit", icon: Icons.description_outlined, color: Color(0xFF3B82F6)),
        WebActionItem(key: "GO_PUR_REG", title: "Purchase Register", subtitle: "Inward Tax Register & Summary", icon: Icons.history_rounded, color: Color(0xFFB45309)),
      ],
    ),

    // 2. DELIVERY CHALLANS (5 EXACT BUTTONS)
    WebHubItem(
      id: "CHALLANS",
      title: "DELIVERY CHALLANS",
      subtitle: "Inward/Outward Notes, Stitcher & Registers",
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF0F766E),
      subActions: [
        WebActionItem(key: "GO_CHALLAN_SALE", title: "Outward Sale Challan", subtitle: "Dispatch Delivery Note", icon: Icons.local_shipping_rounded, color: Color(0xFF0F766E)),
        WebActionItem(key: "GO_CHALLAN_PUR", title: "Inward Purchase Challan", subtitle: "Stock Inward Receipt Note", icon: Icons.inventory_2_rounded, color: Color(0xFFD97706)),
        WebActionItem(key: "GO_STITCHER", title: "Challan to Bill Converter", subtitle: "Stitch Pending Challans to Invoice", icon: Icons.auto_fix_high_rounded, color: Color(0xFF2DD4BF)),
        WebActionItem(key: "GO_CHALLAN_SALE_REG", title: "Sale Challans Register", subtitle: "Track Pending Deliveries", icon: Icons.list_alt_rounded, color: Color(0xFF4338CA)),
        WebActionItem(key: "GO_CHALLAN_PUR_REG", title: "Purchase Challans Register", subtitle: "Audit Inward Dispatches", icon: Icons.history_edu_rounded, color: Color(0xFFB45309)),
      ],
    ),

    // 3. RETURNS
    WebHubItem(
      id: "RETURNS",
      title: "RETURNS & REVERSALS",
      subtitle: "Credit Notes, Debit Notes & Breakage",
      icon: Icons.assignment_return_rounded,
      color: Color(0xFFDC2626),
      subActions: [
        WebActionItem(key: "GO_CN", title: "Credit Note (Sale Return)", subtitle: "Sellable Customer Return", icon: Icons.assignment_return_rounded, color: Color(0xFFDC2626)),
        WebActionItem(key: "GO_DN", title: "Debit Note (Purchase Return)", subtitle: "Return to Distributor", icon: Icons.remove_shopping_cart_rounded, color: Color(0xFF92400E)),
        WebActionItem(key: "GO_BREAKAGE", title: "Breakage / Expiry Return", subtitle: "Non-Sellable Stock Out", icon: Icons.delete_sweep_rounded, color: Color(0xFFEA580C)),
        WebActionItem(key: "GO_RET_REG", title: "Returns Audit Register", subtitle: "Full Reversals History", icon: Icons.format_list_bulleted_rounded, color: Color(0xFF991B1B)),
      ],
    ),

    // 4. INVENTORY
    WebHubItem(
      id: "INVENTORY",
      title: "INVENTORY & INTEL",
      subtitle: "Live Stock, 1.5x Shortage & Batches",
      icon: Icons.inventory_2_rounded,
      color: Color(0xFF7C3AED),
      subActions: [
        WebActionItem(key: "GO_STOCK", title: "Live Stock Explorer", subtitle: "Batch & Expiry Search", icon: Icons.view_in_ar_rounded, color: Color(0xFF7C3AED)),
        WebActionItem(key: "GO_SHORTAGE", title: "1.5x Auto Shortage Scan", subtitle: "45-Days Requirement PO", icon: Icons.trending_down_rounded, color: Color(0xFFDC2626)),
        WebActionItem(key: "GO_ITEM_LEDGER", title: "Item Movement Ledger", subtitle: "In/Out Stock Timeline", icon: Icons.menu_book_rounded, color: Color(0xFF475569)),
        WebActionItem(key: "GO_DUMP", title: "Dumping / Non-Moving", subtitle: "Dead Stock Analysis (90 Days)", icon: Icons.delete_sweep_outlined, color: Color(0xFFC2410C)),
      ],
    ),

    // 5. ACCOUNTS
    WebHubItem(
      id: "ACCOUNTS",
      title: "ACCOUNTS & KHAATA",
      subtitle: "Daybook, Vouchers & Ledgers",
      icon: Icons.account_balance_wallet_rounded,
      color: Color(0xFF3730A3),
      subActions: [
        WebActionItem(key: "GO_DAYBOOK", title: "Daybook Register", subtitle: "Daily Inflow & Outflow", icon: Icons.event_note_rounded, color: Color(0xFF475569)),
        WebActionItem(key: "GO_LEDGERS", title: "Customer Ledgers", subtitle: "Outstanding & Balances", icon: Icons.people_alt_rounded, color: Color(0xFF4338CA)),
        WebActionItem(key: "GO_RECEIPT", title: "Receipt Voucher", subtitle: "Payment Received (Cash/Bank)", icon: Icons.add_chart_rounded, color: Color(0xFF15803D)),
        WebActionItem(key: "GO_PAYMENT", title: "Payment Voucher", subtitle: "Supplier Payment Out", icon: Icons.analytics_rounded, color: Color(0xFFB91C1C)),
      ],
    ),

    // 6. MASTERS
    WebHubItem(
      id: "MASTERS",
      title: "BUSINESS MASTERS",
      subtitle: "Parties, Medicines, Salts & Brands",
      icon: Icons.stars_rounded,
      color: Color(0xFFC2410C),
      subActions: [
        WebActionItem(key: "GO_M_PARTY", title: "Parties & Ledgers", subtitle: "Customers & Suppliers", icon: Icons.group_add_rounded, color: Color(0xFF4338CA)),
        WebActionItem(key: "GO_M_ITEM", title: "Item Master", subtitle: "Drug & Product Catalog", icon: Icons.medication_rounded, color: Color(0xFF7C3AED)),
        WebActionItem(key: "GO_M_BATCH", title: "Batch Master", subtitle: "Central Batch Adjustments", icon: Icons.layers_outlined, color: Color(0xFF312E81)),
        WebActionItem(key: "GO_M_ROUTE", title: "Routes & Areas", subtitle: "Delivery Route Planner", icon: Icons.map_rounded, color: Color(0xFF0F766E)),
        WebActionItem(key: "GO_M_COMP", title: "Company Brands", subtitle: "Manufacturer Library", icon: Icons.business_rounded, color: Color(0xFF9A3412)),
        WebActionItem(key: "GO_M_SALT", title: "Salt Compositions", subtitle: "Mono/Duo Salt Master", icon: Icons.science_rounded, color: Color(0xFFC2410C)),
      ],
    ),

    // 7. GST
    WebHubItem(
      id: "GST",
      title: "GST & STATUTORY",
      subtitle: "GSTR-1, GSTR-3B & Reconciliations",
      icon: Icons.verified_rounded,
      color: Color(0xFF15803D),
      subActions: [
        WebActionItem(key: "GO_GST_1", title: "GSTR-1 (Sales Register)", subtitle: "B2B, B2C & HSN Summary", icon: Icons.assignment_outlined, color: Color(0xFF15803D)),
        WebActionItem(key: "GO_GST_3B", title: "GSTR-3B Summary", subtitle: "Monthly Tax Computation", icon: Icons.summarize_outlined, color: Color(0xFF2563EB)),
        WebActionItem(key: "GO_GST_RECON", title: "Portal 2A/2B Match", subtitle: "ITC Reconciliation", icon: Icons.fact_check_outlined, color: Color(0xFF0D9488)),
      ],
    ),

    // 8. DATA HUB
    WebHubItem(
      id: "DATA_HUB",
      title: "DATA EXCHANGE HUB",
      subtitle: "C2C Store Sync & 39-Col Universal CSV",
      icon: Icons.cloud_sync_rounded,
      color: Color(0xFF334155),
      subActions: [
        WebActionItem(key: "GO_C2C", title: "Store-to-Store (C2C)", subtitle: "Internal Branch Synchronization", icon: Icons.sync_alt_rounded, color: Color(0xFF2563EB)),
        WebActionItem(key: "GO_C2V", title: "Vendor Supply (C2V)", subtitle: "External Trade (Masked Rate)", icon: Icons.business_center_rounded, color: Color(0xFF0D9488)),
        WebActionItem(key: "GO_CSV", title: "39-Column CSV Tool", subtitle: "Universal Data Import/Export", icon: Icons.table_chart_rounded, color: Color(0xFFD97706)),
      ],
    ),
  ];
}
REGISTRY_EOF

# 3. Update web_challan_view.dart with 5 Solid Non-Collapsing Buttons & Modules
echo -e "\033[1;33m[2/4] Updating web_challan_view.dart with 5-Button Hub...\033[0m"
cat << 'CHALLAN_VIEW_EOF' > lib/web_live_sync/web_challan_view.dart
// FILE: lib/web_live_sync/web_challan_view.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'web_models.dart';
import 'pharoah_web_manager.dart';
import 'web_app_date_logic.dart';
import 'web_pharoah_numbering_engine.dart';
import 'web_pdf_router_service.dart';
import 'web_challan_stitcher_wizard.dart';

class WebChallanView extends StatefulWidget {
  final VoidCallback onBack;
  final int initialTabIndex;

  const WebChallanView({
    super.key,
    required this.onBack,
    this.initialTabIndex = 0,
  });

  @override
  State<WebChallanView> createState() => _WebChallanViewState();
}

class _WebChallanViewState extends State<WebChallanView> {
  int activeIndex = 0;

  // 1. Sale Challan State
  final scNumberC = TextEditingController();
  final scRemarksC = TextEditingController();
  DateTime scDate = DateTime.now();
  Party? scSelectedCustomer;
  List<BillItem> scItems = [];

  // 2. Purchase Challan State
  final pcInternalNoC = TextEditingController();
  final pcSupplierRefC = TextEditingController();
  final pcRemarksC = TextEditingController();
  DateTime pcDate = DateTime.now();
  Party? pcSelectedSupplier;
  List<PurchaseItem> pcItems = [];

  // 3. Register State
  DateTime regFromDate = DateTime.now();
  DateTime regToDate = DateTime.now();
  String registerSearch = "";
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    activeIndex = widget.initialTabIndex;
    final webPh = Provider.of<PharoahWebManager>(context, listen: false);

    scNumberC.text = webPh.getNextBillNumber("CHALLAN", "SCH-", 101);
    pcInternalNoC.text = WebPharoahNumberingEngine.getNextNumber(
      prefix: "PCH-",
      startFrom: 1,
      currentList: webPh.purchaseChallans,
    );

    scDate = WebAppDateLogic.getSmartDate(webPh.financialYear);
    pcDate = scDate;
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

  @override
  void dispose() {
    scNumberC.dispose();
    scRemarksC.dispose();
    pcInternalNoC.dispose();
    pcSupplierRefC.dispose();
    pcRemarksC.dispose();
    super.dispose();
  }

  // --- ITEM DIALOG: SALE CHALLAN ---
  void _openScItemDialog(PharoahWebManager webPh, Medicine med) {
    final batchC = TextEditingController();
    final expC = TextEditingController(text: "12/28");
    final mrpC = TextEditingController(text: med.mrp.toStringAsFixed(2));
    final rateC = TextEditingController(text: med.rateA.toStringAsFixed(2));
    final qtyC = TextEditingController(text: "1");
    final freeC = TextEditingController(text: "0");
    final gstC = TextEditingController(text: med.gst.toString());

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) {
          double q = double.tryParse(qtyC.text) ?? 0.0;
          double r = double.tryParse(rateC.text) ?? 0.0;
          double g = double.tryParse(gstC.text) ?? 0.0;
          double itemTotal = (q * r) * (1 + g / 100);

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white12)),
            title: Text("DISPATCH ITEM • ${med.name}", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: _input("BATCH NO *", batchC, isCaps: false)),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: _input("EXPIRY (MM/YY)", expC, isNum: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _input("MRP ₹", mrpC, isNum: true)),
                        const SizedBox(width: 10),
                        Expanded(child: _input("CHALLAN RATE ₹ *", rateC, isNum: true, isHighlight: true, onChanged: (_) => setDialogState(() {}))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _input("DISPATCH QTY *", qtyC, isNum: true, isHighlight: true, onChanged: (_) => setDialogState(() {}))),
                        const SizedBox(width: 10),
                        Expanded(child: _input("FREE QTY", freeC, isNum: true)),
                        const SizedBox(width: 10),
                        Expanded(child: _input("GST %", gstC, isNum: true, onChanged: (_) => setDialogState(() {}))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("ESTIMATED DISPATCH VALUE", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("₹${itemTotal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white),
                onPressed: () {
                  if (batchC.text.trim().isEmpty || q <= 0 || r <= 0) return;
                  final newItem = BillItem(
                    id: "SCITM-${DateTime.now().millisecondsSinceEpoch}",
                    srNo: scItems.length + 1,
                    medicineID: med.id,
                    name: med.name,
                    packing: med.packing,
                    batch: batchC.text.trim(),
                    exp: expC.text.trim(),
                    hsn: med.hsnCode,
                    mrp: double.tryParse(mrpC.text) ?? 0.0,
                    qty: q,
                    freeQty: double.tryParse(freeC.text) ?? 0.0,
                    rate: r,
                    gstRate: g,
                    total: itemTotal,
                  );
                  setState(() => scItems.add(newItem));
                  Navigator.pop(c);
                },
                child: const Text("ADD TO CHALLAN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveSaleChallan(PharoahWebManager webPh) {
    if (scSelectedCustomer == null || scItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Customer and add items!"), backgroundColor: Colors.orange));
      return;
    }

    double total = scItems.fold(0.0, (sum, it) => sum + it.total);

    final newChallan = SaleChallan(
      id: "SCH-WEB-${DateTime.now().millisecondsSinceEpoch}",
      billNo: scNumberC.text.trim(),
      partyId: scSelectedCustomer!.id,
      partyName: scSelectedCustomer!.name,
      partyGstin: scSelectedCustomer!.gst,
      partyState: scSelectedCustomer!.state,
      date: scDate,
      items: List.from(scItems),
      totalAmount: total,
      status: "Pending",
      remarks: scRemarksC.text.trim(),
    );

    webPh.saleChallans.add(newChallan);
    webPh.pushUpdatedDataToCloud();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Delivery Challan ${scNumberC.text} Saved!"), backgroundColor: Colors.green));
    setState(() {
      scItems.clear();
      scSelectedCustomer = null;
      scNumberC.text = webPh.getNextBillNumber("CHALLAN", "SCH-", 101);
      activeIndex = 3; // Switch to Sale Challan Register
    });
  }

  // --- ITEM DIALOG: PURCHASE CHALLAN ---
  void _openPcItemDialog(PharoahWebManager webPh, Medicine med) {
    final batchC = TextEditingController();
    final expC = TextEditingController(text: "12/28");
    final mrpC = TextEditingController(text: med.mrp.toStringAsFixed(2));
    final purRateC = TextEditingController(text: med.purRate.toStringAsFixed(2));
    final qtyC = TextEditingController(text: "1");
    final freeC = TextEditingController(text: "0");
    final gstC = TextEditingController(text: med.gst.toString());

    showDialog(
      context: context,
      builder: (c) => StatefulBuilder(
        builder: (context, setDialogState) {
          double q = double.tryParse(qtyC.text) ?? 0.0;
          double pRate = double.tryParse(purRateC.text) ?? 0.0;
          double g = double.tryParse(gstC.text) ?? 0.0;
          double itemTotal = (q * pRate) * (1 + g / 100);

          return AlertDialog(
            backgroundColor: const Color(0xFF1E293B),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: const BorderSide(color: Colors.white12)),
            title: Text("INWARD ITEM • ${med.name}", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(flex: 3, child: _input("BATCH NO *", batchC, isCaps: false)),
                        const SizedBox(width: 10),
                        Expanded(flex: 2, child: _input("EXPIRY (MM/YY)", expC, isNum: true)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _input("MRP ₹", mrpC, isNum: true)),
                        const SizedBox(width: 10),
                        Expanded(child: _input("PUR. RATE ₹ *", purRateC, isNum: true, isHighlight: true, onChanged: (_) => setDialogState(() {}))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _input("INWARD QTY *", qtyC, isNum: true, isHighlight: true, onChanged: (_) => setDialogState(() {}))),
                        const SizedBox(width: 10),
                        Expanded(child: _input("FREE QTY", freeC, isNum: true)),
                        const SizedBox(width: 10),
                        Expanded(child: _input("GST %", gstC, isNum: true, onChanged: (_) => setDialogState(() {}))),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("INWARD VALUE", style: TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold)),
                          Text("₹${itemTotal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 18, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(c), child: const Text("CANCEL", style: TextStyle(color: Colors.white54))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white),
                onPressed: () {
                  if (batchC.text.trim().isEmpty || q <= 0 || pRate <= 0) return;
                  final newItem = PurchaseItem(
                    id: "PCITM-${DateTime.now().millisecondsSinceEpoch}",
                    srNo: pcItems.length + 1,
                    medicineID: med.id,
                    name: med.name,
                    packing: med.packing,
                    batch: batchC.text.trim(),
                    exp: expC.text.trim(),
                    hsn: med.hsnCode,
                    mrp: double.tryParse(mrpC.text) ?? 0.0,
                    qty: q,
                    freeQty: double.tryParse(freeC.text) ?? 0.0,
                    purchaseRate: pRate,
                    gstRate: g,
                    total: itemTotal,
                  );
                  setState(() => pcItems.add(newItem));
                  Navigator.pop(c);
                },
                child: const Text("ADD TO INWARD CHALLAN", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  void _savePurchaseChallan(PharoahWebManager webPh) {
    if (pcSelectedSupplier == null || pcSupplierRefC.text.trim().isEmpty || pcItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Select Supplier, Ref No & add items!"), backgroundColor: Colors.orange));
      return;
    }

    double total = pcItems.fold(0.0, (sum, it) => sum + it.total);

    final newChallan = PurchaseChallan(
      id: "PCH-WEB-${DateTime.now().millisecondsSinceEpoch}",
      internalNo: pcInternalNoC.text.trim(),
      billNo: pcSupplierRefC.text.trim(),
      partyId: pcSelectedSupplier!.id,
      distributorName: pcSelectedSupplier!.name,
      date: pcDate,
      items: List.from(pcItems),
      totalAmount: total,
      status: "Pending",
      remarks: pcRemarksC.text.trim(),
    );

    webPh.purchaseChallans.add(newChallan);
    webPh.pushUpdatedDataToCloud();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ Inward Challan ${pcInternalNoC.text} Saved!"), backgroundColor: Colors.green));
    setState(() {
      pcItems.clear();
      pcSelectedSupplier = null;
      pcSupplierRefC.clear();
      pcInternalNoC.text = WebPharoahNumberingEngine.getNextNumber(prefix: "PCH-", startFrom: 1, currentList: webPh.purchaseChallans);
      activeIndex = 4; // Switch to Purchase Challan Register
    });
  }

  @override
  Widget build(BuildContext context) {
    final webPh = Provider.of<PharoahWebManager>(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white12,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                onPressed: widget.onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text("BACK", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.local_shipping_rounded, color: Color(0xFF2DD4BF), size: 22),
              const SizedBox(width: 10),
              const Text(
                "DELIVERY CHALLANS & CONVERTER HUB",
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5 PROMINENT BUTTONS BAR (Exact 1:1 App Parity)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _topNavButton(0, "OUTWARD SALE CHALLAN", Icons.local_shipping_rounded, const Color(0xFF0F766E)),
                const SizedBox(width: 8),
                _topNavButton(1, "INWARD PUR CHALLAN", Icons.inventory_2_rounded, const Color(0xFFD97706)),
                const SizedBox(width: 8),
                _topNavButton(2, "CHALLAN TO BILL CONVERTER", Icons.auto_fix_high_rounded, const Color(0xFF2DD4BF)),
                const SizedBox(width: 8),
                _topNavButton(3, "SALE CHALLANS REGISTER (${webPh.saleChallans.length})", Icons.list_alt_rounded, const Color(0xFF4338CA)),
                const SizedBox(width: 8),
                _topNavButton(4, "PUR CHALLANS REGISTER (${webPh.purchaseChallans.length})", Icons.history_edu_rounded, const Color(0xFFB45309)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 5 DIRECT CONTENT MODULES (No unbounded height collapse)
          if (activeIndex == 0) _buildSaleChallanForm(webPh),
          if (activeIndex == 1) _buildPurchaseChallanForm(webPh),
          if (activeIndex == 2) WebChallanStitcherWizard(onBack: () => setState(() => activeIndex = 0)),
          if (activeIndex == 3) _buildSaleRegister(webPh),
          if (activeIndex == 4) _buildPurchaseRegister(webPh),
        ],
      ),
    );
  }

  Widget _topNavButton(int index, String title, IconData icon, Color color) {
    bool isSelected = activeIndex == index;

    return InkWell(
      onTap: () => setState(() => activeIndex = index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.white : Colors.white12, width: isSelected ? 1.5 : 1.0),
          boxShadow: isSelected ? [BoxShadow(color: color.withAlpha(80), blurRadius: 10, offset: const Offset(0, 3))] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white70),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- VIEW 1: SALE CHALLAN ENTRY FORM ---
  Widget _buildSaleChallanForm(PharoahWebManager webPh) {
    double total = scItems.fold(0.0, (sum, it) => sum + it.total);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 950;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildScLeftColumn(webPh)),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _buildScRightSidebar(webPh, total)),
                ],
              )
            : Column(
                children: [
                  _buildScRightSidebar(webPh, total),
                  const SizedBox(height: 16),
                  _buildScLeftColumn(webPh),
                ],
              );
      },
    );
  }

  Widget _buildScLeftColumn(PharoahWebManager webPh) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: Autocomplete<Medicine>(
            displayStringForOption: (m) => "${m.name} (${m.packing}) - Stock: ${m.stock.toInt()}",
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable.empty();
              return webPh.medicines.where((m) =>
                  m.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (med) => _openScItemDialog(webPh, med),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  hintText: "Search Product to add in outward delivery challan...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                  prefixIcon: Icon(Icons.search, color: Color(0xFF2DD4BF), size: 18),
                  border: InputBorder.none,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: scItems.isEmpty
              ? const Center(child: Text("No items in delivery challan cart. Search products above.", style: TextStyle(color: Colors.white38, fontSize: 11.5)))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: scItems.length,
                  itemBuilder: (c, i) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      dense: true,
                      title: Text(scItems[i].name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text("Batch: ${scItems[i].batch} | Qty: ${scItems[i].qty.toInt()} + ${scItems[i].freeQty.toInt()} | Rate: ₹${scItems[i].rate}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("₹${scItems[i].total.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.bold, fontSize: 12)),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent), onPressed: () => setState(() => scItems.removeAt(i))),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildScRightSidebar(PharoahWebManager webPh, double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input("CHALLAN NUMBER", scNumberC),
          const SizedBox(height: 12),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: scDate,
                firstDate: WebAppDateLogic.getFYStart(webPh.financialYear),
                lastDate: WebAppDateLogic.getFYEnd(webPh.financialYear),
              );
              if (picked != null) setState(() => scDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DATE: ${DateFormat('dd/MM/yyyy').format(scDate)}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Icon(Icons.calendar_month, color: Color(0xFF2DD4BF), size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Autocomplete<Party>(
            displayStringForOption: (p) => "${p.name} (${p.city})",
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable.empty();
              return webPh.parties.where((p) => p.group == "Sundry Debtors" && p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (p) => setState(() => scSelectedCustomer = p),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  labelText: "SELECT CUSTOMER *",
                  labelStyle: TextStyle(color: Colors.white54, fontSize: 9),
                  prefixIcon: Icon(Icons.person, color: Color(0xFF38BDF8), size: 16),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _input("DISPATCH REMARKS / VEHICLE", scRemarksC),
          const SizedBox(height: 20),
          Text("TOTAL CHALLAN: ₹${total.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _saveSaleChallan(webPh),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text("SAVE DELIVERY CHALLAN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- VIEW 2: PURCHASE CHALLAN ENTRY FORM ---
  Widget _buildPurchaseChallanForm(PharoahWebManager webPh) {
    double total = pcItems.fold(0.0, (sum, it) => sum + it.total);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWide = constraints.maxWidth > 950;
        return isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 7, child: _buildPcLeftColumn(webPh)),
                  const SizedBox(width: 16),
                  Expanded(flex: 3, child: _buildPcRightSidebar(webPh, total)),
                ],
              )
            : Column(
                children: [
                  _buildPcRightSidebar(webPh, total),
                  const SizedBox(height: 16),
                  _buildPcLeftColumn(webPh),
                ],
              );
      },
    );
  }

  Widget _buildPcLeftColumn(PharoahWebManager webPh) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: Autocomplete<Medicine>(
            displayStringForOption: (m) => "${m.name} (${m.packing})",
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable.empty();
              return webPh.medicines.where((m) =>
                  m.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (med) => _openPcItemDialog(webPh, med),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  hintText: "Search Product to add in inward purchase challan...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                  prefixIcon: Icon(Icons.search, color: Color(0xFFD97706), size: 18),
                  border: InputBorder.none,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Container(
          constraints: const BoxConstraints(minHeight: 220),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: pcItems.isEmpty
              ? const Center(child: Text("No items in inward challan. Search products above.", style: TextStyle(color: Colors.white38, fontSize: 11.5)))
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: pcItems.length,
                  itemBuilder: (c, i) => Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
                    child: ListTile(
                      dense: true,
                      title: Text(pcItems[i].name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      subtitle: Text("Batch: ${pcItems[i].batch} | Qty: ${pcItems[i].qty.toInt()} + ${pcItems[i].freeQty.toInt()} | Pur Rate: ₹${pcItems[i].purchaseRate}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("₹${pcItems[i].total.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.bold, fontSize: 12)),
                          IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.redAccent), onPressed: () => setState(() => pcItems.removeAt(i))),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPcRightSidebar(PharoahWebManager webPh, double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _input("INTERNAL INWARD ID", pcInternalNoC),
          const SizedBox(height: 10),
          _input("SUPPLIER REF / CHALLAN NO *", pcSupplierRefC, isCaps: true),
          const SizedBox(height: 10),
          InkWell(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: pcDate,
                firstDate: WebAppDateLogic.getFYStart(webPh.financialYear),
                lastDate: WebAppDateLogic.getFYEnd(webPh.financialYear),
              );
              if (picked != null) setState(() => pcDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("DATE: ${DateFormat('dd/MM/yyyy').format(pcDate)}", style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  const Icon(Icons.calendar_month, color: Color(0xFFFBBF24), size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Autocomplete<Party>(
            displayStringForOption: (p) => "${p.name} (${p.city})",
            optionsBuilder: (textEditingValue) {
              if (textEditingValue.text.isEmpty) return const Iterable.empty();
              return webPh.parties.where((p) => p.group == "Sundry Creditors" && p.name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
            },
            onSelected: (p) => setState(() => pcSelectedSupplier = p),
            fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
              return TextField(
                controller: controller,
                focusNode: focusNode,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(
                  labelText: "SELECT SUPPLIER *",
                  labelStyle: TextStyle(color: Colors.white54, fontSize: 9),
                  prefixIcon: Icon(Icons.business, color: Color(0xFFF59E0B), size: 16),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          _input("INWARD REMARKS", pcRemarksC),
          const SizedBox(height: 20),
          Text("TOTAL INWARD: ₹${total.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD97706), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => _savePurchaseChallan(webPh),
              icon: const Icon(Icons.check_circle_rounded, size: 18),
              label: const Text("SAVE INWARD CHALLAN", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  // --- VIEW 4: SALE CHALLANS REGISTER ---
  Widget _buildSaleRegister(PharoahWebManager webPh) {
    final activeShop = CompanyProfile.fromMap(webPh.companyProfile);
    final fDateOnly = _dateOnly(regFromDate);
    final tDateOnly = _dateOnly(regToDate);

    List<SaleChallan> list = List.from(webPh.saleChallans);
    list.sort((a, b) => b.date.compareTo(a.date));

    final filtered = list.where((c) {
      final cDateOnly = _dateOnly(c.date);
      bool dateMatch = !cDateOnly.isBefore(fDateOnly) && !cDateOnly.isAfter(tDateOnly);
      bool searchMatch = registerSearch.isEmpty ||
          c.partyName.toLowerCase().contains(registerSearch.toLowerCase()) || 
          c.billNo.toString().toLowerCase().contains(registerSearch.toLowerCase());
      return dateMatch && searchMatch;
    }).toList();

    double totalVal = filtered.fold(0.0, (s, c) => s + c.totalAmount);

    return Column(
      children: [
        _buildRegisterFilterBar(
          webPh, 
          onPrintReport: () => WebPdfRouterService.printChallanReport(challans: filtered, shop: activeShop, from: regFromDate, to: regToDate, isSaleChallan: true),
        ),
        const SizedBox(height: 12),
        filtered.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("No Sale Challans found for selected date range.", style: TextStyle(color: Colors.white38))))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (c, i) {
                  final item = filtered[i];
                  bool isPending = item.status == "Pending";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(color: Color(0x330F766E), borderRadius: BorderRadius.all(Radius.circular(6))),
                        child: const Text("SALE CH", style: TextStyle(color: Color(0xFF2DD4BF), fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                      title: Row(
                        children: [
                          Text(item.partyName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          _statusBadge(item.status.toUpperCase(), isPending),
                        ],
                      ),
                      subtitle: Text("Challan No: ${item.billNo} • Date: ${DateFormat('dd/MM/yyyy').format(item.date)} • Items: ${item.items.length}", style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("₹${item.totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF2DD4BF), fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.print_outlined, color: Color(0xFF38BDF8), size: 18),
                            tooltip: "Print Landscape Challan",
                            onPressed: () {
                              final pObj = webPh.parties.firstWhere((p) => p.name == item.partyName, orElse: () => Party(id: 'temp', name: item.partyName));
                              WebPdfRouterService.printSaleChallan(challan: item, party: pObj, shop: activeShop);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.download_rounded, color: Colors.greenAccent, size: 18),
                            tooltip: "Download PDF",
                            onPressed: () {
                              final pObj = webPh.parties.firstWhere((p) => p.name == item.partyName, orElse: () => Party(id: 'temp', name: item.partyName));
                              WebPdfRouterService.downloadSaleChallanPdf(challan: item, party: pObj, shop: activeShop);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                            tooltip: "Delete Challan",
                            onPressed: () {
                              webPh.deleteSaleChallan(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Sale Challan Removed!"), backgroundColor: Colors.redAccent));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL SALE CHALLANS: ${filtered.length}", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              Text("REGISTER VALUE: ₹${totalVal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFF2DD4BF), fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  // --- VIEW 5: PURCHASE CHALLANS REGISTER ---
  Widget _buildPurchaseRegister(PharoahWebManager webPh) {
    final activeShop = CompanyProfile.fromMap(webPh.companyProfile);
    final fDateOnly = _dateOnly(regFromDate);
    final tDateOnly = _dateOnly(regToDate);

    List<PurchaseChallan> list = List.from(webPh.purchaseChallans);
    list.sort((a, b) => b.date.compareTo(a.date));

    final filtered = list.where((c) {
      final cDateOnly = _dateOnly(c.date);
      bool dateMatch = !cDateOnly.isBefore(fDateOnly) && !cDateOnly.isAfter(tDateOnly);
      bool searchMatch = registerSearch.isEmpty ||
          c.distributorName.toLowerCase().contains(registerSearch.toLowerCase()) || 
          c.internalNo.toString().toLowerCase().contains(registerSearch.toLowerCase()) ||
          c.billNo.toString().toLowerCase().contains(registerSearch.toLowerCase());
      return dateMatch && searchMatch;
    }).toList();

    double totalVal = filtered.fold(0.0, (s, c) => s + c.totalAmount);

    return Column(
      children: [
        _buildRegisterFilterBar(
          webPh, 
          onPrintReport: () => WebPdfRouterService.printChallanReport(challans: filtered, shop: activeShop, from: regFromDate, to: regToDate, isSaleChallan: false),
        ),
        const SizedBox(height: 12),
        filtered.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(30), child: Text("No Inward Purchase Challans found.", style: TextStyle(color: Colors.white38))))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filtered.length,
                itemBuilder: (c, i) {
                  final item = filtered[i];
                  bool isPending = item.status == "Pending";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
                    child: ListTile(
                      dense: true,
                      leading: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(color: Color(0x33D97706), borderRadius: BorderRadius.all(Radius.circular(6))),
                        child: const Text("PUR CH", style: TextStyle(color: Color(0xFFFBBF24), fontSize: 9.5, fontWeight: FontWeight.bold)),
                      ),
                      title: Row(
                        children: [
                          Text(item.distributorName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 8),
                          _statusBadge(item.status.toUpperCase(), isPending),
                        ],
                      ),
                      subtitle: Text("ID: ${item.internalNo} • Ref: ${item.billNo} • Date: ${DateFormat('dd/MM/yyyy').format(item.date)} • Items: ${item.items.length}", style: const TextStyle(color: Colors.white38, fontSize: 10.5)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("₹${item.totalAmount.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFBBF24), fontWeight: FontWeight.w900, fontSize: 14)),
                          const SizedBox(width: 12),
                          IconButton(
                            icon: const Icon(Icons.print_outlined, color: Color(0xFF38BDF8), size: 18),
                            tooltip: "Print Inward Slip",
                            onPressed: () {
                              final pObj = webPh.parties.firstWhere((p) => p.name == item.distributorName, orElse: () => Party(id: 'temp', name: item.distributorName));
                              WebPdfRouterService.printPurchaseChallan(challan: item, party: pObj, shop: activeShop);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.download_rounded, color: Colors.greenAccent, size: 18),
                            tooltip: "Download PDF",
                            onPressed: () {
                              final pObj = webPh.parties.firstWhere((p) => p.name == item.distributorName, orElse: () => Party(id: 'temp', name: item.distributorName));
                              WebPdfRouterService.downloadPurchaseChallanPdf(challan: item, party: pObj, shop: activeShop);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
                            tooltip: "Delete Challan",
                            onPressed: () {
                              webPh.deletePurchaseChallan(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🗑️ Inward Challan Removed!"), backgroundColor: Colors.redAccent));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(10)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("TOTAL INWARD CHALLANS: ${filtered.length}", style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              Text("REGISTER VALUE: ₹${totalVal.toStringAsFixed(2)}", style: const TextStyle(color: Color(0xFFFBBF24), fontSize: 14, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFilterBar(PharoahWebManager webPh, {required VoidCallback onPrintReport}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _dateTile("FROM DATE", regFromDate, (d) => setState(() => regFromDate = d), webPh.financialYear)),
              const SizedBox(width: 10),
              Expanded(child: _dateTile("TO DATE", regToDate, (d) => setState(() => regToDate = d), webPh.financialYear)),
              const SizedBox(width: 14),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F766E), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                onPressed: onPrintReport,
                icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                label: const Text("PRINT REPORT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            style: const TextStyle(color: Colors.white, fontSize: 12),
            decoration: const InputDecoration(
              hintText: "Search in Challans Register (Party, Challan No)...",
              hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
              prefixIcon: Icon(Icons.search, color: Color(0xFF0F766E), size: 16),
              filled: true, fillColor: Colors.black26,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
            onChanged: (v) => setState(() => registerSearch = v),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, bool isPending) {
    Color bg = isPending ? const Color(0x33F59E0B) : const Color(0x3310B981);
    Color fg = isPending ? Colors.orangeAccent : Colors.greenAccent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4), border: Border.all(color: fg, width: 0.5)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 7.5, fontWeight: FontWeight.w900)),
    );
  }

  Widget _dateTile(String label, DateTime d, Function(DateTime) onPick, String fy) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: d,
          firstDate: WebAppDateLogic.getFYStart(fy),
          lastDate: WebAppDateLogic.getFYEnd(fy),
        );
        if (picked != null) onPick(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(color: Colors.black26, border: Border.all(color: Colors.white12), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 8.5, color: Colors.white54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(DateFormat('dd/MM/yyyy').format(d), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5)),
              ],
            ),
            const Icon(Icons.calendar_month_rounded, color: Color(0xFF38BDF8), size: 16),
          ],
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController ctrl, {bool isNum = false, bool isCaps = false, bool isHighlight = false, Function(String)? onChanged}) {
    return TextField(
      controller: ctrl,
      onChanged: onChanged,
      keyboardType: isNum ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      textCapitalization: isCaps ? TextCapitalization.characters : TextCapitalization.none,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 8.5, fontWeight: FontWeight.bold),
        filled: true,
        fillColor: isHighlight ? const Color(0x330F766E) : Colors.black26,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
    );
  }
}
CHALLAN_VIEW_EOF

# 4. Strict Analyzer Verification (0 Errors in lib/web_live_sync/)
echo -e "\033[1;33m[3/4] Running static analyzer on lib/web_live_sync/...\033[0m"
flutter analyze lib/web_live_sync/

# 5. Build and Deploy
echo -e "\033[1;33m[4/4] Compiling Web App & Deploying to Cloudflare Pages...\033[0m"
pkill -f "analysis_server" 2>/dev/null || true
pkill -f "dart_language_server" 2>/dev/null || true
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true

flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

npx wrangler pages deploy build/web --project-name=pharoah-erp --commit-dirty=true

git add .
git commit -m "Deploy 5-Button Challans Hub Live" || true
git push origin main || true

echo -e "\n\033[0;34m====================================================\033[0m"
echo -e "\033[0;32m  🎉 5 CHALLAN BUTTONS DEPLOYED LIVE SUCCESSFULLY!\033[0m"
echo -e "\033[0;32m  🌐 URL: https://pharoah-erp.pages.dev\033[0m"
echo -e "\033[0;34m====================================================\033[0m"
