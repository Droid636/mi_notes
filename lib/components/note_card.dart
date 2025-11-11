import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;

  const NoteCard({super.key, required this.note, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(note.content),
        onTap: onTap,
        trailing: note.pinned ? const Icon(Icons.push_pin) : null,
      ),
    );
  }
}
