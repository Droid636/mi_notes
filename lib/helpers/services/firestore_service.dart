import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_notes/models/note_model.dart';
import 'package:mi_notes/models/event_model.dart';
import 'package:mi_notes/models/reminder_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===============================
  // 🔹 NOTAS
  // ===============================
  Future<void> addNote(NoteModel note) async {
    await _db.collection('notes').doc(note.id).set(note.toMap());
  }

  Future<void> updateNote(NoteModel note) async {
    await _db.collection('notes').doc(note.id).update(note.toMap());
  }

  Future<void> deleteNote(String id) async {
    await _db.collection('notes').doc(id).delete();
  }

  Stream<List<NoteModel>> getNotesStream(String uid) {
    return _db
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NoteModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ===============================
  // 🔹 EVENTOS
  // ===============================
  Future<void> addEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).set(event.toMap());
  }

  Future<void> updateEvent(EventModel event) async {
    await _db.collection('events').doc(event.id).update(event.toMap());
  }

  Future<void> deleteEvent(String id) async {
    await _db.collection('events').doc(id).delete();
  }

  Stream<List<EventModel>> getEventsStream(String uid) {
    return _db
        .collection('events')
        .where('uid', isEqualTo: uid)
        .orderBy('startDate')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => EventModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // ===============================
  // 🔹 RECORDATORIOS
  // ===============================
  Future<void> addReminder(ReminderModel reminder) async {
    await _db.collection('reminders').doc(reminder.id).set(reminder.toMap());
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _db.collection('reminders').doc(reminder.id).update(reminder.toMap());
  }

  Future<void> deleteReminder(String id) async {
    await _db.collection('reminders').doc(id).delete();
  }

  Stream<List<ReminderModel>> getRemindersStream(String uid) {
    return _db
        .collection('reminders')
        .where('uid', isEqualTo: uid)
        .orderBy('scheduledAt')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ReminderModel.fromMap(doc.data()))
              .toList(),
        );
  }
}
