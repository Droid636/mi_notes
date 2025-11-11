import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/data_provider.dart';
import '../../helpers/providers/auth_provider.dart';
import '../../models/event_model.dart';

class EventScreen extends StatelessWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return StreamBuilder<List<EventModel>>(
      stream: dataProvider.getEvents(
        authProvider.currentUser!.uid,
      ), // ✅ CORREGIDO
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final events = snapshot.data!;
        if (events.isEmpty) {
          return const Center(child: Text('No hay eventos aún'));
        }

        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(event.title),
                subtitle: Text(event.description),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => dataProvider.deleteEvent(event.id),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/eventForm', arguments: event);
                },
              ),
            );
          },
        );
      },
    );
  }
}
