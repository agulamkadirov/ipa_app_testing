import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/client.dart';

class CalendarView extends StatefulWidget {
  final List<Client> clients;

  const CalendarView({required this.clients, super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  late Map<DateTime, List<Client>> _events;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _events = _groupClientsByDate(widget.clients);
  }

  Map<DateTime, List<Client>> _groupClientsByDate(List<Client> clients) {
    Map<DateTime, List<Client>> map = {};
    for (var client in clients) {
      final date = DateTime(client.date.year, client.date.month, client.date.day);
      map.putIfAbsent(date, () => []).add(client);
    }
    return map;
  }

  List<Client> _getClientsForDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _events[d] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final clientsForDay = _getClientsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyurtma Kalendar'),
      ),
      body: Column(
        children: [
          TableCalendar<Client>(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) =>
                _selectedDay != null &&
                day.year == _selectedDay!.year &&
                day.month == _selectedDay!.month &&
                day.day == _selectedDay!.day,
            eventLoader: _getClientsForDay,
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              markerDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: clientsForDay.length,
              itemBuilder: (context, index) {
                final c = clientsForDay[index];
                return ListTile(
                  title: Text(c.name),
                  subtitle: Text("${c.phone} • ${c.address}"),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

