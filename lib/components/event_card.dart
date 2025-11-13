import 'package:flutter/material.dart';
import '../models/event_model.dart';
import '../utils/date_utils.dart';

// Tarjeta para mostrar información de un evento
class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;
  final void Function(String action)? onActionSelected;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onActionSelected,
  });

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
        trailing: onActionSelected != null
            ? PopupMenuButton<String>(
                onSelected: (value) => onActionSelected!(value),
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              )
            : null,
      ),
    );
  }
}
