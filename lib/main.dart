import 'package:flutter/material.dart';
import 'package:hello_flutter/widgets/client_form.dart';
import 'models/client.dart';
import 'widgets/client_tile.dart';
import 'screens/calendar_view.dart';


void main() {
    runApp(const MyApp());
}

class MyApp extends StatelessWidget {
    const MyApp({super.key});

    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'Dasturvachcha',
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            themeMode: ThemeMode.system,
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
    ValueNotifier< List<Client> > clientsNotifier = ValueNotifier<List<Client>>([
    Client(
      name: 'Alice Smith',
      phone: '+123456789',
      date: DateTime.now().add(const Duration(days: 5)),
      notes: 'Prefers morning appointments.',
      address: "Shayxontoxur 15",
    ),
    Client(
      name: 'Bob Johnson',
      phone: '+987654321',
      date: DateTime.now().add(const Duration(days: 12)),
      notes: 'Brings dog, needs extra time.',
      address: "Amerikada krch",
    ),
    Client(
      name: 'Charlie Rose',
      phone: '+1122334455',
      date: DateTime.now().add(const Duration(days: 2)),
      notes: 'VIP client, send reminder 1 day before.',
      address: "Qo'shtepa street",
    ),
  ]);

    @override
    void dispose() {
        clientsNotifier.dispose();
        super.dispose();
    }
    void _showClientForm() {
        showDialog(
          context: context,
          builder: (_) => ClientForm(
            onSave: (newClient) {
                List<Client> clients = clientsNotifier.value;
                clients.add(newClient);
                clients.sort(Client.compareByDate);
                clientsNotifier.value = [...clients];
            }
          ),
    );
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
                    IconButton(
                        icon: const Icon(Icons.brightness_6),
                        onPressed: () {}, // TODO theme toggle logic here
                    ),
                ],
            ),
            body: Padding(
                padding: const EdgeInsets.only(
                    bottom: 80, // FloatingPoint yopib qo'ymasligi uchun
                    // hardcode qilganim uchun kechiringlar :'(
                ),
                child: ValueListenableBuilder<List<Client>>(
                    valueListenable: clientsNotifier,
                    builder: (context, clients, _) {
                        return ListView.builder(
                            itemCount: clients.length,
                            itemBuilder: (context, index) {
                                return ClientTile(
                                    client: clients[index],
                                    clientsNotifier: clientsNotifier,
                                );
                            },
                        );
                    }
                )
            ),

            floatingActionButton: FloatingActionButton(
                onPressed: () => _showClientForm(),
                child: const Icon(Icons.add),
            ),
        );
    }
}
