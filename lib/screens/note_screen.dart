import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_notes/helpers/providers/data_provider.dart';
import 'package:mi_notes/helpers/providers/auth_provider.dart';
import 'package:mi_notes/helpers/providers/notification_provider.dart';
import 'package:mi_notes/models/note_model.dart';

class NoteFormScreen extends StatefulWidget {
  final NoteModel? note;
  const NoteFormScreen({super.key, this.note});

  @override
  State<NoteFormScreen> createState() => _NoteFormScreenState();
}

class _NoteFormScreenState extends State<NoteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note == null ? 'Nueva Nota' : 'Editar Nota'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese un título' : null,
              ),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese contenido' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  try {
                    final notificationProvider = 
                        Provider.of<NotificationProvider>(context, listen: false);
                    
                    if (widget.note == null) {
                      // Crear nueva nota
                      await dataProvider.addNote(
                        uid,
                        _titleController.text,
                        _contentController.text,
                      );
                      // Mostrar notificación de nota guardada
                      await notificationProvider.showInstantNotification(
                        id: DateTime.now().millisecond,
                        title: '✅ Nota guardada',
                        body: '${_titleController.text} se guardó correctamente',
                      );
                    } else {
                      // Editar nota existente
                      final updatedNote = widget.note!.copyWith(
                        title: _titleController.text,
                        content: _contentController.text,
                      );
                      await dataProvider.updateNote(updatedNote);
                      // Mostrar notificación de nota actualizada
                      await notificationProvider.showInstantNotification(
                        id: DateTime.now().millisecond,
                        title: '✏️ Nota actualizada',
                        body: '${_titleController.text} fue actualizada',
                      );
                    }

                    // Mostrar SnackBar de confirmación
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nota guardada correctamente'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    // Regresar a la pantalla anterior indicando que hubo cambios
                    Navigator.pop(context, true);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
