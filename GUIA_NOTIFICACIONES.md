# 📱 Guía de Correcciones - Notificaciones en Mi Notes

## ✅ Cambios Realizados (En Español)

Aquí están TODOS los cambios que se hicieron para que las notificaciones funcionen en **Notas**, **Eventos** y **Recordatorios**.

---

## 1️⃣ `lib/screens/note_screen.dart` - NOTAS

### ✅ Cambio 1: Agregar Import
**Línea 5** - Agregar el import de NotificationProvider:
```dart
import 'package:mi_notes/helpers/providers/notification_provider.dart';
```

### ✅ Cambio 2: Actualizar Función de Guardar
**Líneas 61-96** - Reemplazar el `onPressed` del botón "Guardar":

```dart
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

    // Regresar a la pantalla anterior
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
```

---

## 2️⃣ `lib/screens/event_screen.dart` - EVENTOS

### ✅ Cambio 1: Agregar Import
**Línea 5** - Agregar:
```dart
import 'package:mi_notes/helpers/providers/notification_provider.dart';
```

### ✅ Cambio 2: Actualizar Función de Guardar
**Líneas 106-165** - Reemplazar el `onPressed` del botón "Guardar":

```dart
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
      await dataProvider.addEvent(
        uid,
        _titleController.text,
        _descController.text,
        _startDate!,
        _endDate!,
      );
      // Mostrar notificación de evento creado
      await notificationProvider.showInstantNotification(
        id: DateTime.now().millisecond,
        title: '📅 Evento creado',
        body: '${_titleController.text} fue creado exitosamente',
      );
    } else {
      // Editar evento existente
      final updatedEvent = widget.event!.copyWith(
        title: _titleController.text,
        description: _descController.text,
        startDate: _startDate,
        endDate: _endDate,
      );
      await dataProvider.updateEvent(updatedEvent);
      // Mostrar notificación de evento actualizado
      await notificationProvider.showInstantNotification(
        id: DateTime.now().millisecond,
        title: '✏️ Evento actualizado',
        body: '${_titleController.text} fue actualizado',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Evento guardado correctamente'),
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
```

---

## 3️⃣ `lib/screens/reminder_screen.dart` - RECORDATORIOS

### ✅ Cambio 1: Agregar Import
**Línea 5** - Agregar:
```dart
import 'package:mi_notes/helpers/providers/notification_provider.dart';
```

### ✅ Cambio 2: Actualizar Función de Guardar
**Líneas 95-172** - Reemplazar el `onPressed` del botón "Guardar":

```dart
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
        body: 'Se programó "${_titleController.text}" para ${_scheduledAt!.toString().split('.')[0]}',
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
        body: 'Se actualizó para ${_scheduledAt!.toString().split('.')[0]}',
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Recordatorio guardado correctamente'),
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
```

---

## 4️⃣ `lib/screens/home_screen.dart` - ELIMINAR CON NOTIFICACIONES

### ✅ Cambio 1: Actualizar Eliminación de NOTAS
**En la función `_buildNotes()`** - Actualizar el `onActionSelected`:

```dart
onActionSelected: (value) async {
  final notificationProvider = 
      Provider.of<NotificationProvider>(context, listen: false);
      
  if (value == 'edit') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteFormScreen(note: note),
      ),
    );
  } else if (value == 'delete') {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar nota'),
          content: const Text('¿Está seguro de que desea eliminar esta nota?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await dataProvider.deleteNote(note.id);
      
      // Mostrar notificación de eliminación
      await notificationProvider.showInstantNotification(
        id: DateTime.now().millisecond,
        title: '🗑️ Nota eliminada',
        body: 'Se eliminó "${note.title}"',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nota eliminada'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
},
```

### ✅ Cambio 2: Actualizar Eliminación de EVENTOS
**En la función `_buildEvents()`** - Actualizar el `onActionSelected`:

