import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String uid;
  final String title;
  final String description;
  final DateTime startDate;
  final DateTime endDate;

  EventModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
    };
  }

  static DateTime _parseTimestamp(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] ?? '',
      uid: map['uid'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      startDate: _parseTimestamp(map['startDate']),
      endDate: _parseTimestamp(map['endDate']),
    );
  }

  EventModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return EventModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
