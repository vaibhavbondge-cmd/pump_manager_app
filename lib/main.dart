import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() {
  runApp(const PumpApp());
}

class PumpApp extends StatelessWidget {
  const PumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Shri Ganesh Petroleum',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const OwnerDashboard(),
    );
  }
}

class OwnerDashboard extends StatelessWidget {
  const OwnerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shri Ganesh Petroleum Togari"),
        centerTitle: true,
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(12),
        crossAxisCount: 2,
        children: [
          _card(context, "Add Sales", Icons.local_gas_station,
              const SalesEntryScreen()),
          _card(context, "History", Icons.history,
              const HistoryScreen()),
        ],
      ),
    );
  }

  Widget _card(
      BuildContext context, String title, IconData icon, Widget screen) {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context,
              MaterialPageRoute(builder: (_) => screen)),
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.blue),
            const SizedBox(height: 10),
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class SalesEntryScreen extends StatefulWidget {
  const SalesEntryScreen({super.key});

  @override
  State<SalesEntryScreen> createState() =>
      _SalesEntryScreenState();
}

class _SalesEntryScreenState extends State<SalesEntryScreen> {
  final petrol = TextEditingController();
  final diesel = TextEditingController();
  final cash = TextEditingController();
  final upi = TextEditingController();

  double total = 0;

  String today =
      DateTime.now().toString().substring(0, 10);

  void calculate() {
    double p = double.tryParse(petrol.text) ?? 0;
    double d = double.tryParse(diesel.text) ?? 0;
    total = p + d;
    setState(() {});
  }

  Future<void> saveData() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    List<String> list =
        prefs.getStringList("sales") ?? [];

    Map<String, dynamic> data = {
      "date": today,
      "petrol": petrol.text,
      "diesel": diesel.text,
      "cash": cash.text,
      "upi": upi.text,
      "total": total.toString()
    };

    list.add(jsonEncode(data));
    await prefs.setStringList("sales", list);

    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Saved")));

    petrol.clear();
    diesel.clear();
    cash.clear();
    upi.clear();
  }

  Widget field(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(10))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Sales Entry ($today)")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            field("Petrol Sale ₹", petrol),
            field("Diesel Sale ₹", diesel),

            ElevatedButton(
                onPressed: calculate,
                child: const Text("Calculate")),

            Text("Total: ₹ $total",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),

            const Divider(),

            field("Cash", cash),
            field("UPI", upi),

            const SizedBox(height: 20),

            ElevatedButton(
                onPressed: saveData,
                child: const Text("Save"))
          ],
        ),
      ),
    );
  }
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() =>
      _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List data = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();
    List<String> list =
        prefs.getStringList("sales") ?? [];

    data = list
        .map((e) => jsonDecode(e))
        .toList()
        .reversed
        .toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("History")),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (c, i) {
          var d = data[i];
          return Card(
            child: ListTile(
              title: Text("Date: ${d['date']}"),
              subtitle: Text(
                  "Total: ₹ ${d['total']}"),
            ),
          );
        },
      ),
    );
  }
}