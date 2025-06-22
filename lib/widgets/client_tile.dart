import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/database_instance.dart';
import 'package:drift/drift.dart' as drift;
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
            onSave: (newClient) async {
                await db.update(db.clients).replace(newClient);
                clients[index] = newClient;
                clients.sort((a, b) => a.date.compareTo(b.date));
                widget.clientsNotifier.value = [...clients];
                Navigator.of(context).pop();
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
                    onPressed: () async {
                        await (db.delete(db.clients)..where((tbl) => tbl.id.equals(widget.client.id))).go();
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

  String _getDaysLeftText(DateTime date) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final target = DateTime(date.year, date.month, date.day);
      final diff = target.difference(today).inDays;

      if (diff == 0) return 'Bugun';
      if (diff == 1) return 'Ertaga';
      if (diff == 2) return 'Indinga';
      if (diff < 0) return '${-diff} kun oldin';
      return '$diff kun qoldi';
  }

  void _confirmCompletion(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
            title: const Text("Tasdiqlaysizmi?"),
            content: const Text("Bu buyurtmani yakunlandi deb belgilamoqchimisiz?"),
            actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Yo'q"),
                    ),
                ElevatedButton(
                    onPressed: () async {
                        // Update DB
                        await (db.update(db.clients)
                            ..where((tbl) => tbl.id.equals(widget.client.id)))
                            .write(const ClientsCompanion(completed: drift.Value(true)));

                        // Remove from UI
                        final clients = widget.clientsNotifier.value;
                        clients.remove(widget.client);
                        widget.clientsNotifier.value = [...clients];

                        Navigator.of(context).pop(); // Close the dialog
                    },
                    child: const Text("Ha"),
                ),
            ],
        ),
    );
}

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final clientDate = DateTime(widget.client.date.year, widget.client.date.month, widget.client.date.day);
    final isExpired = clientDate.isBefore(today) || clientDate.isAtSameMomentAs(today);
    final textColor = isExpired ? Color(int.parse("0xFF37371F")) : Theme.of(context).textTheme.bodyMedium?.color;
    final backgroundColor = isExpired
        ? Color(int.parse("0xFFEA9010"))
        : Theme.of(context).cardColor;
    final textStyle = Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor);

    return Card(
      color: backgroundColor,
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
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(color: textColor),
                    ),
                  ),
                  Text(_getDaysLeftText(widget.client.date), style: textStyle),
                ],
              ),
              const SizedBox(height: 4),
              Text('📞 ${widget.client.phone}', style: textStyle),
              Text('📅 ${widget.client.date.toLocal().toString().split(" ")[0]}', style: textStyle),
              Text("📍 ${widget.client.address}", style: textStyle),

              if (isExpired) ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                    ),
                    onPressed: () => _confirmCompletion(context),
                    icon: const Icon(Icons.check),
                    label: const Text("Tugatildi"),
                    ),
              ],

              // Expandable Notes
              if (_expanded) ...[
                const Divider(height: 16),
                Text('📝 ${widget.client.notes}', style: textStyle),
              ],

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _editClient(context),
                    icon: Icon(Icons.edit, color: isExpired ? Colors.black : Colors.white),
                    label: const Text(''),
                  ),
                  TextButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: Icon(Icons.delete, color: isExpired ? Colors.black : Colors.white),
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

