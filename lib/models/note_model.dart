import 'package:cloud_firestore/cloud_firestore.dart';

class NoteModel {
  final String id;
  final String uid;
  final String title;
  final String content;
  final bool pinned;
  final DateTime createdAt;

  NoteModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'content': content,
      'pinned': pinned,
      // Guardamos como Timestamp para consistencia en Firestore
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper para parsear distintos tipos que puedan venir de Firestore
  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    if (value is String) {
      // Intenta parsear ISO string
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    // Fallback
    return DateTime.now();
  }

  factory NoteModel.fromMap(Map<String, dynamic> map) {
    return NoteModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      pinned: map['pinned'] ?? false,
      createdAt: _parseTimestamp(map['createdAt']),
    );
  }

  NoteModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? content,
    bool? pinned,
    DateTime? createdAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      content: content ?? this.content,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
