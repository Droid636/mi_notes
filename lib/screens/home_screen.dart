import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/providers/auth_provider.dart';
import '../helpers/providers/data_provider.dart';
import '../helpers/providers/notification_provider.dart';
import '../models/note_model.dart';
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import '../components/note_card.dart';
import '../components/event_card.dart';
import '../components/reminder_tile.dart';
import '../utils/date_utils.dart';
import 'note_screen.dart';
import 'event_screen.dart';
import 'reminder_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );
    notificationProvider.initNotifications();
    notificationProvider.requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser!.uid;
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedIndex == 0
              ? 'Notas'
              : _selectedIndex == 1
              ? 'Eventos'
              : 'Recordatorios',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: _selectedIndex == 0
          ? _buildNotes(uid, dataProvider)
          : _selectedIndex == 1
          ? _buildEvents(uid, dataProvider)
          : _buildReminders(uid, dataProvider),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.note), label: 'Notas'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Eventos'),
          BottomNavigationBarItem(
            icon: Icon(Icons.alarm),
            label: 'Recordatorios',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedIndex == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NoteFormScreen()),
            );
          } else if (_selectedIndex == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EventFormScreen()),
            );
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReminderFormScreen()),
            );
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildNotes(String uid, DataProvider dataProvider) {
    return StreamBuilder<List<NoteModel>>(
      stream: dataProvider.getNotes(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notes = snapshot.data!;
        if (notes.isEmpty) return const Center(child: Text('No hay notas'));
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(note: note, onTap: () => _showNoteModal(note));
          },
        );
      },
    );
  }

  Widget _buildEvents(String uid, DataProvider dataProvider) {
    return StreamBuilder<List<EventModel>>(
      stream: dataProvider.getEvents(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final events = snapshot.data!;
        if (events.isEmpty) return const Center(child: Text('No hay eventos'));
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(event: event, onTap: () => _showEventModal(event));
          },
        );
      },
    );
  }

  Widget _buildReminders(String uid, DataProvider dataProvider) {
    return StreamBuilder<List<ReminderModel>>(
      stream: dataProvider.getReminders(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final reminders = snapshot.data!;
        if (reminders.isEmpty) {
          return const Center(child: Text('No hay recordatorios'));
        }
        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return ReminderTile(
              reminder: reminder,
              onTap: () => _showReminderModal(reminder),
            );
          },
        );
      },
    );
  }

  Future<void> _showNoteModal(NoteModel note) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(note.title),
          content: SingleChildScrollView(child: Text(note.content)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
                );
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Eliminar nota'),
                      content: const Text(
                        '¿Está seguro de que desea eliminar esta nota?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed ?? false) {
                  await dataProvider.deleteNote(note.id);

                  await notificationProvider.showInstantNotification(
                    id: DateTime.now().millisecond,
                    title: '🗑️ Nota eliminada',
                    body: 'Se eliminó "${note.title}"',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nota eliminada'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEventModal(EventModel event) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(event.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.description),
                const SizedBox(height: 12),
                Text('Inicio: ${formatDateTime(event.startDate)}'),
                Text('Fin: ${formatDateTime(event.endDate)}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EventFormScreen(event: event),
                  ),
                );
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Eliminar evento'),
                      content: const Text(
                        '¿Está seguro de que desea eliminar este evento?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed ?? false) {
                  await dataProvider.deleteEvent(event.id);

                  await notificationProvider.cancelNotification(
                    event.id.hashCode,
                  );

                  await notificationProvider.showInstantNotification(
                    id: DateTime.now().millisecond,
                    title: '🗑️ Evento eliminado',
                    body: 'Se eliminó "${event.title}"',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento eliminado'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReminderModal(ReminderModel reminder) async {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final notificationProvider = Provider.of<NotificationProvider>(
      context,
      listen: false,
    );

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(reminder.title),
          content: Text(
            'Programado para: ${formatDateTime(reminder.scheduledAt)}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReminderFormScreen(reminder: reminder),
                  ),
                );
              },
              child: const Text('Editar'),
            ),
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Eliminar recordatorio'),
                      content: const Text(
                        '¿Está seguro de que desea eliminar este recordatorio?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Eliminar',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                );

                if (confirmed ?? false) {
                  await dataProvider.deleteReminder(reminder.id);

                  await notificationProvider.cancelNotification(
                    reminder.id.hashCode,
                  );

                  await notificationProvider.showInstantNotification(
                    id: DateTime.now().millisecond,
                    title: '🗑️ Recordatorio eliminado',
                    body: 'Se eliminó "${reminder.title}"',
                  );

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Recordatorio eliminado'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text(
                'Eliminar',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
