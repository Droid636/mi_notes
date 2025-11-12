import 'package:flutter/material.dart';
import '../models/note_model.dart';

class NoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback onTap;
  final void Function(String action)? onActionSelected;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    this.onActionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(note.title),
        subtitle: Text(note.content),
        onTap: onTap,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (note.pinned) const Icon(Icons.push_pin, color: Colors.orange),
            if (onActionSelected != null)
              PopupMenuButton<String>(
                onSelected: (value) => onActionSelected!(value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
