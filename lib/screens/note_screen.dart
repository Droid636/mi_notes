import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/providers/data_provider.dart';
import '../../helpers/providers/auth_provider.dart';
import '../../models/note_model.dart';

class NoteScreen extends StatelessWidget {
  const NoteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return StreamBuilder<List<NoteModel>>(
      stream: dataProvider.getNotes(authProvider.currentUser!.uid),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final notes = snapshot.data!;
        if (notes.isEmpty) {
          return const Center(child: Text('No hay notas aún'));
        }

        return ListView.builder(
          itemCount: notes.length,
          itemBuilder: (context, index) {
            final note = notes[index];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                title: Text(note.title),
                subtitle: Text(note.content),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => dataProvider.deleteNote(note.id),
                ),
                onTap: () {
                  Navigator.pushNamed(context, '/noteForm', arguments: note);
                },
              ),
            );
          },
        );
      },
    );
  }
}
