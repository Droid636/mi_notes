import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:mi_notes/helpers/services/firestore_service.dart';
import 'package:mi_notes/models/note_model.dart';
import 'package:mi_notes/models/event_model.dart';
import 'package:mi_notes/models/reminder_model.dart';

class DataProvider with ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final Uuid _uuid = const Uuid();

  // Notas
  Future<void> addNote(String uid, String title, String content) async {
    final note = NoteModel(
      id: _uuid.v4(),
      uid: uid,
      title: title,
      content: content,
      pinned: false,
      createdAt: DateTime.now(),
    );
    await _firestore.addNote(note);
  }

  // Post , Update , Delete , Get Notes
  Future<void> updateNote(NoteModel note) async {
    await _firestore.updateNote(note);
  }

  Future<void> deleteNote(String id) async {
    await _firestore.deleteNote(id);
  }

  Stream<List<NoteModel>> getNotes(String uid) {
    return _firestore.getNotesStream(uid);
  }

  // Eventos
  Future<void> addEvent(
    String uid,
    String title,
    String description,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final event = EventModel(
      id: _uuid.v4(),
      uid: uid,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
    );
    await _firestore.addEvent(event);
  }

  // Post , Update , Delete , Get Events
  Future<void> updateEvent(EventModel event) async {
    await _firestore.updateEvent(event);
  }

  Future<void> deleteEvent(String id) async {
    await _firestore.deleteEvent(id);
  }

  Stream<List<EventModel>> getEvents(String uid) {
    return _firestore.getEventsStream(uid);
  }

  // Recordatorios
  // Post , Update , Delete , Get Reminders

  Future<void> addReminder(ReminderModel reminder) async {
    await _firestore.addReminder(reminder);
  }

  Future<void> updateReminder(ReminderModel reminder) async {
    await _firestore.updateReminder(reminder);
  }

  Future<void> deleteReminder(String id) async {
    await _firestore.deleteReminder(id);
  }

  Stream<List<ReminderModel>> getReminders(String uid) {
    return _firestore.getRemindersStream(uid);
  }
}
