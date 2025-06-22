import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../database/database_instance.dart';


class ClientForm extends StatefulWidget {
  final Client? initialClient;
  final void Function(Client client) onSave;

  const ClientForm({
    this.initialClient,
    required this.onSave,
    super.key,
  });

  @override
  State<ClientForm> createState() => _ClientFormState();
}

class _ClientFormState extends State<ClientForm> {
  final _formKey = GlobalKey<FormState>();

  late int id;
  late String _name;
  late String _phone;
  late String _address;
  late String _notes;
  late DateTime _date;
  late bool _completed;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final c = widget.initialClient;

    id = c?.id ?? 0;
    _name = c?.name ?? '';
    _phone = c?.phone ?? '';
    _address = c?.address ?? '';
    _notes = c?.notes ?? '';
    _date = c?.date ?? DateTime.now();
    _completed = c?.completed ?? false;
    _nameController.text = _name;
  }

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final client = Client(
        id: id,
        name: _name,
        phone: _phone,
        address: _address,
        notes: _notes,
        date: _date,
        completed: _completed,
      );

      widget.onSave(client);
    }
  }

  Future<List<String>> getDistinctClientNames() async {
      final query = db.customSelect(
          'SELECT DISTINCT name FROM clients',
          readsFrom: {db.clients},
      );
      final rows = await query.get();
      return rows.map((row) => row.data['name'] as String).toList();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialClient == null ? "Buyurtma qo'shish" : "Buyurtmani tahrirlash"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) async {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  final allNames = await getDistinctClientNames();
                  return allNames.where((name) =>
                    name.toLowerCase().contains(textEditingValue.text.toLowerCase()));
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  controller.text = _nameController.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: "Mijoz ismi"),
                    validator: (val) => val == null || val.trim().isEmpty ? "Bo'sh bo'lmasin!" : null,
                    onSaved: (val) => _name = val!,
                    onChanged: (val) => _nameController.text = val,
                   );
                },
                onSelected: (String selection) {
                  _nameController.text = selection;
                  _name = selection;
                },
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Tel. raqam'),
                validator: (val) => val == null || val.trim().isEmpty ? "Bo'sh bo'lmasin!" : null,
                onSaved: (val) => _phone = val!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Manzili'),
                validator: (val) => val == null || val.trim().isEmpty ? "Bo'sh bo'lmasin!" : null,
                onSaved: (val) => _address = val!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(_date.toLocal().toString().split(" ")[0]),
                  const Spacer(),
                  TextButton(
                    onPressed: _pickDate,
                    child: const Text('Sana tanlang'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: "Qo'shimcha eslatma",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                maxLines: 5,
                onSaved: (val) => _notes = val ?? '',
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Saqlash'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

