import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mi_notes/helpers/providers/data_provider.dart';
import 'package:mi_notes/helpers/providers/auth_provider.dart';
import 'package:mi_notes/helpers/providers/notification_provider.dart';
import 'package:mi_notes/models/event_model.dart';
import 'package:uuid/uuid.dart';
import '../components/responsive_form.dart';

class EventFormScreen extends StatefulWidget {
  final EventModel? event;
  const EventFormScreen({super.key, this.event});

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController = TextEditingController(
      text: widget.event?.description ?? '',
    );
    _startDate = widget.event?.startDate;
    _endDate = widget.event?.endDate;
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final uid = authProvider.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event == null ? 'Nuevo Evento' : 'Editar Evento'),
      ),
      body: ResponsiveForm(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Título'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _startDate == null
                        ? 'Fecha de inicio'
                        : 'Inicio: ${_startDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _startDate = date);
                  },
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _endDate == null
                        ? 'Fecha de fin'
                        : 'Fin: ${_endDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _endDate = date);
                  },
                  child: const Text('Seleccionar'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _descController.text.isEmpty ||
                    _startDate == null ||
                    _endDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Complete todos los campos y fechas'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final notificationProvider =
                      Provider.of<NotificationProvider>(context, listen: false);

                  if (widget.event == null) {
                    // Crear nuevo evento
                    final newEventId = const Uuid().v4();
                    await dataProvider.addEvent(
                      uid,
                      _titleController.text,
                      _descController.text,
                      _startDate!,
                      _endDate!,
                    );

                    // Mostrar notificación inmediata
                    await notificationProvider.showInstantNotification(
                      id: DateTime.now().millisecond,
                      title: '📅 Evento creado',
                      body: '${_titleController.text} fue creado exitosamente',
                    );

                    // Programar notificación para cuando inicie el evento
                    if (_startDate!.isAfter(DateTime.now())) {
                      try {
                        await notificationProvider.scheduleNotification(
                          id: newEventId.hashCode,
                          title: '🔔 Evento: ${_titleController.text}',
                          body: 'Tu evento está comenzando ahora',
                          scheduledAt: _startDate!,
                          payload: newEventId,
                        );
                      } catch (e) {
                        print(
                          'Advertencia: No se pudo programar notificación del evento: $e',
                        );
                      }
                    }
                  } else {
                    // Editar evento existente
                    final updatedEvent = widget.event!.copyWith(
                      title: _titleController.text,
                      description: _descController.text,
                      startDate: _startDate,
                      endDate: _endDate,
                    );
                    await dataProvider.updateEvent(updatedEvent);

                    // Mostrar notificación inmediata
                    await notificationProvider.showInstantNotification(
                      id: DateTime.now().millisecond,
                      title: '✏️ Evento actualizado',
                      body: '${_titleController.text} fue actualizado',
                    );

                    // Reprogramar notificación
                    try {
                      await notificationProvider.cancelNotification(
                        widget.event!.id.hashCode,
                      );
                      if (_startDate!.isAfter(DateTime.now())) {
                        await notificationProvider.scheduleNotification(
                          id: updatedEvent.id.hashCode,
                          title: '🔔 Evento: ${_titleController.text}',
                          body: 'Tu evento está comenzando ahora',
                          scheduledAt: _startDate!,
                          payload: updatedEvent.id,
                        );
                      }
                    } catch (e) {
                      print(
                        'Advertencia: No se pudo reprogramar notificación del evento: $e',
                      );
                    }
                  }

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento guardado correctamente'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al guardar: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
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
