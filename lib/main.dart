import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'models/item.dart';
import 'services/firestore_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return MaterialApp(
      title: 'Inventory App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: Scaffold(
        appBar: AppBar(title: const Text('Inventory')),
        body: StreamBuilder<List<Item>>(
          stream: service.streamItems(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) return Text('Error: ${snapshot.error}');
            final items = snapshot.data ?? [];
            if (items.isEmpty)
              return const Center(child: Text('No items yet.'));
            return ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => ListTile(
                title: Text(items[i].name),
                subtitle: Text(
                  "Qty: ${items[i].quantity} | \$${items[i].price.toStringAsFixed(2)}",
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => service.deleteItem(items[i].id),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
