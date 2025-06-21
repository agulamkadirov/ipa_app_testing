import 'package:flutter/material.dart';
import 'package:hello_flutter/models/client.dart';
import 'client_form.dart';

class ClientTile extends StatefulWidget {
  final Client client;
  final ValueNotifier< List<Client> > clientsNotifier;

  const ClientTile({
    required this.client,
    required this.clientsNotifier,
    super.key,
  });

  @override
  State<ClientTile> createState() => _ClientTileState();
}

class _ClientTileState extends State<ClientTile> {
    bool _expanded = false;

    void _editClient(BuildContext context) {
        final clients = widget.clientsNotifier.value;
        final client = widget.client;
        final index = clients.indexOf(client);

        showDialog(
          context: context,
          builder: (_) => ClientForm(
            initialClient: client,
            onSave: (newClient) {
                clients[index] = newClient;
                clients.sort(Client.compareByDate);
                widget.clientsNotifier.value = [...clients];
            }
          ),
    );
  }

  void _confirmDelete(BuildContext context) {
      final clients = widget.clientsNotifier.value;
      final client = widget.client;
      final index = clients.indexOf(client);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Buyurtmani o'chirmoqchimisiz?"),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Yo'q"),
                ),
                ElevatedButton(
                    onPressed: () {
                        clients.removeAt(index);
                        widget.clientsNotifier.value = [...clients];
                        Navigator.of(context).pop();
                    },
                    child: const Text("Ha")
                )
            ]
        )
      );
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = widget.client.date.difference(DateTime.now()).inDays;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Info
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.client.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text('$daysLeft kun qoldi'),
                ],
              ),
              const SizedBox(height: 4),
              Text('📞 ${widget.client.phone}'),
              Text('📅 ${widget.client.date.toLocal().toString().split(" ")[0]}'),
              Text("📍 ${widget.client.address}"),

              // Expandable Notes
              if (_expanded) ...[
                const Divider(height: 16),
                Text('📝 ${widget.client.notes}'),
              ],

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editClient(context),
                    icon: const Icon(Icons.edit),
                    label: const Text(''),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete),
                    label: const Text(""),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

