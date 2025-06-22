import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import 'database/app_database.dart';
import 'database/database_instance.dart';
import 'screens/calendar_view.dart';
import 'widgets/client_form.dart';
import 'widgets/client_tile.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dasturvachcha',
      theme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ValueNotifier<List<Client>> clientsNotifier = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final clientsFromDb = await (db.select(db.clients)
        ..where((tbl) => tbl.completed.equals(false)))
        .get();
    clientsFromDb.sort((a, b) => a.date.compareTo(b.date));
    clientsNotifier.value = clientsFromDb;
  }

  Future<void> _addClient(Client newClient) async {
    await db.into(db.clients).insert(ClientsCompanion(
      name: drift.Value(newClient.name),
      phone: drift.Value(newClient.phone),
      address: drift.Value(newClient.address),
      notes: drift.Value(newClient.notes),
      date: drift.Value(newClient.date),
      completed: const drift.Value(false),
    ));
    await _loadClients();
  }

  void _showClientForm() {
    showDialog(
      context: context,
      builder: (_) => ClientForm(
        onSave: (newClient) async {
          await _addClient(newClient);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  @override
  void dispose() {
    clientsNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejalashtirgich'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CalendarView(clientsNotifier: clientsNotifier),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: ValueListenableBuilder<List<Client>>(
          valueListenable: clientsNotifier,
          builder: (context, clients, _) {
            if (clients.isEmpty) {
              return const Center(child: Text("Buyurtmalar yo‘q"));
            }
            return ListView.builder(
              itemCount: clients.length,
              itemBuilder: (context, index) {
                return ClientTile(
                  client: clients[index],
                  clientsNotifier: clientsNotifier,
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showClientForm,
        child: const Icon(Icons.add),
      ),
    );
  }
}

