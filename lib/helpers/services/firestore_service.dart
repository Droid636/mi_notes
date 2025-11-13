import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_notes/models/note_model.dart';
import 'package:mi_notes/models/event_model.dart';
import 'package:mi_notes/models/reminder_model.dart';

// Servicio para interactuar con Firestore
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addNote(NoteModel note) async {
    try {
      await _db.collection('notes').doc(note.id).set(note.toMap());
    } catch (e) {
      throw Exception('Error al agregar nota: $e');
    }
  }

  Future<void> updateNote(NoteModel note) async {
    try {
      await _db.collection('notes').doc(note.id).update(note.toMap());
    } catch (e) {
      throw Exception('Error al actualizar nota: $e');
    }
  }

  Future<void> deleteNote(String id) async {
    try {
      await _db.collection('notes').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar nota: $e');
    }
  }

  Stream<List<NoteModel>> getNotesStream(String uid) {
    return _db
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NoteModel.fromMap({
                  ...doc.data(),
                  'id': doc.id, // agregamos el id
                }),
              )
              .toList(),
        );
  }

  Future<void> addEvent(EventModel event) async {
    try {
      await _db.collection('events').doc(event.id).set(event.toMap());
    } catch (e) {
      throw Exception('Error al agregar evento: $e');
    }
  }

  Future<void> updateEvent(EventModel event) async {
    try {
      await _db.collection('events').doc(event.id).update(event.toMap());
    } catch (e) {
      throw Exception('Error al actualizar evento: $e');
    }
  }

  Future<void> deleteEvent(String id) async {
    try {
      await _db.collection('events').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar evento: $e');
    }
  }

  Stream<List<EventModel>> getEventsStream(String uid) {
    return _db
        .collection('events')
        .where('uid', isEqualTo: uid)
        .orderBy('startDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromMap({...doc.data(), 'id': doc.id}))
              .toList(),
        );
  }

  Future<void> addReminder(ReminderModel reminder) async {
    try {
      await _db.collection('reminders').doc(reminder.id).set(reminder.toMap());
    } catch (e) {
      throw Exception('Error al agregar recordatorio: $e');
    }
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    try {
      await _db
          .collection('reminders')
          .doc(reminder.id)
          .update(reminder.toMap());
    } catch (e) {
      throw Exception('Error al actualizar recordatorio: $e');
    }
  }

  Future<void> deleteReminder(String id) async {
    try {
      await _db.collection('reminders').doc(id).delete();
    } catch (e) {
      throw Exception('Error al eliminar recordatorio: $e');
    }
  }

  Stream<List<ReminderModel>> getRemindersStream(String uid) {
    return _db
        .collection('reminders')
        .where('uid', isEqualTo: uid)
        .orderBy('scheduledAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ReminderModel.fromMap({...doc.data(), 'id': doc.id}),
              )
              .toList(),
        );
  }
}
