import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/date_utils.dart'; // Para formato de fecha bonito

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(event.title),
        subtitle: Text(
          '${formatDate(event.startDate)} - ${formatDate(event.endDate)}',
        ),
        onTap: onTap,
      ),
    );
  }
}
