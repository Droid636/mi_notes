import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/auth_provider.dart';
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

  // ❌ Se quitó const
  final List<Widget> _screens = [
    NoteFormScreen(),
    EventFormScreen(),
    ReminderFormScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

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
      body: _screens[_selectedIndex],
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
            Navigator.pushNamed(context, '/noteForm');
          } else if (_selectedIndex == 1) {
            Navigator.pushNamed(context, '/eventForm');
          } else {
            Navigator.pushNamed(context, '/reminderForm');
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
