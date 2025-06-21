import 'package:flutter/material.dart';
import '../models/client.dart';

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
  late String _name;
  late String _phone;
  late String _notes;
  late String _address;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    final c = widget.initialClient;
    _name = c?.name ?? '';
    _phone = c?.phone ?? '';
    _notes = c?.notes ?? '';
    _date = c?.date ?? DateTime.now();
    _address = c?.address ?? '';
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
        name: _name,
        phone: _phone,
        date: _date,
        notes: _notes,
        address: _address,
      );
      widget.onSave(client);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialClient == null ? "Buyurtma qo'shish": "Buyurtmani tahrirlash"),
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
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: "Mijoz ismi"),
                validator: (val) => val == null || val.trim().isEmpty ? "Bo'sh bo'lmasin!": null,
                onSaved: (val) => _name = val!,
              ),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Tel. raqam'),
                validator: (val) => val == null || val.trim().isEmpty ? "Bo'sh bo'lmasin!": null,
                onSaved: (val) => _phone = val!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Manzili'),
                validator: (val) => val == null || val.trim().isEmpty ? "Bo'sh bo'lmasin!": null,
                onSaved: (val) => _address = val!,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 8),
                  Text(_date.toLocal().toString().split(" ")[0]),
                  const Spacer(),
                  TextButton(onPressed: _pickDate, child: const Text('Sana tanlang.')),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _notes,
                decoration: const InputDecoration(
                  labelText: "Qo'shimcha...",
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

