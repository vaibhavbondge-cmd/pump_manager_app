import 'package:flutter/material.dart';

void main() {
  runApp(const PumpApp());
}

class PumpApp extends StatelessWidget {
  const PumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pump Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/* ================= MODELS ================= */

class PurchaseEntry {
  final DateTime date;
  final double petrolQty;
  final double petrolPrice;
  final double dieselQty;
  final double dieselPrice;

  PurchaseEntry({
    required this.date,
    required this.petrolQty,
    required this.petrolPrice,
    required this.dieselQty,
    required this.dieselPrice,
  });
}

class MeterEntry {
  final DateTime date;
  final double petrolOpen;
  final double petrolClose;
  final double dieselOpen;
  final double dieselClose;

  MeterEntry({
    required this.date,
    required this.petrolOpen,
    required this.petrolClose,
    required this.dieselOpen,
    required this.dieselClose,
  });

  double get petrolSale => petrolClose - petrolOpen;
  double get dieselSale => dieselClose - dieselOpen;
}

/* ================= HOME ================= */

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<PurchaseEntry> purchases = [];
  List<MeterEntry> meters = [];

  double petrolStock = 0;
  double dieselStock = 0;

  double totalProfit = 0;

  /* Controllers */

  final petrolQtyCtrl = TextEditingController();
  final petrolPriceCtrl = TextEditingController();
  final dieselQtyCtrl = TextEditingController();
  final dieselPriceCtrl = TextEditingController();

  final petrolOpenCtrl = TextEditingController();
  final petrolCloseCtrl = TextEditingController();
  final dieselOpenCtrl = TextEditingController();
  final dieselCloseCtrl = TextEditingController();

  /* ================= PURCHASE ================= */

  void addPurchase() {
    double pQty = double.tryParse(petrolQtyCtrl.text) ?? 0;
    double pPrice = double.tryParse(petrolPriceCtrl.text) ?? 0;
    double dQty = double.tryParse(dieselQtyCtrl.text) ?? 0;
    double dPrice = double.tryParse(dieselPriceCtrl.text) ?? 0;

    purchases.add(
      PurchaseEntry(
        date: DateTime.now(),
        petrolQty: pQty,
        petrolPrice: pPrice,
        dieselQty: dQty,
        dieselPrice: dPrice,
      ),
    );

    petrolStock += pQty;
    dieselStock += dQty;

    clearFields();
    setState(() {});
  }

  /* ================= METER ================= */

  void addMeter() {
    double pOpen = double.tryParse(petrolOpenCtrl.text) ?? 0;
    double pClose = double.tryParse(petrolCloseCtrl.text) ?? 0;
    double dOpen = double.tryParse(dieselOpenCtrl.text) ?? 0;
    double dClose = double.tryParse(dieselCloseCtrl.text) ?? 0;

    MeterEntry entry = MeterEntry(
      date: DateTime.now(),
      petrolOpen: pOpen,
      petrolClose: pClose,
      dieselOpen: dOpen,
      dieselClose: dClose,
    );

    meters.add(entry);

    petrolStock -= entry.petrolSale;
    dieselStock -= entry.dieselSale;

    // Simple profit logic (you can improve later)
    totalProfit += (entry.petrolSale * 3) + (entry.dieselSale * 2);

    clearFields();
    setState(() {});
  }

  void clearFields() {
    petrolQtyCtrl.clear();
    petrolPriceCtrl.clear();
    dieselQtyCtrl.clear();
    dieselPriceCtrl.clear();
    petrolOpenCtrl.clear();
    petrolCloseCtrl.clear();
    dieselOpenCtrl.clear();
    dieselCloseCtrl.clear();
  }

  /* ================= UI ================= */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pump Manager"),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => HistoryScreen(
                    purchases: purchases,
                    meters: meters,
                  ),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            dashboardCard(),
            const SizedBox(height: 10),
            purchaseCard(),
            const SizedBox(height: 10),
            meterCard(),
          ],
        ),
      ),
    );
  }

  Widget dashboardCard() {
    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        title: const Text("Dashboard"),
        subtitle: Text(
          "Petrol Stock: $petrolStock L\n"
          "Diesel Stock: $dieselStock L\n"
          "Total Profit: ₹$totalProfit",
        ),
      ),
    );
  }

  Widget purchaseCard() {
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text("Purchase Entry")),
          field(petrolQtyCtrl, "Petrol Qty"),
          field(petrolPriceCtrl, "Petrol Price"),
          field(dieselQtyCtrl, "Diesel Qty"),
          field(dieselPriceCtrl, "Diesel Price"),
          ElevatedButton(
            onPressed: addPurchase,
            child: const Text("Add Purchase"),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget meterCard() {
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text("Meter Reading")),
          field(petrolOpenCtrl, "Petrol Opening"),
          field(petrolCloseCtrl, "Petrol Closing"),
          field(dieselOpenCtrl, "Diesel Opening"),
          field(dieselCloseCtrl, "Diesel Closing"),
          ElevatedButton(
            onPressed: addMeter,
            child: const Text("Add Meter Entry"),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget field(TextEditingController c, String label) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}

/* ================= HISTORY SCREEN ================= */

class HistoryScreen extends StatelessWidget {
  final List<PurchaseEntry> purchases;
  final List<MeterEntry> meters;

  const HistoryScreen({
    super.key,
    required this.purchases,
    required this.meters,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView(
        children: [
          const ListTile(title: Text("Purchases")),
          ...purchases.map((p) => ListTile(
                title: Text(
                    "Petrol ${p.petrolQty}L | Diesel ${p.dieselQty}L"),
                subtitle: Text(p.date.toString()),
              )),
          const Divider(),
          const ListTile(title: Text("Meter Entries")),
          ...meters.map((m) => ListTile(
                title: Text(
                    "Petrol Sale ${m.petrolSale}L | Diesel Sale ${m.dieselSale}L"),
                subtitle: Text(m.date.toString()),
              )),
        ],
      ),
    );
  }
}