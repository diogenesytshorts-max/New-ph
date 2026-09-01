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
echo -e "\033[0;34m   🚀 FIXING LAYOUT & DEPLOYING 5 CHALLAN MODULES   \033[0m"
echo -e "\033[0;34m====================================================\033[0m\n"

# 2. Update Top Bar to always display Company's real PH-LIVE Store Token
echo -e "\033[1;33m[1/4] Updating Top Bar with dynamic PH-LIVE token...\033[0m"
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
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                webPh.companyName.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
              Row(
                children: [
                  Text(
                    "FY: ${webPh.financialYear}",
                    style: const TextStyle(
                      fontSize: 9.5,
                      color: Color(0xFF38BDF8),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                    decoration: BoxDecoration(
                      color: const Color(0x2610B981),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.greenAccent, width: 0.5),
                    ),
                    child: Text(
                      webPh.activeStoreToken.isNotEmpty ? webPh.activeStoreToken : "#PH-LIVE",
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 8, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 36,
              constraints: const BoxConstraints(maxWidth: 380),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                style: const TextStyle(color: Colors.white, fontSize: 11.5),
                decoration: const InputDecoration(
                  hintText: "Search Medicines, Customers, Invoices...",
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 11),
                  prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF38BDF8), size: 16),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 9),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0x1F10B981),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x4D10B981)),
            ),
            child: const Row(
              children: [
                Icon(Icons.circle, color: Colors.greenAccent, size: 7),
                SizedBox(width: 6),
                Text(
                  "LIVE CLOUD",
                  style: TextStyle(
                    color: Colors.greenAccent,
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: const Icon(Icons.sync_rounded, color: Colors.white70, size: 20),
            tooltip: "Refresh Live Data",
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

# 3. Create 100% Non-Collapsing 5-Button WebChallanView
echo -e "\033[1;33m[2/4] Writing crash-free 5-Button web_challan_view.dart...\033[0m"
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
      width: double.infinity,
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

          // 5 PROMINENT BUTTONS BAR
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

          // 5 SOLID WORKSTATION MODULES (No unbounded height collapse)
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
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: scItems.isEmpty
              ? const Padding(padding: EdgeInsets.all(25), child: Center(child: Text("No items in delivery challan cart. Search products above.", style: TextStyle(color: Colors.white38, fontSize: 11.5))))
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
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12)),
          child: pcItems.isEmpty
              ? const Padding(padding: EdgeInsets.all(25), child: Center(child: Text("No items in inward challan. Search products above.", style: TextStyle(color: Colors.white38, fontSize: 11.5))))
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

# 4. Clean WebChallanStitcherWizard (Remove unbounded Expanded for 100% stable embedding)
echo -e "\033[1;33m[3/4] Updating web_challan_stitcher_wizard.dart...\033[0m"
cat << 'STITCHER_EOF' > lib/web_live_sync/web_challan_stitcher_wizard.dart
// FILE: lib/web_live_sync/web_challan_stitcher_wizard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'web_models.dart';
import 'pharoah_web_manager.dart';
import 'web_app_date_logic.dart';
import 'web_pharoah_numbering_engine.dart';
import 'web_pdf_router_service.dart';

class WebChallanStitcherWizard extends StatefulWidget {
  final VoidCallback onBack;

  const WebChallanStitcherWizard({super.key, required this.onBack});

  @override
  State<WebChallanStitcherWizard> createState() => _WebChallanStitcherWizardState();
}

class _WebChallanStitcherWizardState extends State<WebChallanStitcherWizard> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  String funnelStep = "MODE"; // MODE -> ROUTE -> PARTY -> REVIEW
  String selectionMode = "NONE";
  bool isProcessing = false;
  double progressValue = 0.0;
  String progressText = "";

  DateTime batchBillDate = DateTime.now();
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime.now();
  String? selectedRoute;
  List<String> selectedPartyNames = [];
  List<Map<String, dynamic>> draftBills = [];
  String partySearch = "";

  final List<String> fyMonths = ["April", "May", "June", "July", "August", "September", "October", "November", "December", "January", "February", "March"];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final webPh = Provider.of<PharoahWebManager>(context, listen: false);
    batchBillDate = WebAppDateLogic.getSmartDate(webPh.financialYear);
    fromDate = WebAppDateLogic.getFYStart(webPh.financialYear);
    toDate = WebAppDateLogic.getSmartDate(webPh.financialYear);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _generateDrafts(PharoahWebManager webPh) {
    setState(() => isProcessing = true);
    List<Map<String, dynamic>> temp = [];
    bool isSale = _tabController.index == 0;

    for (var pName in selectedPartyNames) {
      Party? pObj;
      try {
        pObj = webPh.parties.firstWhere((p) => p.name == pName);
      } catch (_) {
        pObj = Party(id: 'temp', name: pName);
      }

      var chs = isSale
          ? webPh.saleChallans.where((c) => c.partyName.trim().toUpperCase() == pName.trim().toUpperCase() && c.status == "Pending").toList()
          : webPh.purchaseChallans.where((c) => c.distributorName.trim().toUpperCase() == pName.trim().toUpperCase() && c.status == "Pending").toList();

      if (chs.isEmpty) continue;

      List<dynamic> combinedItems = [];
      for (var c in chs) {
        if (isSale) {
          SaleChallan act = c as SaleChallan;
          for (var it in act.items) {
            combinedItems.add(it.copyWith(sourceChallanNo: act.billNo, sourceChallanId: act.id));
          }
        } else {
          PurchaseChallan act = c as PurchaseChallan;
          for (var it in act.items) {
            combinedItems.add(it.copyWith(sourceChallanNo: act.billNo, sourceChallanId: act.id));
          }
        }
      }

      double total = combinedItems.fold(0.0, (s, i) => s + (i.total as double));

      temp.add({
        'party': pObj,
        'billNo': 'DRAFT',
        'date': batchBillDate,
        'items': combinedItems,
        'total': total,
        'status': 'DRAFT',
        'isSelected': true,
        'challanIds': chs.map((c) => isSale ? (c as SaleChallan).id : (c as PurchaseChallan).id).toList(),
      });
    }

    setState(() {
      draftBills = temp;
      funnelStep = "REVIEW";
      isProcessing = false;
    });
  }

  Future<void> _handleBatchSave(PharoahWebManager webPh) async {
    var selected = draftBills.where((b) => b['isSelected'] && b['status'] == 'DRAFT').toList();
    if (selected.isEmpty) return;

    setState(() { isProcessing = true; progressText = "Finalizing Batch..."; progressValue = 0.5; });
    bool isSale = _tabController.index == 0;

    if (isSale) {
      String prefix = "INV-";
      int start = 101;
      try {
        final defSeries = webPh.numberingSeries.firstWhere((s) => s.type == "SALE" && s.isDefault && s.isActive);
        prefix = defSeries.prefix;
        start = defSeries.startNumber;
      } catch (_) {}

      for (var b in selected) {
        String finalBillNo = WebPharoahNumberingEngine.getNextNumber(prefix: prefix, startFrom: start, currentList: webPh.sales);
        final Party pRef = b['party'] as Party;
        final newSale = Sale(
          id: "SALE-WEB-${DateTime.now().millisecondsSinceEpoch}-$finalBillNo", billNo: finalBillNo, partyId: pRef.id, partyName: pRef.name, partyGstin: pRef.gst, partyState: pRef.state, partyAddress: pRef.address, partyCity: pRef.city, partyPhone: pRef.phone, partyEmail: pRef.email, partyDl: pRef.dl, partyPan: pRef.pan, date: b['date'], paymentMode: "CREDIT", totalAmount: b['total'], items: (b['items'] as List).cast<BillItem>(), linkedChallanIds: List<String>.from(b['challanIds']), sourceTag: "WEB-PORTAL",
        );
        webPh.sales.add(newSale);
        for (var cId in b['challanIds']) {
          int idx = webPh.saleChallans.indexWhere((c) => c.id == cId);
          if (idx != -1) webPh.saleChallans[idx].status = "Billed";
        }
        b['status'] = 'SAVED'; b['billNo'] = finalBillNo;
      }
    } else {
      for (var b in selected) {
        String finalInternalNo = WebPharoahNumberingEngine.getNextNumber(prefix: "PUR-", startFrom: 1, currentList: webPh.purchases);
        final Party pRef = b['party'] as Party;
        final newPurchase = Purchase(
          id: "PUR-WEB-${DateTime.now().millisecondsSinceEpoch}-$finalInternalNo", internalNo: finalInternalNo, billNo: "CH-CONV-${finalInternalNo.replaceAll('PUR-', '')}", partyId: pRef.id, distributorName: pRef.name, date: b['date'], entryDate: DateTime.now(), paymentMode: "CREDIT", totalAmount: b['total'], items: (b['items'] as List).cast<PurchaseItem>(), linkedChallanIds: List<String>.from(b['challanIds']), sourceTag: "WEB-PORTAL",
        );
        webPh.purchases.add(newPurchase);
        for (var cId in b['challanIds']) {
          int idx = webPh.purchaseChallans.indexWhere((c) => c.id == cId);
          if (idx != -1) webPh.purchaseChallans[idx].status = "Billed";
        }
        b['status'] = 'SAVED'; b['billNo'] = finalInternalNo;
      }
    }

    webPh.rebuildInventory();
    await webPh.pushUpdatedDataToCloud();
    setState(() => isProcessing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("✅ ${selected.length} Invoices Created from Challans!"), backgroundColor: Colors.green));
    }
  }

  @override
  Widget build(BuildContext context) {
    final webPh = Provider.of<PharoahWebManager>(context);
    bool isSale = _tabController.index == 0;
    Color color = isSale ? const Color(0xFF2563EB) : const Color(0xFFD97706);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white70),
                onPressed: funnelStep != "MODE" ? () => setState(() => funnelStep = "MODE") : widget.onBack,
              ),
              const SizedBox(width: 8),
              const Text("CHALLAN TO BILL STITCHER WIZARD", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              const Spacer(),
              if (funnelStep == "MODE")
                SizedBox(
                  width: 320,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: color,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white54,
                    tabs: const [Tab(text: "OUTWARD CHALLANS"), Tab(text: "INWARD CHALLANS")],
                  ),
                ),
            ],
          ),
          const Divider(color: Colors.white10, height: 20),

          if (isProcessing)
            Padding(
              padding: const EdgeInsets.all(30),
              child: Center(child: Column(children: [CircularProgressIndicator(color: color), const SizedBox(height: 12), Text(progressText, style: const TextStyle(color: Colors.white, fontSize: 12))])),
            )
          else ...[
            if (funnelStep == "MODE") _buildModeStep(webPh, color),
            if (funnelStep == "ROUTE") _buildRouteStep(webPh, color),
            if (funnelStep == "PARTY") _buildPartyStep(webPh, color),
            if (funnelStep == "REVIEW") _buildReviewStep(webPh, color),
          ]
        ],
      ),
    );
  }

  Widget _buildModeStep(PharoahWebManager webPh, Color color) {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _showMonthPicker(webPh.financialYear),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withAlpha(100))),
                child: Column(
                  children: [
                    Icon(Icons.calendar_month_rounded, color: color, size: 28),
                    const SizedBox(height: 10),
                    const Text("MONTHLY BATCH STITCH", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    const SizedBox(height: 4),
                    const Text("Select a financial month to convert", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: InkWell(
              onTap: () => _pickCustomRange(webPh.financialYear),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF2DD4BF))),
                child: const Column(
                  children: [
                    Icon(Icons.date_range_rounded, color: Color(0xFF2DD4BF), size: 28),
                    SizedBox(height: 10),
                    Text("CUSTOM DATE RANGE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.5)),
                    SizedBox(height: 4),
                    Text("Choose custom date period in FY", style: TextStyle(color: Colors.white54, fontSize: 10)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMonthPicker(String fy) {
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("Select Month", style: TextStyle(color: Colors.white, fontSize: 14)),
        content: SizedBox(
          width: 300,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: fyMonths.length,
            itemBuilder: (ctx, i) => ListTile(
              title: Text(fyMonths[i], style: const TextStyle(color: Colors.white, fontSize: 12)),
              onTap: () {
                Navigator.pop(c);
                int yr = int.parse(fy.split('-')[0]); if (yr < 2000) yr += 2000;
                int tM = i + 4; if (tM > 12) { tM -= 12; yr++; }
                setState(() { fromDate = DateTime(yr, tM, 1); toDate = DateTime(yr, tM + 1, 0); funnelStep = "ROUTE"; selectionMode = "MONTHLY"; });
              },
            ),
          ),
        ),
      ),
    );
  }

  void _pickCustomRange(String fy) async {
    final picked = await showDateRangePicker(context: context, firstDate: WebAppDateLogic.getFYStart(fy), lastDate: WebAppDateLogic.getFYEnd(fy));
    if (picked != null) {
      setState(() { fromDate = picked.start; toDate = picked.end; funnelStep = "ROUTE"; selectionMode = "CUSTOM"; });
    }
  }

  Widget _buildRouteStep(PharoahWebManager webPh, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("STEP 2: FILTER BY AREA / ROUTE", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ListTile(
          tileColor: Colors.black26, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: const BorderSide(color: Color(0xFF2DD4BF))),
          leading: const Icon(Icons.done_all, color: Color(0xFF2DD4BF)),
          title: const Text("SHOW ALL ROUTES / CUSTOMERS", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          onTap: () => setState(() { selectedRoute = null; funnelStep = "PARTY"; }),
        ),
        const SizedBox(height: 10),
        ...webPh.routes.map((r) => Container(
          margin: const EdgeInsets.only(bottom: 6),
          decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            dense: true, title: Text(r.name, style: const TextStyle(color: Colors.white70, fontSize: 11.5)),
            onTap: () => setState(() { selectedRoute = r.name; funnelStep = "PARTY"; }),
          ),
        )),
      ],
    );
  }

  Widget _buildPartyStep(PharoahWebManager webPh, Color color) {
    bool isSale = _tabController.index == 0;
    final list = webPh.parties.where((p) {
      bool hasPending = isSale
          ? webPh.saleChallans.any((c) => c.partyName.trim().toUpperCase() == p.name.trim().toUpperCase() && c.status == "Pending")
          : webPh.purchaseChallans.any((c) => c.distributorName.trim().toUpperCase() == p.name.trim().toUpperCase() && c.status == "Pending");
      bool matchesRoute = selectedRoute == null || p.route == selectedRoute;
      return hasPending && matchesRoute;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("STEP 3: SELECT PARTIES TO STITCH", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () => setState(() {
                if (selectedPartyNames.length == list.length) {
                  selectedPartyNames.clear();
                } else {
                  selectedPartyNames = list.map((e) => e.name).toList();
                }
              }),
              child: Text(selectedPartyNames.length == list.length ? "UNSELECT ALL" : "SELECT ALL", style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 11)),
            )
          ],
        ),
        const SizedBox(height: 10),
        if (list.isEmpty)
          const Padding(padding: EdgeInsets.all(25), child: Center(child: Text("No parties with pending challans.", style: TextStyle(color: Colors.white38, fontSize: 11))))
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: list.length,
            itemBuilder: (c, i) {
              final p = list[i];
              bool isChecked = selectedPartyNames.contains(p.name);
              return CheckboxListTile(
                dense: true,
                activeColor: color,
                value: isChecked,
                title: Text(p.name, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                subtitle: Text("${p.city} • Route: ${p.route}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                onChanged: (v) => setState(() { v == true ? selectedPartyNames.add(p.name) : selectedPartyNames.remove(p.name); }),
              );
            },
          ),
        if (selectedPartyNames.isNotEmpty) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity, height: 44,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
              onPressed: () => _generateDrafts(webPh),
              icon: const Icon(Icons.auto_fix_high_rounded, size: 16),
              label: Text("STITCH ${selectedPartyNames.length} INVOICES", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          )
        ]
      ],
    );
  }

  Widget _buildReviewStep(PharoahWebManager webPh, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("REVIEW STITCHED DRAFTS (${draftBills.length})", style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              onPressed: () => _handleBatchSave(webPh),
              icon: const Icon(Icons.save_rounded, size: 14),
              label: const Text("SAVE ALL INVOICES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
            )
          ],
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: draftBills.length,
          itemBuilder: (c, i) {
            final b = draftBills[i];
            bool isSaved = b['status'] == 'SAVED';

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(8), border: Border.all(color: isSaved ? Colors.greenAccent : Colors.white10)),
              child: ListTile(
                dense: true,
                title: Text(b['party'].name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                subtitle: Text("Items: ${(b['items'] as List).length} • Status: ${b['status']}", style: const TextStyle(color: Colors.white54, fontSize: 10)),
                trailing: Text("₹${(b['total'] as double).toStringAsFixed(2)}", style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            );
          },
        ),
      ],
    );
  }
}
STITCHER_EOF

# 5. Clean RAM, Fast Compile & Live Upload
echo -e "\033[1;33m[4/4] Freeing RAM, Compiling & Deploying to Cloudflare Pages...\033[0m"
pkill -f "analysis_server" 2>/dev/null || true
pkill -f "dart_language_server" 2>/dev/null || true
sync
echo 3 | sudo tee /proc/sys/vm/drop_caches 2>/dev/null || true

flutter build web -t lib/web_live_sync/web_main.dart --release --base-href "/" --pwa-strategy=none --no-tree-shake-icons --dart2js-optimization=O1

npx wrangler pages deploy build/web --project-name=pharoah-erp --commit-dirty=true

git add .
git commit -m "Fix Layout Collapse & Live Deploy 5 Challan Buttons with Store Token" || true
git push origin main || true

echo -e "\n\033[0;34m====================================================\033[0m"
echo -e "\033[0;32m  🎉 5 CHALLAN BUTTONS LIVE & DEPLOYED SUCCESSFULLY!\033[0m"
echo -e "\033[0;32m  🌐 LIVE AT: https://pharoah-erp.pages.dev\033[0m"
echo -e "\033[0;34m====================================================\033[0m"
