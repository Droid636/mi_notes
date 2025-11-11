import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../helpers/providers/auth_provider.dart';
import '../helpers/providers/data_provider.dart';
import '../models/note_model.dart';
import '../models/event_model.dart';
import '../models/reminder_model.dart';
import '../components/note_card.dart';
import '../components/event_card.dart';
import '../components/reminder_tile.dart';
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
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final notes = snapshot.data!;
        if (notes.isEmpty) return const Center(child: Text('No hay notas'));
        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return NoteCard(
              note: note,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NoteFormScreen(note: note)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEvents(String uid, DataProvider dataProvider) {
    return StreamBuilder<List<EventModel>>(
      stream: dataProvider.getEvents(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final events = snapshot.data!;
        if (events.isEmpty) return const Center(child: Text('No hay eventos'));
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            final event = events[index];
            return EventCard(
              event: event,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EventFormScreen(event: event),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReminders(String uid, DataProvider dataProvider) {
    return StreamBuilder<List<ReminderModel>>(
      stream: dataProvider.getReminders(uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final reminders = snapshot.data!;
        if (reminders.isEmpty)
          return const Center(child: Text('No hay recordatorios'));
        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            final reminder = reminders[index];
            return ReminderTile(
              reminder: reminder,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReminderFormScreen(reminder: reminder),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
