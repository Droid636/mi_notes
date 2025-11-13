import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 👈 Import necesario para formatear la fecha
import '../models/reminder_model.dart';

class ReminderTile extends StatelessWidget {
  final ReminderModel reminder;
  final VoidCallback? onTap;
  final Widget? trailing;

  const ReminderTile({
    super.key,
    required this.reminder,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // 👇 Formato bonito de fecha y hora en español (ej: 13 nov 2025, 10:30 p. m.)
    final formattedDate = DateFormat(
      'd MMM yyyy, hh:mm a',
      'es_MX',
    ).format(reminder.scheduledAt);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(
          reminder.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Programado para: $formattedDate',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
