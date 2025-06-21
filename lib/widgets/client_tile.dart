import 'package:flutter/material.dart';
import 'package:hello_flutter/models/client.dart';

class ClientTile extends StatefulWidget {
  final Client client;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ClientTile({
    required this.client,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  @override
  State<ClientTile> createState() => _ClientTileState();
}

class _ClientTileState extends State<ClientTile> {
  bool _expanded = false;

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
                    onPressed: widget.onEdit,
                    icon: const Icon(Icons.edit),
                    label: const Text(''),
                  ),
                  TextButton.icon(
                    onPressed: widget.onDelete,
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

