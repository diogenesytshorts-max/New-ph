import 'web_sale_challan_view.dart';
// FILE: lib/web_live_sync/sub_views/web_challans/web_challan_hub.dart

import 'package:flutter/material.dart';

class WebChallanHub extends StatelessWidget {
  final VoidCallback onBack;

  const WebChallanHub({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: const Text("BACK TO DASHBOARD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 15),
              const Icon(Icons.local_shipping_rounded, color: Color(0xFF2DD4BF), size: 22),
              const SizedBox(width: 10),
              const Text(
                "CHALLAN MANAGEMENT HUB",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
              ),
            ],
          ),
          const SizedBox(height: 25),
          const Text(
            "PRIMARY BUSINESS DISPATCHES",
            style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5),
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              int crossAxisCount = constraints.maxWidth > 900 ? 4 : (constraints.maxWidth > 600 ? 2 : 1);

              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
                children: [
                  _appModuleCard(
                    context,
                    title: "Sale Challan",
                    subtitle: "Outward Delivery Note",
                    icon: Icons.local_shipping_rounded,
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (c) => const WebSaleChallanView()));
                    },
                  ),
                  _appModuleCard(
                    context,
                    title: "Pur Challan",
                    subtitle: "Inward Purchase Note",
                    icon: Icons.inventory_2_rounded,
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proceeding to Step 2: Pur Challan Entry...")));
                    },
                  ),
                  _appModuleCard(
                    context,
                    title: "Sale Reg",
                    subtitle: "Outward Registers",
                    icon: Icons.list_alt_rounded,
                    color: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proceeding to Step 2: Sale Register...")));
                    },
                  ),
                  _appModuleCard(
                    context,
                    title: "Pur Reg",
                    subtitle: "Inward Registers",
                    icon: Icons.history_edu_rounded,
                    color: Colors.amber.shade800,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Proceeding to Step 2: Purchase Register...")));
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _appModuleCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha(25),
              blurRadius: 15,
              offset: const Offset(0, 5),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(color: color.withAlpha(230), fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
