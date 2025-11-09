import 'package:flutter/material.dart';
import '../../helpers/providers/auth_provider.dart';

class HomeScreen extends StatelessWidget {
  final AuthProvider _authProvider = AuthProvider();

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _authProvider.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Center(child: Text('Bienvenido 🎉')),
    );
  }
}
