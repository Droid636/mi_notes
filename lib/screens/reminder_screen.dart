import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/data_provider.dart';
import '../../helpers/providers/auth_provider.dart';
import '../../models/reminder_model.dart';

class ReminderScreen extends StatelessWidget {
  const ReminderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return StreamBuilder<List<ReminderModel>>(
      stream: dataProvider.getReminders(authProvider.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final reminders = snapshot.data!;
        if (reminders.isEmpty) {
          return const Center(child: Text('No hay recordatorios aún'));
        }

        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                // ✅ ya no da error: no existe "title" en ReminderModel
                title: const Text('Recordatorio'),
                subtitle: Text(
                  'Fecha: ${reminder.scheduledAt.toLocal().toString()}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => dataProvider.deleteReminder(reminder.id),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
