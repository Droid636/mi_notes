import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_notes/helpers/providers/data_provider.dart';
import 'package:mi_notes/helpers/providers/auth_provider.dart';
import 'package:mi_notes/helpers/providers/notification_provider.dart';
import 'package:mi_notes/models/reminder_model.dart';
import 'package:uuid/uuid.dart';

class ReminderFormScreen extends StatefulWidget {
  final ReminderModel? reminder;
  const ReminderFormScreen({super.key, this.reminder});

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen> {
  late TextEditingController _titleController;
  DateTime? _scheduledAt;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.reminder?.title ?? '',
    );
    _scheduledAt = widget.reminder?.scheduledAt;
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.reminder == null
              ? 'Nuevo Recordatorio'
              : 'Editar Recordatorio',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _scheduledAt == null
                        ? 'Seleccionar fecha y hora'
                        : 'Fecha: ${_scheduledAt!.toLocal()}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _scheduledAt ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                          _scheduledAt ?? DateTime.now(),
                        ),
                      );
                      if (time != null) {
                        setState(() {
                          _scheduledAt = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty || _scheduledAt == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Ingrese un título y seleccione fecha'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final notificationProvider =
                      Provider.of<NotificationProvider>(context, listen: false);

                  if (widget.reminder == null) {
                    // Crear nuevo recordatorio
                    final newReminder = ReminderModel(
                      id: const Uuid().v4(),
                      uid: uid,
                      title: _titleController.text,
                      scheduledAt: _scheduledAt!,
                      eventId: null,
                      noteId: null,
                    );
                    await dataProvider.addReminder(newReminder);

                    // Programar notificación para la fecha/hora seleccionada
                    if (_scheduledAt!.isAfter(DateTime.now())) {
                      await notificationProvider.scheduleNotification(
                        id: newReminder.id.hashCode,
                        title: '🔔 Recordatorio: ${_titleController.text}',
                        body: 'Es hora de: ${_titleController.text}',
                        scheduledAt: _scheduledAt!,
                        payload: newReminder.id,
                      );
                    }

                    // Mostrar notificación inmediata de creación
                    await notificationProvider.showInstantNotification(
                      id: DateTime.now().millisecond,
                      title: '⏰ Recordatorio creado',
                      body:
                          'Se programó "${_titleController.text}" para ${_scheduledAt!.toString().split('.')[0]}',
                    );
                  } else {
                    // Editar recordatorio existente
                    final updatedReminder = widget.reminder!.copyWith(
                      title: _titleController.text,
                      scheduledAt: _scheduledAt,
                    );
                    await dataProvider.updateReminder(updatedReminder);

                    // Reprogramar notificación
                    await notificationProvider.cancelNotification(
                      widget.reminder!.id.hashCode,
                    );
                    if (_scheduledAt!.isAfter(DateTime.now())) {
                      await notificationProvider.scheduleNotification(
                        id: updatedReminder.id.hashCode,
                        title: '🔔 Recordatorio: ${_titleController.text}',
                        body: 'Es hora de: ${_titleController.text}',
                        scheduledAt: _scheduledAt!,
                        payload: updatedReminder.id,
                      );
                    }

                    // Mostrar notificación de actualización
                    await notificationProvider.showInstantNotification(
                      id: DateTime.now().millisecond,
                      title: '✏️ Recordatorio actualizado',
                      body:
                          'Se actualizó para ${_scheduledAt!.toString().split('.')[0]}',
                    );
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Recordatorio guardado correctamente'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );

                  Navigator.pop(context, true); // refresca la lista
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
    );
  }
}
