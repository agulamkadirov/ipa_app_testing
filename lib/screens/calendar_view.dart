import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/client.dart';
import '../widgets/client_tile.dart';

class CalendarView extends StatefulWidget {
  final ValueNotifier<List<Client>> clientsNotifier;

  const CalendarView({
    required this.clientsNotifier,
    super.key,
  });

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// Strips time portion from DateTime.
  DateTime _normalizeDate(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// Groups clients by normalized date.
  Map<DateTime, List<Client>> _groupClientsByDate(List<Client> clients) {
    final Map<DateTime, List<Client>> map = {};
    for (var client in clients) {
      final date = _normalizeDate(client.date);
      map.putIfAbsent(date, () => []).add(client);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buyurtma Kalendar'),
      ),
      body: ValueListenableBuilder<List<Client>>(
        valueListenable: widget.clientsNotifier,
        builder: (context, clients, _) {
          final events = _groupClientsByDate(clients);
          final selectedDate = _normalizeDate(_selectedDay ?? _focusedDay);
          final clientsForDay = events[selectedDate] ?? [];

          return Column(
            children: [
              TableCalendar<Client>(
                firstDay: DateTime.now().subtract(const Duration(days: 365)),
                lastDay: DateTime.now().add(const Duration(days: 365)),
                focusedDay: _focusedDay,
                selectedDayPredicate: (day) =>
                    _normalizeDate(day) == selectedDate,
                eventLoader: (day) => events[_normalizeDate(day)] ?? [],
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = _normalizeDate(selectedDay);
                    _focusedDay = _normalizeDate(focusedDay);
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
                child: clientsForDay.isEmpty
                    ? const Center(child: Text('Buyurtma yo‘q'))
                    : ListView.builder(
                        itemCount: clientsForDay.length,
                        itemBuilder: (context, index) {
                          return ClientTile(
                            client: clientsForDay[index],
                            clientsNotifier: widget.clientsNotifier,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

