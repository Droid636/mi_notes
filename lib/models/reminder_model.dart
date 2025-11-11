import 'package:cloud_firestore/cloud_firestore.dart';

class ReminderModel {
  final String id;
  final String uid;
  final String title; // ✅ Agregado
  final DateTime scheduledAt;
  final String? eventId;
  final String? noteId;

  ReminderModel({
    required this.id,
    required this.uid,
    required this.title, // ✅ Agregado
    required this.scheduledAt,
    this.eventId,
    this.noteId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title, // ✅ Guardar título
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'eventId': eventId,
      'noteId': noteId,
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory ReminderModel.fromMap(Map<String, dynamic> map) {
    return ReminderModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? 'Recordatorio', // ✅ Valor por defecto
      scheduledAt: _parseTimestamp(map['scheduledAt']),
      eventId: map['eventId'],
      noteId: map['noteId'],
    );
  }

  ReminderModel copyWith({
    String? id,
    String? uid,
    String? title,
    DateTime? scheduledAt,
    String? eventId,
    String? noteId,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      eventId: eventId ?? this.eventId,
      noteId: noteId ?? this.noteId,
    );
  }
}
