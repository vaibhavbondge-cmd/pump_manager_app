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

class ShiftEntry {
  final DateTime date;
  final double petrolSale;
  final double dieselSale;

  ShiftEntry({
    required this.date,
    required this.petrolSale,
    required this.dieselSale,
  });
}

class PurchaseEntry {
  final DateTime date;
  final double petrolPrice;
  final double dieselPrice;
  final double petrolQty;
  final double dieselQty;

  PurchaseEntry({
    required this.date,
    required this.petrolPrice,
    required this.dieselPrice,
    required this.petrolQty,
    required this.dieselQty,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final petrolController = TextEditingController();
  final dieselController = TextEditingController();

  final purchasePetrolPrice = TextEditingController();
  final purchaseDieselPrice = TextEditingController();
  final purchasePetrolQty = TextEditingController();
  final purchaseDieselQty = TextEditingController();

  List<ShiftEntry> shifts = [];
  List<PurchaseEntry> purchases = [];

  double get latestPetrolPrice =>
      purchases.isEmpty ? 0 : purchases.last.petrolPrice;

  double get latestDieselPrice =>
      purchases.isEmpty ? 0 : purchases.last.dieselPrice;

  void addShift() {
    final petrol = double.tryParse(petrolController.text) ?? 0;
    final diesel = double.tryParse(dieselController.text) ?? 0;

    setState(() {
      shifts.add(ShiftEntry(
        date: DateTime.now(),
        petrolSale: petrol,
        dieselSale: diesel,
      ));
    });

    petrolController.clear();
    dieselController.clear();
  }

  void addPurchase() {
    final petrolPrice = double.tryParse(purchasePetrolPrice.text) ?? 0;
    final dieselPrice = double.tryParse(purchaseDieselPrice.text) ?? 0;
    final petrolQty = double.tryParse(purchasePetrolQty.text) ?? 0;
    final dieselQty = double.tryParse(purchaseDieselQty.text) ?? 0;

    setState(() {
      purchases.add(PurchaseEntry(
        date: DateTime.now(),
        petrolPrice: petrolPrice,
        dieselPrice: dieselPrice,
        petrolQty: petrolQty,
        dieselQty: dieselQty,
      ));
    });

    purchasePetrolPrice.clear();
    purchaseDieselPrice.clear();
    purchasePetrolQty.clear();
    purchaseDieselQty.clear();
  }

  double get totalPetrolSale =>
      shifts.fold(0, (sum, item) => sum + item.petrolSale);

  double get totalDieselSale =>
      shifts.fold(0, (sum, item) => sum + item.dieselSale);

  double get profit {
    if (purchases.isEmpty) return 0;

    double petrolProfit = totalPetrolSale * (110 - latestPetrolPrice);
    double dieselProfit = totalDieselSale * (95 - latestDieselPrice);

    return petrolProfit + dieselProfit;
  }

  void openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => HistoryScreen(
          shifts: shifts,
          purchases: purchases,
        ),
      ),
    );
  }

  Widget box(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),
              Text(value, style: const TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pump Manager'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: openHistory,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            const Text("Add Shift", style: TextStyle(fontSize: 18)),

            TextField(
              controller: petrolController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Petrol Sale (L)"),
            ),
            TextField(
              controller: dieselController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Diesel Sale (L)"),
            ),
            ElevatedButton(onPressed: addShift, child: const Text("Add Shift")),

            const Divider(),

            const Text("Add Purchase", style: TextStyle(fontSize: 18)),

            TextField(
              controller: purchasePetrolPrice,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Petrol Purchase Price"),
            ),
            TextField(
              controller: purchaseDieselPrice,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Diesel Purchase Price"),
            ),
            TextField(
              controller: purchasePetrolQty,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Petrol Quantity (L)"),
            ),
            TextField(
              controller: purchaseDieselQty,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(labelText: "Diesel Quantity (L)"),
            ),
            ElevatedButton(
                onPressed: addPurchase, child: const Text("Add Purchase")),

            const Divider(),

            Row(
              children: [
                box("Petrol Sale", totalPetrolSale.toStringAsFixed(2)),
                box("Diesel Sale", totalDieselSale.toStringAsFixed(2)),
              ],
            ),
            Row(
              children: [
                box("Profit", profit.toStringAsFixed(2)),
                box("Shifts", shifts.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatelessWidget {
  final List<ShiftEntry> shifts;
  final List<PurchaseEntry> purchases;

  const HistoryScreen({
    super.key,
    required this.shifts,
    required this.purchases,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView(
        children: [
          const ListTile(
            title: Text("Shift History",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...shifts.map((s) => ListTile(
                title: Text(
                    "${s.date.toLocal().toString().split(' ')[0]} - Petrol: ${s.petrolSale}L Diesel: ${s.dieselSale}L"),
              )),

          const Divider(),

          const ListTile(
            title: Text("Purchase History",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ...purchases.map((p) => ListTile(
                title: Text(
                    "${p.date.toLocal().toString().split(' ')[0]} - Petrol ₹${p.petrolPrice} Diesel ₹${p.dieselPrice}"),
                subtitle:
                    Text("Qty: Petrol ${p.petrolQty}L | Diesel ${p.dieselQty}L"),
              )),
        ],
      ),
    );
  }
}