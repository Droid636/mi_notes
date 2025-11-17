// lib/screens/event_screen.dart
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
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event?.title ?? '');
    _descController = TextEditingController(
      text: widget.event?.description ?? '',
    );

    if (widget.event != null) {
      _selectedDate = widget.event!.startDate;
      _selectedTime = TimeOfDay.fromDateTime(widget.event!.startDate);
    }
  }

  DateTime? _composeDateTime() {
    if (_selectedDate == null) return null;
    final date = _selectedDate!;
    final time = _selectedTime ?? TimeOfDay(hour: 0, minute: 0);
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
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
                    _selectedDate == null
                        ? 'Fecha'
                        : 'Fecha: ${_selectedDate!.toLocal()}'.split(' ')[0],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  child: const Text('Seleccionar fecha'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedTime == null
                        ? 'Hora'
                        : 'Hora: ${_selectedTime!.format(context)}',
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime ?? TimeOfDay.now(),
                    );
                    if (time != null) setState(() => _selectedTime = time);
                  },
                  child: const Text('Seleccionar hora'),
                ),
              ],
            ),
            const SizedBox(height: 18),

            ElevatedButton(
              onPressed: () async {
                if (_titleController.text.isEmpty ||
                    _descController.text.isEmpty ||
                    _selectedDate == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Completa título, descripción y fecha/hora',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final eventDateTime = _composeDateTime();
                if (eventDateTime == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Selecciona fecha y hora válidas'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                try {
                  final notifier = Provider.of<NotificationProvider>(
                    context,
                    listen: false,
                  );
                  final uuid = const Uuid();

                  if (widget.event == null) {
                    // Crear nuevo evento
                    final newEventId = uuid.v4();

                    await dataProvider.addEvent(
                      uid,
                      _titleController.text,
                      _descController.text,
                      eventDateTime,
                      eventDateTime,
                    );

                    // ⭐ NOTIFICACIÓN EXCLUSIVA DE EVENTO
                    await notifier.scheduleEventNotification(
                      id: newEventId.hashCode,
                      title: '📅 Evento próximo',
                      body: _titleController.text,
                      scheduledAt: eventDateTime,
                      payload: newEventId,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento creado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    final updatedEvent = widget.event!.copyWith(
                      title: _titleController.text,
                      description: _descController.text,
                      startDate: eventDateTime,
                      endDate: eventDateTime,
                    );

                    await dataProvider.updateEvent(updatedEvent);

                    // Cancelar notificación anterior
                    await notifier.cancelNotification(
                      widget.event!.id.hashCode,
                    );

                    // Crear nueva
                    await notifier.scheduleEventNotification(
                      id: updatedEvent.id.hashCode,
                      title: '📅 Evento próximo',
                      body: _titleController.text,
                      scheduledAt: eventDateTime,
                      payload: updatedEvent.id,
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Evento actualizado'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }

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
    );
  }
}