```dart
onActionSelected: (value) async {
  final notificationProvider = 
      Provider.of<NotificationProvider>(context, listen: false);
      
  if (value == 'edit') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EventFormScreen(event: event),
      ),
    );
  } else if (value == 'delete') {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar evento'),
          content: const Text('¿Está seguro de que desea eliminar este evento?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await dataProvider.deleteEvent(event.id);
      
      // Mostrar notificación de eliminación
      await notificationProvider.showInstantNotification(
        id: DateTime.now().millisecond,
        title: '🗑️ Evento eliminado',
        body: 'Se eliminó "${event.title}"',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evento eliminado'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
},
```

### ✅ Cambio 3: Actualizar Eliminación de RECORDATORIOS
**En la función `_buildReminders()`** - Actualizar el `onSelected` del `PopupMenuButton`:

```dart
onSelected: (value) async {
  final notificationProvider = 
      Provider.of<NotificationProvider>(context, listen: false);
      
  if (value == 'edit') {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderFormScreen(reminder: reminder),
      ),
    );
  } else if (value == 'delete') {
    // Mostrar confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar recordatorio'),
          content: const Text('¿Está seguro de que desea eliminar este recordatorio?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed ?? false) {
      await dataProvider.deleteReminder(reminder.id);
      
      // Cancelar la notificación programada
      await notificationProvider.cancelNotification(
        reminder.id.hashCode,
      );
      
      // Mostrar notificación de eliminación
      await notificationProvider.showInstantNotification(
        id: DateTime.now().millisecond,
        title: '🗑️ Recordatorio eliminado',
        body: 'Se eliminó "${reminder.title}"',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Recordatorio eliminado'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
},
```

---

## 📊 Resumen de Cambios

| Pantalla | Acción | Notificación |
|----------|--------|--------------|
| **note_screen.dart** | Crear nota | ✅ Nota guardada |
| **note_screen.dart** | Editar nota | ✏️ Nota actualizada |
| **event_screen.dart** | Crear evento | 📅 Evento creado |
| **event_screen.dart** | Editar evento | ✏️ Evento actualizado |
| **reminder_screen.dart** | Crear recordatorio | ⏰ Recordatorio creado + 🔔 Programado |
| **reminder_screen.dart** | Editar recordatorio | ✏️ Recordatorio actualizado + 🔔 Reprogramado |
| **home_screen.dart** | Eliminar nota | 🗑️ Nota eliminada |
| **home_screen.dart** | Eliminar evento | 🗑️ Evento eliminado |
| **home_screen.dart** | Eliminar recordatorio | 🗑️ Recordatorio eliminado |

---

## 🎯 Características Agregadas

✅ **Notificaciones Inmediatas** - Se muestran al crear/editar/eliminar
✅ **Notificaciones Programadas** - Para recordatorios en fecha/hora específica
✅ **Diálogos de Confirmación** - Al eliminar se pide confirmación
✅ **Emojis** - Identifican cada tipo de notificación
✅ **SnackBars Mejorados** - Con colores para éxito/error
✅ **Cancelación de Notificaciones** - Al eliminar recordatorios se cancela la notificación programada

---

## 🔧 Métodos Utilizados de NotificationProvider

```dart
// Mostrar notificación inmediata
await notificationProvider.showInstantNotification(
  id: DateTime.now().millisecond,
  title: 'Título',
  body: 'Descripción',
);

// Programar notificación para fecha/hora
await notificationProvider.scheduleNotification(
  id: reminderId.hashCode,
  title: 'Título',
  body: 'Descripción',
  scheduledAt: DateTime,
  payload: 'datos_opcionales',
);

// Cancelar notificación
await notificationProvider.cancelNotification(id);
```

---

## ✨ Listo para Usar

Con estos cambios, tu app Mi Notes ahora tiene **notificaciones completas** en:
- 📝 Notas
- 📅 Eventos  
- 🔔 Recordatorios

¡Todo funciona automáticamente! 🚀
