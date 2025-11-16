import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_notes/helpers/providers/data_provider.dart';
import 'package:mi_notes/helpers/providers/auth_provider.dart';
import 'package:mi_notes/helpers/providers/notification_provider.dart';
import 'package:mi_notes/models/note_model.dart';
import '../components/responsive_form.dart';

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

  // ⭐ Nuevo: soporte para PINNED
  late bool _pinned;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(
      text: widget.note?.content ?? '',
    );
    _pinned = widget.note?.pinned ?? false; // ← si es edición, cargar
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
      body: ResponsiveForm(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese un título' : null,
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _contentController,
                maxLines: 6,
                decoration: const InputDecoration(labelText: 'Contenido'),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Ingrese contenido' : null,
              ),

              const SizedBox(height: 18),

              // ⭐ Switch para Fijar Nota
              SwitchListTile(
                title: const Text("Fijar nota (pinned)"),
                value: _pinned,
                onChanged: (val) {
                  setState(() => _pinned = val);
                },
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;

                  try {
                    final notificationProvider =
                        Provider.of<NotificationProvider>(
                          context,
                          listen: false,
                        );

                    if (widget.note == null) {
                      // ⭐ Crear nota con pinned
                      await dataProvider.addNote(
                        uid,
                        _titleController.text,
                        _contentController.text,
                        pinned: _pinned, // ← lo agregué
                      );

                      await notificationProvider.showInstantNotification(
                        id: DateTime.now().millisecond,
                        title: '✅ Nota guardada',
                        body:
                            '${_titleController.text} se guardó correctamente',
                      );
                    } else {
                      // ⭐ Actualizar nota con pinned
                      final updatedNote = widget.note!.copyWith(
                        title: _titleController.text,
                        content: _contentController.text,
                        pinned: _pinned, // ← también lo agregué
                      );

                      await dataProvider.updateNote(updatedNote);

                      await notificationProvider.showInstantNotification(
                        id: DateTime.now().millisecond,
                        title: '✏️ Nota actualizada',
                        body: '${_titleController.text} fue actualizada',
                      );
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Nota guardada correctamente'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

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
